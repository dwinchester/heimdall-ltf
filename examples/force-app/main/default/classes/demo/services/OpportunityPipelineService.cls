/**
 * Example service that composes Account and Opportunity repositories.
 */
public class OpportunityPipelineService {
    private final IAccountRepository accountRepository;
    private final IOpportunityRepository opportunityRepository;

    public OpportunityPipelineService(
        IAccountRepository accountRepository,
        IOpportunityRepository opportunityRepository
    ) {
        this.accountRepository = accountRepository;
        this.opportunityRepository = opportunityRepository;
    }

    /**
     * Returns Opportunities owned by the current user, closing this quarter, in the East region.
     */
    public List<Opportunity> getMyOpportunitiesClosingThisQuarter() {
        return opportunityRepository.getClosingThisQuarter('East', UserInfo.getUserId());
    }

    /**
     * Returns Accounts owned by the current user.
     */
    public List<Account> getMyAccounts() {
        return accountRepository.getOwnedByUser(UserInfo.getUserId());
    }
}
