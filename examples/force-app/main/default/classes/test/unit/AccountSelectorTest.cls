/**
 * Unit tests for {@link AccountSelector}.
 */
@isTest
private class AccountSelectorTest extends BaseTest {
    @isTest
    static void getByIdReturnsAccount() {
        Account acc = TestDataFactory.account(true);
        AccountSelector selector = new AccountSelector();

        Account result = selector.getById(acc.Id);

        System.assertEquals(acc.Id, result.Id);
        System.assertEquals(acc.Name, result.Name);
        assertFastTest();
    }

    @isTest
    static void getByIdsReturnsMap() {
        Account a1 = new Account(Name = 'Test A');
        Account a2 = new Account(Name = 'Test B');
        insert new List<Account>{ a1, a2 };

        AccountSelector selector = new AccountSelector();
        Map<Id, Account> results = selector.getByIds(new Set<Id>{ a1.Id, a2.Id });

        System.assertEquals(2, results.size());
        System.assertEquals(a1.Name, results.get(a1.Id).Name);
        System.assertEquals(a2.Name, results.get(a2.Id).Name);
        assertFastTest();
    }

    @isTest
    static void getAccountsByRegionReturnsMatches() {
        TestDataFactory.mockAccounts(true);

        AccountSelector selector = new AccountSelector();
        List<Account> results = selector.getAccountsByRegion('East');

        System.assertEquals(5, results.size());
        for (Account acc : results) {
            System.assertEquals('East', acc.BillingState);
        }
        assertFastTest();
    }
}
