/**
 * Test double for {@link IAccountRepository} that returns predictable Account records.
 */
@isTest
public class MockAccountRepository implements IAccountRepository {
    public Integer insertCount = 0;
    public Integer updateCount = 0;
    public Integer deleteCount = 0;
    public List<Account> inserted = new List<Account>();
    public List<Account> updated = new List<Account>();
    public List<Account> deleted = new List<Account>();

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

    public List<Account> getAccountsByRegion(String region) {
        if (String.isBlank(region)) {
            return new List<Account>();
        }
        List<Account> matches = new List<Account>();
        for (Account acct : TestDataFactory.mockAccounts()) {
            if (acct.BillingState == region) {
                matches.add(acct);
            }
        }
        return matches;
    }

    public List<Account> getOwnedByUser(Id ownerId) {
        if (ownerId == null) {
            return new List<Account>();
        }
        return new List<Account>{
            new Account(Id = '001000000000002AAA', Name = 'Mock Owned', OwnerId = ownerId)
        };
    }

    public Database.SaveResult[] insertRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        insertCount++;
        inserted.addAll(records);
        return new Database.SaveResult[] {};
    }

    public Database.SaveResult[] updateRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        updateCount++;
        updated.addAll(records);
        return new Database.SaveResult[] {};
    }

    public Database.DeleteResult[] deleteRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        deleteCount++;
        deleted.addAll(records);
        return new Database.DeleteResult[] {};
    }
}
