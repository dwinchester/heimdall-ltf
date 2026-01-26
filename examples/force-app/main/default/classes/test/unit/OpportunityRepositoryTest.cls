/**
 * Unit tests for {@link OpportunityRepository}.
 */
@isTest
private class OpportunityRepositoryTest extends BaseTest {
    @isTest
    static void delegatesReadsToSelector() {
        resetRegistry();
        OpportunityRepository repo =
            new OpportunityRepository(new MockOpportunitySelector(), new MockRecordMutator());

        Id opportunityId = Id.valueOf('006000000000001AAA');
        Opportunity opp = repo.getById(opportunityId);
        System.assertEquals('Mock Opportunity', opp.Name);

        Map<Id, Opportunity> opps = repo.getByIds(new Set<Id>{ opportunityId });
        System.assertEquals(1, opps.size());
        System.assertEquals('Mock Opportunity', opps.get(opportunityId).Name);

        Id accountId = Id.valueOf('001000000000002AAA');
        List<Opportunity> byAccount = repo.getByAccountId(accountId);
        System.assertEquals(1, byAccount.size());
        System.assertEquals(accountId, byAccount[0].AccountId);

        List<AggregateResult> aggregates = repo.getCountsAndAmountsByRegion('East');
        System.assertEquals(1, aggregates.size());

        List<Opportunity> closing = repo.getClosingThisQuarter('East', UserInfo.getUserId());
        System.assertEquals(1, closing.size());
        System.assertEquals(UserInfo.getUserId(), closing[0].OwnerId);
        assertFastTest();
    }

    @isTest
    static void delegatesWritesToMutator() {
        resetRegistry();
        MockRecordMutator mutator = new MockRecordMutator();
        OpportunityRepository repo = new OpportunityRepository(new MockOpportunitySelector(), mutator);

        List<Opportunity> records = new List<Opportunity>{
            new Opportunity(Name = 'One', StageName = 'Prospecting', CloseDate = Date.today()),
            new Opportunity(Name = 'Two', StageName = 'Prospecting', CloseDate = Date.today())
        };
        repo.insertRecords(records);
        repo.updateRecords(records);
        repo.deleteRecords(records);

        System.assertEquals(1, mutator.insertCount);
        System.assertEquals(1, mutator.updateCount);
        System.assertEquals(1, mutator.deleteCount);
        System.assertEquals(2, mutator.inserted.size());
        System.assertEquals(2, mutator.updated.size());
        System.assertEquals(2, mutator.deleted.size());
        assertFastTest();
    }

    @isTest
    static void writeMethodsHandleNullOrEmpty() {
        resetRegistry();
        MockRecordMutator mutator = new MockRecordMutator();
        OpportunityRepository repo = new OpportunityRepository(new MockOpportunitySelector(), mutator);

        System.assertEquals(0, repo.insertRecords(null).size());
        System.assertEquals(0, repo.updateRecords(new List<Opportunity>()).size());
        System.assertEquals(0, repo.deleteRecords(new List<Opportunity>()).size());
        System.assertEquals(0, mutator.insertCount);
        System.assertEquals(0, mutator.updateCount);
        System.assertEquals(0, mutator.deleteCount);
        assertFastTest();
    }
}
