/**
 * Test double for {@link IOpportunityRepository} that returns predictable Opportunity records.
 */
@isTest
public class MockOpportunityRepository implements IOpportunityRepository {
    public Integer insertCount = 0;
    public Integer updateCount = 0;
    public Integer deleteCount = 0;
    public List<Opportunity> inserted = new List<Opportunity>();
    public List<Opportunity> updated = new List<Opportunity>();
    public List<Opportunity> deleted = new List<Opportunity>();

    public Opportunity getById(Id opportunityId) {
        return new Opportunity(Id = opportunityId, Name = 'Mock Opportunity');
    }

    public Map<Id, Opportunity> getByIds(Set<Id> opportunityIds) {
        Map<Id, Opportunity> results = new Map<Id, Opportunity>();
        if (opportunityIds == null) {
            return results;
        }
        for (Id opportunityId : opportunityIds) {
            results.put(opportunityId, new Opportunity(Id = opportunityId, Name = 'Mock Opportunity'));
        }
        return results;
    }

    public List<Opportunity> getByAccountId(Id accountId) {
        if (accountId == null) {
            return new List<Opportunity>();
        }
        return new List<Opportunity>{
            new Opportunity(
                Id = '006000000000001AAA',
                Name = 'Mock Opportunity',
                AccountId = accountId
            )
        };
    }

    public List<AggregateResult> getCountsAndAmountsByRegion(String region) {
        if (String.isBlank(region)) {
            return new List<AggregateResult>();
        }
        return new List<AggregateResult>();
    }

    public List<Opportunity> getClosingThisQuarter(String region, Id ownerId) {
        if (String.isBlank(region) || ownerId == null) {
            return new List<Opportunity>();
        }
        return new List<Opportunity>{
            new Opportunity(
                Id = '006000000000002AAA',
                Name = 'Mock East Opportunity',
                OwnerId = ownerId
            )
        };
    }

    public Database.SaveResult[] insertRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        insertCount++;
        inserted.addAll(records);
        return new Database.SaveResult[] {};
    }

    public Database.SaveResult[] updateRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        updateCount++;
        updated.addAll(records);
        return new Database.SaveResult[] {};
    }

    public Database.DeleteResult[] deleteRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        deleteCount++;
        deleted.addAll(records);
        return new Database.DeleteResult[] {};
    }
}
