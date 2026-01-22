/**
 * Unit tests for {@link OpportunityPipelineService}.
 */
@isTest
private class OpportunityPipelineServiceTest extends BaseTest {
    @isTest
    static void returnsMyEastOpportunitiesAndAccounts() {
        TestBootstrap.defaults();
        OpportunityPipelineService svc = new OpportunityPipelineService(
            new MockAccountSelector(),
            new MockOpportunitySelector()
        );

        List<Opportunity> opps = svc.getMyOpportunitiesClosingThisQuarter();
        List<Account> accounts = svc.getMyAccounts();

        System.assertEquals(1, opps.size());
        System.assertEquals('Mock East Opportunity', opps[0].Name);
        System.assertEquals(UserInfo.getUserId(), opps[0].OwnerId);
        System.assertEquals(1, accounts.size());
        System.assertEquals(UserInfo.getUserId(), accounts[0].OwnerId);
        assertSlowTest();
    }
}
