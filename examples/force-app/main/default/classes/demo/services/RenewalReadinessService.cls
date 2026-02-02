/**
 * Business logic for Renewal Readiness calculations and side effects.
 */
public class RenewalReadinessService implements IRenewalReadinessService {
    public static final String RENEWAL_TYPE = 'Renewal';
    public static final String AT_RISK_TASK_SUBJECT = 'Follow up: At-risk renewal';
    public static final String REVIEW_TASK_SUBJECT = 'Review renewal readiness';
    public static final Integer URGENT_DAYS = 14;
    public static final Integer REVIEW_TASK_DAYS = 30;

    private static Boolean internalUpdate = false;

    private final IOpportunityRepository opportunityRepository;
    private final IOpportunityLineItemRepository lineItemRepository;
    private final IAccountRepository accountRepository;
    private final ITaskRepository taskRepository;
    private final IClock clock;

    public RenewalReadinessService() {
        DemoServices.registerAll();
        if (Test.isRunningTest() && !ServiceRegistry.isRegistered(IOpportunityRepository.class)) {
            return;
        }
        this.opportunityRepository =
            (IOpportunityRepository) ServiceRegistry.resolve(IOpportunityRepository.class);
        this.lineItemRepository =
            (IOpportunityLineItemRepository) ServiceRegistry.resolve(IOpportunityLineItemRepository.class);
        this.accountRepository =
            (IAccountRepository) ServiceRegistry.resolve(IAccountRepository.class);
        this.taskRepository =
            (ITaskRepository) ServiceRegistry.resolve(ITaskRepository.class);
        this.clock = (IClock) ServiceRegistry.resolve(IClock.class);
    }

    public RenewalReadinessService(
        IOpportunityRepository opportunityRepository,
        IOpportunityLineItemRepository lineItemRepository,
        IAccountRepository accountRepository,
        ITaskRepository taskRepository,
        IClock clock
    ) {
        this.opportunityRepository = opportunityRepository;
        this.lineItemRepository = lineItemRepository;
        this.accountRepository = accountRepository;
        this.taskRepository = taskRepository;
        this.clock = clock;
    }

    public static Boolean isInternalUpdate() {
        return internalUpdate;
    }

    public void recalcByOpportunityIds(Set<Id> opportunityIds) {
        if (!isReady() || opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }

        Map<Id, Opportunity> oppMap = opportunityRepository.getByIds(opportunityIds);
        if (oppMap == null || oppMap.isEmpty()) {
            return;
        }

        List<Opportunity> renewals = new List<Opportunity>();
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : oppMap.values()) {
            if (!isRenewalOpen(opp)) {
                continue;
            }
            renewals.add(opp);
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        if (renewals.isEmpty()) {
            return;
        }

        Set<Id> renewalIds = new Set<Id>();
        for (Opportunity opp : renewals) {
            renewalIds.add(opp.Id);
        }

        List<OpportunityLineItem> lineItems =
            lineItemRepository.getByOpportunityIds(renewalIds);
        Map<Id, List<OpportunityLineItem>> lineItemsByOpp =
            groupByOpportunity(lineItems);
        Map<Id, Account> accounts = accountRepository.getByIds(accountIds);

        Datetime now = clock.now();
        Date today = now.date();

        List<Opportunity> updates = new List<Opportunity>();
        Map<Id, ReadinessResult> results = new Map<Id, ReadinessResult>();
        Set<Id> accountIdsForSummary = new Set<Id>();
        Set<Id> blockedOppIds = new Set<Id>();

        for (Opportunity opp : renewals) {
            List<OpportunityLineItem> items =
                lineItemsByOpp.containsKey(opp.Id)
                ? lineItemsByOpp.get(opp.Id)
                : new List<OpportunityLineItem>();
            Account acct = accounts.get(opp.AccountId);
            ReadinessResult result = calculateReadiness(opp, items, acct, today, now);
            if (result.blocked == true) {
                blockedOppIds.add(opp.Id);
                updates.add(new Opportunity(
                    Id = opp.Id,
                    RenewalHealthScore__c = null,
                    RenewalReadinessStatus__c = null,
                    LastReadinessCalc__c = null
                ));
            } else {
                results.put(opp.Id, result);
                updates.add(new Opportunity(
                    Id = opp.Id,
                    RenewalHealthScore__c = result.score,
                    RenewalReadinessStatus__c = result.status,
                    LastReadinessCalc__c = result.lastCalculated
                ));
            }
            if (opp.AccountId != null) {
                accountIdsForSummary.add(opp.AccountId);
            }
        }

        if (updates.isEmpty()) {
            return;
        }

        internalUpdate = true;
        try {
            opportunityRepository.updateRecords(updates);
        } finally {
            internalUpdate = false;
        }

        handleAtRiskTasks(results);
        clearAtRiskTasks(blockedOppIds);
        updateAccountSummaries(accountIdsForSummary);
    }

