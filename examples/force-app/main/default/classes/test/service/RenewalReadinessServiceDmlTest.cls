/**
 * Service-level tests with limited DML for Renewal Readiness.
 */
@isTest
private class RenewalReadinessServiceDmlTest extends BaseTest {
    @isTest
    static void recalculatesReadinessAndSideEffects() {
        TestBootstrap.defaults();

        RenewalTestDataFactory.CanonicalData data =
            RenewalTestDataFactory.createCanonicalData(true);

        RenewalReadinessService service = new RenewalReadinessService(
            new OpportunityRepository(new OpportunitySelector(), new SystemRecordMutator()),
            new OpportunityLineItemRepository(
                new OpportunityLineItemSelector(),
                new SystemRecordMutator()
            ),
            new AccountRepository(new AccountSelector(), new SystemRecordMutator()),
            new TaskRepository(new TaskSelector(), new SystemRecordMutator()),
            new SystemClock()
        );

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : data.oppsByKey.values()) {
            oppIds.add(opp.Id);
        }

        service.recalcByOpportunityIds(oppIds);

        Map<Id, Opportunity> savedOpps = new Map<Id, Opportunity>([
            SELECT Id, RenewalHealthScore__c, RenewalReadinessStatus__c, LastReadinessCalc__c, Name
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);

        System.assertEquals(
            40,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O1).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O1).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            85,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Green',
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O2).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            45,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O3).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O3).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            null,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            null,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O4).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            65,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O5).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Amber',
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O5).Id)
                .RenewalReadinessStatus__c
        );
        System.assertEquals(
            40,
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id)
                .RenewalHealthScore__c
        );
        System.assertEquals(
            'Red',
            savedOpps.get(data.oppsByKey.get(RenewalTestDataFactory.KEY_O6).Id)
                .RenewalReadinessStatus__c
        );

        List<Task> tasks = [
            SELECT Id, WhatId, Subject
            FROM Task
            WHERE Subject = :RenewalReadinessService.AT_RISK_TASK_SUBJECT
        ];
        System.assertEquals(3, tasks.size());

        Map<Id, Account> savedAccounts = new Map<Id, Account>([
            SELECT Id, RenewalReadinessSummary__c, Name
            FROM Account
            WHERE Id IN :new List<Id>{
                data.accountsByKey.get(RenewalTestDataFactory.KEY_A_LOW).Id,
                data.accountsByKey.get(RenewalTestDataFactory.KEY_A_MED).Id,
                data.accountsByKey.get(RenewalTestDataFactory.KEY_A_HIGH).Id
            }
        ]);

        System.assertEquals(
            '1 renewals: 0 Green, 0 Amber, 1 Red',
            savedAccounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_LOW).Id)
                .RenewalReadinessSummary__c
        );
        System.assertEquals(
            '2 renewals: 1 Green, 0 Amber, 1 Red',
            savedAccounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_MED).Id)
                .RenewalReadinessSummary__c
        );
        System.assertEquals(
            '2 renewals: 0 Green, 1 Amber, 1 Red',
            savedAccounts.get(data.accountsByKey.get(RenewalTestDataFactory.KEY_A_HIGH).Id)
                .RenewalReadinessSummary__c
        );

        TestLimits.assertWithin(20, 10, 400);
    }
}
