/**
 * Unit tests for {@link AccountRepository}.
 */
@isTest
private class AccountRepositoryTest extends BaseTest {
    @isTest
    static void delegatesReadsToSelector() {
        resetRegistry();
        AccountRepository repo = new AccountRepository(new MockAccountSelector(), new MockRecordMutator());

        Id accountId = Id.valueOf('001000000000001AAA');
        Account account = repo.getById(accountId);
        System.assertEquals('Mock', account.Name);

        Map<Id, Account> accounts = repo.getByIds(new Set<Id>{ accountId });
        System.assertEquals(1, accounts.size());
        System.assertEquals('Mock', accounts.get(accountId).Name);

        List<Account> eastAccounts = repo.getAccountsByRegion('East');
        System.assert(!eastAccounts.isEmpty());
        for (Account acc : eastAccounts) {
            System.assertEquals('East', acc.BillingState);
        }

        List<Account> owned = repo.getOwnedByUser(UserInfo.getUserId());
        System.assertEquals(1, owned.size());
        System.assertEquals(UserInfo.getUserId(), owned[0].OwnerId);
        assertFastTest();
    }

    @isTest
    static void delegatesWritesToMutator() {
        resetRegistry();
        MockRecordMutator mutator = new MockRecordMutator();
        AccountRepository repo = new AccountRepository(new MockAccountSelector(), mutator);

        List<Account> records = new List<Account>{ new Account(Name = 'One'), new Account(Name = 'Two') };
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
        AccountRepository repo = new AccountRepository(new MockAccountSelector(), mutator);

        System.assertEquals(0, repo.insertRecords(null).size());
        System.assertEquals(0, repo.updateRecords(new List<Account>()).size());
        System.assertEquals(0, repo.deleteRecords(new List<Account>()).size());
        System.assertEquals(0, mutator.insertCount);
        System.assertEquals(0, mutator.updateCount);
        System.assertEquals(0, mutator.deleteCount);
        assertFastTest();
    }
}