    public void createReviewTasksForHighPriority(List<Opportunity> newOpps) {
        if (!isReady() || newOpps == null || newOpps.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (!isRenewalOpen(opp) || opp.AccountId == null) {
                continue;
            }
            oppIds.add(opp.Id);
            accountIds.add(opp.AccountId);
        }

        if (oppIds.isEmpty()) {
            return;
        }

        Map<Id, Account> accounts = accountRepository.getByIds(accountIds);
        List<Task> existing = taskRepository.getByOpportunityIds(oppIds, REVIEW_TASK_SUBJECT);
        Map<Id, List<Task>> existingByOpp = mapTasksByOpp(existing);

        Date today = clock.now().date();
        List<Task> toInsert = new List<Task>();
        List<Task> toDelete = new List<Task>();

        for (Opportunity opp : newOpps) {
            if (!isRenewalOpen(opp) || opp.AccountId == null) {
                continue;
            }
            Account acct = accounts.get(opp.AccountId);
            if (!isHighPriority(acct)) {
                continue;
            }
            if (opp.CloseDate == null || opp.CloseDate > today.addDays(REVIEW_TASK_DAYS)) {
                continue;
            }
            List<Task> existingTasks = existingByOpp.get(opp.Id);
            if (existingTasks != null && !existingTasks.isEmpty()) {
                toDelete.addAll(getDuplicateTasks(existingTasks));
                continue;
            }
            toInsert.add(buildTask(opp.Id, REVIEW_TASK_SUBJECT));
        }

        if (!toDelete.isEmpty()) {
            taskRepository.deleteRecords(toDelete);
        }
        if (!toInsert.isEmpty()) {
            taskRepository.insertRecords(toInsert);
        }
    }

    public RenewalReadinessDto loadDto(Id opportunityId) {
        if (!isReady() || opportunityId == null) {
            return null;
        }
        Opportunity opp = opportunityRepository.getById(opportunityId);
        List<OpportunityLineItem> items =
            lineItemRepository.getByOpportunityIds(new Set<Id>{ opportunityId });
        return RenewalReadinessDto.fromOpportunity(opp, items);
    }

    public void updateLineItems(List<OpportunityLineItem> items) {
        if (!isReady() || items == null || items.isEmpty()) {
            return;
        }
        lineItemRepository.updateRecords(items);
    }

