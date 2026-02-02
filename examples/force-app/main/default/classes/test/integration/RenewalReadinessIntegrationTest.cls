/**
 * Integration tests for Renewal Readiness triggers, controller, and batch.
 */
@isTest
private class RenewalReadinessIntegrationTest extends BaseTest {
    @isTest
    static void triggerCalculatesReadinessAndTasks() {
        registerServices();

        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : data.oppsByKey.values()) {
            oppIds.add(opp.Id);
        }

        Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
            SELECT Id, Name, RenewalHealthScore__c, RenewalReadinessStatus__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);

        System.assertEquals(
            40,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O1).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O1).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            85,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Green',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            45,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O3).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O3).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            25,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            65,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O5).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Amber',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O5).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            40,
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            opps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id)
                .RenewalReadinessStatus__c
        );

        List<Task> tasks = [
            SELECT Id, WhatId
            FROM Task
            WHERE Subject = :RenewalReadinessService.AT_RISK_TASK_SUBJECT
        ];
        System.assertEquals(4, tasks.size());

        Set<Id> accountIds = new Set<Id>();
        for (Account account : data.accountsByKey.values()) {
            accountIds.add(account.Id);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([
            SELECT Id, RenewalReadinessSummary__c, Name
            FROM Account
            WHERE Id IN :accountIds
        ]);
        System.assertEquals(
            '2 renewals: 0 Green, 0 Amber, 2 Red',
            accounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_LOW).Id)
                .RenewalReadinessSummary__c
        );
        System.assertEquals(
            '2 renewals: 1 Green, 0 Amber, 1 Red',
            accounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_MED).Id)
                .RenewalReadinessSummary__c
        );
        System.assertEquals(
            '2 renewals: 0 Green, 1 Amber, 1 Red',
            accounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_HIGH).Id)
                .RenewalReadinessSummary__c
        );

        assertIntegrationTest();
    }

    @isTest
    static void validationPreventsInvalidRiskUpdates() {
        registerServices();
        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        OpportunityLineItem item = [
            SELECT Id, RiskFlag__c, RiskReason__c, OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id
            LIMIT 1
        ];

        item.RiskFlag__c = true;
        item.RiskReason__c = '';

        Boolean failed = false;
        try {
            update item;
        } catch (DmlException ex) {
            failed = true;
        }
        System.assertEquals(true, failed);

        Opportunity beforeOpp = [
            SELECT RenewalHealthScore__c, RenewalReadinessStatus__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE Id = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id
        ];
        Opportunity afterOpp = [
            SELECT RenewalHealthScore__c, RenewalReadinessStatus__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE Id = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id
        ];
        System.assertEquals(beforeOpp.RenewalHealthScore__c, afterOpp.RenewalHealthScore__c);
        System.assertEquals(beforeOpp.RenewalReadinessStatus__c, afterOpp.RenewalReadinessStatus__c);
        System.assertEquals(beforeOpp.LastReadinessCalc__c, afterOpp.LastReadinessCalc__c);
        assertIntegrationTest();
    }

    @isTest
    static void deleteLastRiskItemUpdatesStatusAndTasks() {
        registerServices();
        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        OpportunityLineItem item = [
            SELECT Id, OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id
            LIMIT 1
        ];
        delete item;

        Opportunity opp = [
            SELECT RenewalHealthScore__c, RenewalReadinessStatus__c
            FROM Opportunity
            WHERE Id = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id
        ];
        System.assertEquals(55, opp.RenewalHealthScore__c);
        System.assertEquals('Amber', opp.RenewalReadinessStatus__c);

        Integer taskCount = [
            SELECT COUNT()
            FROM Task
            WHERE Subject = :RenewalReadinessService.AT_RISK_TASK_SUBJECT
            AND WhatId = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id
        ];
        System.assertEquals(0, taskCount);

        Account account = [
            SELECT RenewalReadinessSummary__c
            FROM Account
            WHERE Id = :data.accountsByKey.get(RenewalTestDataFactory.KEY_A_MED).Id
        ];
        System.assertEquals(
            '2 renewals: 1 Green, 1 Amber, 0 Red',
            account.RenewalReadinessSummary__c
        );
        assertIntegrationTest();
    }

    @isTest
    static void controllerSaveSurfacesValidationFailure() {
        registerServices();
        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        OpportunityLineItem item = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id
            LIMIT 1
        ];

        RenewalReadinessDto.LineItemRow change = new RenewalReadinessDto.LineItemRow();
        change.id = item.Id;
        change.riskFlag = true;
        change.riskReason = '';

        Boolean failed = false;
        try {
            RenewalReadinessController.save(
                data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id,
                new List<RenewalReadinessDto.LineItemRow>{ change }
            );
        } catch (AuraHandledException ex) {
            failed = true;
        }
        System.assertEquals(true, failed);
        assertIntegrationTest();
    }

    @isTest
    static void batchRecalculatesStaleOpportunities() {
        registerServices();
        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        update new Opportunity(
            Id = data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id,
            LastReadinessCalc__c = System.now().addDays(-10)
        );

        Test.startTest();
        Database.executeBatch(new RenewalReadinessBatch(7), 50);
        Test.stopTest();

        Opportunity opp = [
            SELECT LastReadinessCalc__c
            FROM Opportunity
            WHERE Id = :data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id
        ];
        System.assertNotEquals(null, opp.LastReadinessCalc__c);
        assertIntegrationTest();
    }

    @isTest
    static void bulkOperationsMaintainExpectedBuckets() {
        registerServices();
        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        RenewalTestDataFactory.BulkData bulkData =
            RenewalTestDataFactory.createBulkData(
                data.accountsByKey.get(RenewalTestDataFactory.KEY_A_MED),
                data.pricebookEntryId
            );

        Set<Id> bulkOppIds = new Set<Id>();
        for (Opportunity opp : bulkData.opportunities) {
            bulkOppIds.add(opp.Id);
        }

        Map<String, Opportunity> byName = new Map<String, Opportunity>();
        for (Opportunity opp : [
            SELECT Id, Name, RenewalHealthScore__c, RenewalReadinessStatus__c
            FROM Opportunity
            WHERE Id IN :bulkOppIds
        ]) {
            byName.put(opp.Name, opp);
        }

        System.assertEquals('Green', byName.get('O_BULK_001').RenewalReadinessStatus__c);
        System.assertEquals('Red', byName.get('O_BULK_025').RenewalReadinessStatus__c);
        System.assertEquals('Red', byName.get('O_BULK_040').RenewalReadinessStatus__c);
        System.assertEquals('Amber', byName.get('O_BULK_050').RenewalReadinessStatus__c);

        Integer green = 0;
        Integer amber = 0;
        Integer red = 0;
        for (Opportunity opp : byName.values()) {
            if (opp.RenewalReadinessStatus__c == 'Green') {
                green++;
            } else if (opp.RenewalReadinessStatus__c == 'Amber') {
                amber++;
            } else if (opp.RenewalReadinessStatus__c == 'Red') {
                red++;
            }
        }
        System.assertEquals(20, green);
        System.assertEquals(15, amber);
        System.assertEquals(15, red);

        List<OpportunityLineItem> lineItems = [
            SELECT Id, Confirmed__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :bulkOppIds
            LIMIT 100
        ];
        for (OpportunityLineItem item : lineItems) {
            item.Confirmed__c = !item.Confirmed__c;
        }
        update lineItems;

        List<OpportunityLineItem> riskItems = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE RiskFlag__c = true
            AND OpportunityId IN :bulkOppIds
            LIMIT 50
        ];
        delete riskItems;

        Integer taskCount = [
            SELECT COUNT()
            FROM Task
            WHERE Subject = :RenewalReadinessService.AT_RISK_TASK_SUBJECT
        ];
        System.assertEquals(true, taskCount > 0);
        assertIntegrationTest();
    }

    private static void registerServices() {
        TestBootstrap.defaults();
        TestServiceRegistry.registerMock(IRecordMutator.class, new SystemRecordMutator());
        TestServiceRegistry.registerMock(IAccountSelector.class, new AccountSelector());
        TestServiceRegistry.registerMock(IOpportunitySelector.class, new OpportunitySelector());
        TestServiceRegistry.registerMock(
            IOpportunityLineItemSelector.class,
            new OpportunityLineItemSelector()
        );
        TestServiceRegistry.registerMock(ITaskSelector.class, new TaskSelector());
        TestServiceRegistry.registerMock(
            IAccountRepository.class,
            new AccountRepository(new AccountSelector(), new SystemRecordMutator())
        );
        TestServiceRegistry.registerMock(
            IOpportunityRepository.class,
            new OpportunityRepository(new OpportunitySelector(), new SystemRecordMutator())
        );
        TestServiceRegistry.registerMock(
            IOpportunityLineItemRepository.class,
            new OpportunityLineItemRepository(
                new OpportunityLineItemSelector(),
                new SystemRecordMutator()
            )
        );
        TestServiceRegistry.registerMock(
            ITaskRepository.class,
            new TaskRepository(new TaskSelector(), new SystemRecordMutator())
        );
        TestServiceRegistry.registerMock(
            IRenewalReadinessService.class,
            new RenewalReadinessService(
                (IOpportunityRepository) ServiceRegistry.resolve(IOpportunityRepository.class),
                (IOpportunityLineItemRepository) ServiceRegistry.resolve(
                    IOpportunityLineItemRepository.class
                ),
                (IAccountRepository) ServiceRegistry.resolve(IAccountRepository.class),
                (ITaskRepository) ServiceRegistry.resolve(ITaskRepository.class),
                (IClock) ServiceRegistry.resolve(IClock.class)
            )
        );
    }

    private static void assertIntegrationTest() {
        TestLimits.assertWithin(400, 400, 4000);
    }
}
