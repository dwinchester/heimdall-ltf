/**
 * Example service that composes Account and Opportunity selectors.
 */
public class OpportunityPipelineService {
    private final IAccountSelector accountSelector;
    private final IOpportunitySelector opportunitySelector;

    public OpportunityPipelineService(IAccountSelector accountSelector, IOpportunitySelector opportunitySelector) {
        this.accountSelector = accountSelector;
        this.opportunitySelector = opportunitySelector;
    }

    /**
     * Returns Opportunities owned by the current user, closing this quarter, in the East region.
     */
    public List<Opportunity> getMyOpportunitiesClosingThisQuarter() {
        return opportunitySelector.getClosingThisQuarter('East', UserInfo.getUserId());
    }

    /**
     * Returns Accounts owned by the current user.
     */
    public List<Account> getMyAccounts() {
        return accountSelector.getOwnedByUser(UserInfo.getUserId());
    }
}