    public static ReadinessResult calculateReadiness(
        Opportunity opp,
        List<OpportunityLineItem> items,
        Account acct,
        Date today,
        Datetime now
    ) {
        ReadinessResult result = new ReadinessResult();
        if (opp == null) {
            return result;
        }

        // Start at baseline score.
        Integer score = 50;
        Integer confirmedCount = 0;
        Integer riskCount = 0;
        Boolean riskBlankReason = false;

        if (items != null) {
            for (OpportunityLineItem item : items) {
                if (item.Confirmed__c == true) {
                    confirmedCount++;
                }
                if (item.RiskFlag__c == true) {
                    riskCount++;
                    if (String.isBlank(item.RiskReason__c)) {
                        riskBlankReason = true;
                    }
                }
            }
        }

        if (riskBlankReason) {
            result.blocked = true;
            return result;
        }

        // Line item adjustments with caps.
        Integer confirmedBonus = confirmedCount * 10;
        if (confirmedBonus > 30) {
            confirmedBonus = 30;
        }
        Integer riskPenalty = riskCount * 15;
        if (riskPenalty > 45) {
            riskPenalty = 45;
        }

        score += confirmedBonus;
        score -= riskPenalty;

        // Account priority bonus.
        score += accountPriorityBonus(acct);

        // Urgent penalty when close date is within 14 days and score is below 60.
        if (isUrgent(opp, today) && score < 60) {
            score -= 10;
        }

        // Clamp to 0..100 and map to status.
        score = clamp(score, 0, 100);

        result.score = score;
        result.status = mapStatus(score);
        // Always set last calculated timestamp on success.
        result.lastCalculated = now;
        return result;
    }

    private static Boolean isUrgent(Opportunity opp, Date today) {
        if (opp == null || opp.CloseDate == null || today == null) {
            return false;
        }
        return opp.CloseDate <= today.addDays(URGENT_DAYS);
    }

    private static Integer accountPriorityBonus(Account acct) {
        if (acct == null || String.isBlank(acct.CustomerPriority__c)) {
            return 0;
        }
        if (acct.CustomerPriority__c == 'High') {
            return 10;
        }
        if (acct.CustomerPriority__c == 'Medium') {
            return 5;
        }
        return 0;
    }

    private static Boolean isHighPriority(Account acct) {
        return acct != null && acct.CustomerPriority__c == 'High';
    }

    private static Integer clamp(Integer value, Integer minValue, Integer maxValue) {
        if (value == null) {
            return minValue;
        }
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }

    private static String mapStatus(Integer score) {
        if (score >= 80) {
            return 'Green';
        }
        if (score >= 50) {
            return 'Amber';
        }
        return 'Red';
    }


    private void handleAtRiskTasks(Map<Id, ReadinessResult> results) {
        if (results == null || results.isEmpty()) {
            return;
        }

        Set<Id> oppIds = results.keySet();
        List<Task> existing = taskRepository.getByOpportunityIds(oppIds, AT_RISK_TASK_SUBJECT);
        Map<Id, List<Task>> existingByOpp = mapTasksByOpp(existing);

        List<Task> toInsert = new List<Task>();
        List<Task> toUpdate = new List<Task>();
        List<Task> toDelete = new List<Task>();

        for (Id oppId : oppIds) {
            ReadinessResult result = results.get(oppId);
            List<Task> existingTasks = existingByOpp.get(oppId);
            Task existingTask = getPrimaryTask(existingTasks);
            if (result.status == 'Red') {
                if (existingTask == null) {
                    toInsert.add(buildTask(oppId, AT_RISK_TASK_SUBJECT));
                } else {
                    existingTask.Status = 'Not Started';
                    existingTask.Priority = 'High';
                    toUpdate.add(existingTask);
                    toDelete.addAll(getDuplicateTasks(existingTasks));
                }
            } else if (existingTask != null) {
                toDelete.addAll(existingTasks);
            }
        }

        if (!toInsert.isEmpty()) {
            taskRepository.insertRecords(toInsert);
        }
        if (!toUpdate.isEmpty()) {
            taskRepository.updateRecords(toUpdate);
        }
        if (!toDelete.isEmpty()) {
            taskRepository.deleteRecords(toDelete);
        }
    }

