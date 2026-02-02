/**
 * Trigger handler for Renewal Opportunity events.
 */
public class RenewalOpportunityTriggerHandler extends TriggerHandler {
    private IRenewalReadinessService service;

    /**
     * Register services and resolve the readiness service dependency.
     * In tests, allows a missing registration so mocks can be injected.
     */
    public RenewalOpportunityTriggerHandler() {
        DemoServices.registerAll();
        if (Test.isRunningTest() && !ServiceRegistry.isRegistered(IRenewalReadinessService.class)) {
            return;
        }
        this.service = (IRenewalReadinessService)
            ServiceRegistry.resolve(IRenewalReadinessService.class);
    }

    /**
     * Recalculate readiness and create review tasks for new renewals.
     */
    public override void afterInsert(List<SObject> newList) {
        if (service == null || RenewalReadinessService.isInternalUpdate()) {
            return;
        }
        // Convert trigger scope to Opportunities and ignore non-matching records.
        List<Opportunity> opps = toOpportunities(newList);
        if (opps.isEmpty()) {
            return;
        }
        // Initial readiness calculation for newly inserted renewal opportunities.
        service.recalcByOpportunityIds(getIds(opps));
        // Create follow-up tasks for high-priority renewals due soon.
        service.createReviewTasksForHighPriority(opps);
    }

    /**
     * Recalculate readiness only when relevant fields change.
     */
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        if (service == null || RenewalReadinessService.isInternalUpdate()) {
            return;
        }
        if (oldMap == null || oldMap.isEmpty()) {
            return;
        }
        // Only recalc when key fields change to avoid unnecessary work.
        List<Opportunity> opps = toOpportunities(newList);
        if (opps.isEmpty()) {
            return;
        }
        Set<Id> toRecalc = new Set<Id>();
        for (Opportunity opp : opps) {
            Opportunity oldOpp = (Opportunity) oldMap.get(opp.Id);
            if (oldOpp == null) {
                continue;
            }
            if (opp.CloseDate != oldOpp.CloseDate ||
                opp.StageName != oldOpp.StageName ||
                opp.Amount != oldOpp.Amount) {
                toRecalc.add(opp.Id);
            }
        }
        // Delegate recalculation for the subset with relevant changes.
        if (!toRecalc.isEmpty()) {
            service.recalcByOpportunityIds(toRecalc);
        }
    }

    /**
     * Cast trigger scope into Opportunity records.
     */
    private static List<Opportunity> toOpportunities(List<SObject> records) {
        List<Opportunity> results = new List<Opportunity>();
        if (records == null) {
            return results;
        }
        // Filter trigger scope to Opportunity records only.
        for (SObject record : records) {
            if (record instanceof Opportunity) {
                results.add((Opportunity) record);
            }
        }
        return results;
    }

    /**
     * Extract ids for service calls.
     */
    private static Set<Id> getIds(List<Opportunity> opps) {
        Set<Id> ids = new Set<Id>();
        for (Opportunity opp : opps) {
            ids.add(opp.Id);
        }
        return ids;
    }
}
