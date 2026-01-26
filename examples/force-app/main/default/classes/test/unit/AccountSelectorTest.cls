/**
 * Unit tests for {@link AccountSelector}.
 */
@isTest
private class AccountSelectorTest extends BaseTest {
    @testSetup
    static void setup() {
        resetRegistry();
        TestServiceRegistry.registerMock(IAccountRepository.class, new MockAccountRepository());

        User otherUser = new User(
            Username = 'other.user.' + DateTime.now().getTime() + '@example.com',
            LastName = 'Other',
            Email = 'other.user@example.com',
            Alias = 'othr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = UserInfo.getProfileId()
        );
        insert otherUser;

        Account mine = new Account(Name = 'Mine', OwnerId = UserInfo.getUserId());
        Account theirs = new Account(Name = 'Theirs', OwnerId = otherUser.Id);
        insert new List<Account>{ mine, theirs };
    }

    @isTest
    static void getByIdReturnsAccount() {
        Account acc = TestDataFactory.account(true);
        AccountSelector selector = new AccountSelector();

        Account result = selector.getById(acc.Id);

        System.assertEquals(acc.Id, result.Id);
        System.assertEquals(acc.Name, result.Name);
        assertSlowTest();
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
        assertSlowTest();
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
        assertSlowTest();
    }

    @isTest
    static void getOwnedByUserReturnsMatches() {
        Account mine = [
            SELECT Id
            FROM Account
            WHERE Name = 'Mine' AND OwnerId = :UserInfo.getUserId()
            LIMIT 1
        ];
        Account mineToo = new Account(
            Name = 'Mine Too',
            OwnerId = UserInfo.getUserId()
        );
        insert mineToo;
        Account theirs = [
            SELECT Id
            FROM Account
            WHERE Name = 'Theirs' AND OwnerId != :UserInfo.getUserId()
            LIMIT 1
        ];

        AccountSelector selector = new AccountSelector();
        List<Account> results = selector.getOwnedByUser(UserInfo.getUserId());

        Set<Id> resultIds = new Set<Id>();
        for (Account acc : results) {
            resultIds.add(acc.Id);
        }

        System.assertEquals(2, results.size());
        System.assert(resultIds.contains(mine.Id));
        System.assert(resultIds.contains(mineToo.Id));
        System.assert(!resultIds.contains(theirs.Id));
        assertSlowTest();
    }
}