    private void clearAtRiskTasks(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }
        List<Task> existing =
            taskRepository.getByOpportunityIds(opportunityIds, AT_RISK_TASK_SUBJECT);
        if (existing == null || existing.isEmpty()) {
            return;
        }
        taskRepository.deleteRecords(existing);
    }

    private void updateAccountSummaries(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        List<Opportunity> renewals = opportunityRepository.getRenewalsByAccountIds(accountIds);
        Map<Id, SummaryCounts> countsByAccount = new Map<Id, SummaryCounts>();

        for (Opportunity opp : renewals) {
            if (opp.AccountId == null) {
                continue;
            }
            if (opp.LastReadinessCalc__c == null) {
                continue;
            }
            SummaryCounts counts = countsByAccount.get(opp.AccountId);
            if (counts == null) {
                counts = new SummaryCounts();
                countsByAccount.put(opp.AccountId, counts);
            }
            counts.total++;
            if (opp.RenewalReadinessStatus__c == 'Green') {
                counts.green++;
            } else if (opp.RenewalReadinessStatus__c == 'Amber') {
                counts.amber++;
            } else if (opp.RenewalReadinessStatus__c == 'Red') {
                counts.red++;
            }
        }

        List<Account> updates = new List<Account>();
        for (Id accountId : accountIds) {
            SummaryCounts counts = countsByAccount.containsKey(accountId)
                ? countsByAccount.get(accountId)
                : new SummaryCounts();
            updates.add(new Account(
                Id = accountId,
                RenewalReadinessSummary__c = buildSummary(counts)
            ));
        }

        if (!updates.isEmpty()) {
            accountRepository.updateRecords(updates);
        }
    }

    public static String buildSummary(SummaryCounts counts) {
        if (counts == null) {
            return '0 renewals: 0 Green, 0 Amber, 0 Red';
        }
        return counts.total + ' renewals: ' + counts.green + ' Green, ' +
            counts.amber + ' Amber, ' + counts.red + ' Red';
    }

    private static Map<Id, List<OpportunityLineItem>> groupByOpportunity(
        List<OpportunityLineItem> items
    ) {
        Map<Id, List<OpportunityLineItem>> results =
            new Map<Id, List<OpportunityLineItem>>();
        if (items == null) {
            return results;
        }
        for (OpportunityLineItem item : items) {
            if (item.OpportunityId == null) {
                continue;
            }
            if (!results.containsKey(item.OpportunityId)) {
                results.put(item.OpportunityId, new List<OpportunityLineItem>());
            }
            results.get(item.OpportunityId).add(item);
        }
        return results;
    }

    private static Map<Id, List<Task>> mapTasksByOpp(List<Task> tasks) {
        Map<Id, List<Task>> results = new Map<Id, List<Task>>();
        if (tasks == null) {
            return results;
        }
        for (Task task : tasks) {
            if (task.WhatId != null) {
                if (!results.containsKey(task.WhatId)) {
                    results.put(task.WhatId, new List<Task>());
                }
                results.get(task.WhatId).add(task);
            }
        }
        return results;
    }

    private static Task getPrimaryTask(List<Task> tasks) {
        return tasks == null || tasks.isEmpty() ? null : tasks[0];
    }

    private static List<Task> getDuplicateTasks(List<Task> tasks) {
        if (tasks == null || tasks.size() <= 1) {
            return new List<Task>();
        }
        List<Task> duplicates = new List<Task>();
        for (Integer index = 1; index < tasks.size(); index++) {
            duplicates.add(tasks[index]);
        }
        return duplicates;
    }

    private static Task buildTask(Id oppId, String subject) {
        return new Task(
            Subject = subject,
            WhatId = oppId,
            Status = 'Not Started',
            Priority = 'High'
        );
    }

    private Boolean isReady() {
        return opportunityRepository != null &&
            lineItemRepository != null &&
            accountRepository != null &&
            taskRepository != null &&
            clock != null;
    }

    private static Boolean isRenewalOpen(Opportunity opp) {
        return opp != null &&
            opp.Type == RENEWAL_TYPE &&
            opp.IsClosed == false;
    }

    public class ReadinessResult {
        public Integer score;
        public String status;
        public Datetime lastCalculated;
        public Boolean blocked = false;
    }

    public class SummaryCounts {
        public Integer total = 0;
        public Integer green = 0;
        public Integer amber = 0;
        public Integer red = 0;
    }
}
