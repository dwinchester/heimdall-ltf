/**
 * Test double for {@link IAccountSelector} that returns predictable Account records.
 *
 * Useful when you want selector behavior without inserting/querying real data.
 */
@isTest
public class MockAccountSelector implements IAccountSelector {
    public Account getById(Id accountId) {
        return new Account(Id = accountId, Name = 'Mock');
    }

    public Map<Id, Account> getByIds(Set<Id> accountIds) {
        Map<Id, Account> results = new Map<Id, Account>();
        if (accountIds == null) {
            return results;
        }
        for (Id accountId : accountIds) {
            results.put(accountId, new Account(Id = accountId, Name = 'Mock'));
        }
        return results;
    }
}

