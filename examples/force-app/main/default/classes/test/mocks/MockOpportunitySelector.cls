/**
 * Test double for {@link IOpportunitySelector} that returns predictable Opportunity records.
 */
@isTest
public class MockOpportunitySelector implements IOpportunitySelector {
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
                Amount = 100,
                CloseDate = Date.today(),
                StageName = 'Prospecting',
                AccountId = accountId
            )
        };
    }

    public List<AggregateResult> getCountsAndAmountsByRegion(String region) {
        if (String.isBlank(region)) {
            return new List<AggregateResult>();
        }
        Integer totalCount = region == 'East' ? 2 : 1;
        Decimal totalAmount = region == 'East' ? 350 : 100;
        String payload =
            '[{"totalCount":' + totalCount + ',"totalAmount":' + String.valueOf(totalAmount) + '}]';
        return (List<AggregateResult>) JSON.deserialize(payload, List<AggregateResult>.class);
    }

    public List<Opportunity> getClosingThisQuarter(String region, Id ownerId) {
        if (String.isBlank(region) || ownerId == null || region != 'East') {
            return new List<Opportunity>();
        }
        return new List<Opportunity>{
            new Opportunity(
                Id = '006000000000002AAA',
                Name = 'Mock East Opportunity',
                Amount = 250,
                CloseDate = Date.today(),
                StageName = 'Qualification',
                AccountId = '001000000000003AAA',
                OwnerId = ownerId
            )
        };
    }

    public List<Opportunity> getRenewalsByAccountIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Opportunity>();
        }
        List<Opportunity> results = new List<Opportunity>();
        for (Id accountId : accountIds) {
            results.add(new Opportunity(
                Id = '006000000000009AAA',
                Name = 'Mock Renewal Opportunity',
                AccountId = accountId,
                Type = 'Renewal',
                CloseDate = Date.today().addDays(30),
                StageName = 'Negotiation/Review'
            ));
        }
        return results;
    }

    public Database.QueryLocator getStaleRenewalQuery(Datetime cutoff) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Opportunity
            WHERE Id = null
        ]);
    }
}
