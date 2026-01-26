/**
 * Unit tests for {@link OpportunitySelector}.
 */
@isTest
private class OpportunitySelectorTest extends BaseTest {
    @isTest
    static void getByAccountIdReturnsMatches() {
        resetRegistry();
        TestServiceRegistry.registerMock(IAccountRepository.class, new MockAccountRepository());

        Account east = new Account(Name = 'East Account', BillingState = 'East');
        Account west = new Account(Name = 'West Account', BillingState = 'West');
        insert new List<Account>{ east, west };

        Opportunity o1 = new Opportunity(
            Name = 'East Opp 1',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 100,
            AccountId = east.Id
        );
        Opportunity o2 = new Opportunity(
            Name = 'East Opp 2',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            Amount = 200,
            AccountId = east.Id
        );
        Opportunity o3 = new Opportunity(
            Name = 'West Opp 1',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 300,
            AccountId = west.Id
        );
        insert new List<Opportunity>{ o1, o2, o3 };

        OpportunitySelector selector = new OpportunitySelector();
        List<Opportunity> results = selector.getByAccountId(east.Id);

        System.assertEquals(2, results.size());
        for (Opportunity opp : results) {
            System.assertEquals(east.Id, opp.AccountId);
        }
        assertSlowTest();
    }

    @isTest
    static void getCountsAndAmountsByRegionReturnsAggregate() {
        resetRegistry();
        TestServiceRegistry.registerMock(IAccountRepository.class, new MockAccountRepository());

        Account east = new Account(Name = 'East Account', BillingState = 'East');
        Account west = new Account(Name = 'West Account', BillingState = 'West');
        insert new List<Account>{ east, west };

        insert new List<Opportunity>{
            new Opportunity(
                Name = 'East Opp 1',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 100,
                AccountId = east.Id
            ),
            new Opportunity(
                Name = 'East Opp 2',
                StageName = 'Qualification',
                CloseDate = Date.today(),
                Amount = 250,
                AccountId = east.Id
            ),
            new Opportunity(
                Name = 'West Opp 1',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 400,
                AccountId = west.Id
            )
        };

        OpportunitySelector selector = new OpportunitySelector();
        List<AggregateResult> results = selector.getCountsAndAmountsByRegion('East');

        System.assertEquals(1, results.size());
        Integer totalCount = (Integer) results[0].get('totalCount');
        Decimal totalAmount = (Decimal) results[0].get('totalAmount');
        System.assertEquals(2, totalCount);
        System.assertEquals(350, totalAmount);
        assertSlowTest();
    }

    @isTest
    static void getClosingThisQuarterReturnsMatches() {
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

        Account east = new Account(Name = 'East Account', BillingState = 'East');
        Account west = new Account(Name = 'West Account', BillingState = 'West');
        insert new List<Account>{ east, west };

        insert new List<Opportunity>{
            new Opportunity(
                Name = 'Match Opp',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 500,
                AccountId = east.Id,
                OwnerId = UserInfo.getUserId()
            ),
            new Opportunity(
                Name = 'Wrong Region',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 150,
                AccountId = west.Id,
                OwnerId = UserInfo.getUserId()
            ),
            new Opportunity(
                Name = 'Wrong Owner',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 200,
                AccountId = east.Id,
                OwnerId = otherUser.Id
            ),
            new Opportunity(
                Name = 'Wrong Quarter',
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(4),
                Amount = 300,
                AccountId = east.Id,
                OwnerId = UserInfo.getUserId()
            )
        };

        OpportunitySelector selector = new OpportunitySelector();
        List<Opportunity> results =
            selector.getClosingThisQuarter('East', UserInfo.getUserId());

        System.assertEquals(1, results.size());
        System.assertEquals(east.Id, results[0].AccountId);
        System.assertEquals(UserInfo.getUserId(), results[0].OwnerId);
        assertSlowTest();
    }

    @isTest
    static void getByIdReturnsOpportunity() {
        resetRegistry();
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Opportunity opp = new Opportunity(
            Name = 'Target',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acct.Id
        );
        insert opp;

        OpportunitySelector selector = new OpportunitySelector();
        Opportunity result = selector.getById(opp.Id);

        System.assertEquals(opp.Id, result.Id);
        System.assertEquals(opp.Name, result.Name);
        assertSlowTest();
    }

    @isTest
    static void getByIdsReturnsMap() {
        resetRegistry();
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Opportunity o1 = new Opportunity(
            Name = 'One',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acct.Id
        );
        Opportunity o2 = new Opportunity(
            Name = 'Two',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acct.Id
        );
        insert new List<Opportunity>{ o1, o2 };

        OpportunitySelector selector = new OpportunitySelector();
        Map<Id, Opportunity> results = selector.getByIds(new Set<Id>{ o1.Id, o2.Id });

        System.assertEquals(2, results.size());
        System.assertEquals('One', results.get(o1.Id).Name);
        System.assertEquals('Two', results.get(o2.Id).Name);
        assertSlowTest();
    }
}
