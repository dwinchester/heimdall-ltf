/**
 * Data access contract for Opportunity queries.
 *
 * Implementations should be bulk-safe and clearly document null/exception behavior.
 * Production implementation: {@link OpportunitySelector}.
 */
public interface IOpportunitySelector {
    /**
     * Fetches Opportunities for a given Account.
     *
     * @param accountId Account Id
     * @return List of Opportunities for the Account
     */
    List<Opportunity> getByAccountId(Id accountId);

    /**
     * Fetches counts and total amount of Opportunities for a region.
     *
     * Region is modeled by {@code Account.BillingState} in this example.
     *
     * @param region Billing state to filter by
     * @return Aggregate results containing count and total amount
     */
    List<AggregateResult> getCountsAndAmountsByRegion(String region);

    /**
     * Fetches Opportunities owned by a user, closing this quarter, in a region.
     *
     * Region is modeled by {@code Account.BillingState} in this example.
     *
     * @param region Billing state to filter by
     * @param ownerId Owner Id to filter by
     * @return List of Opportunities matching the criteria
     */
    List<Opportunity> getClosingThisQuarter(String region, Id ownerId);
}
