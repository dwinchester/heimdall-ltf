/**
 * Repository contract for Opportunity data access and persistence.
 *
 * Implementations should delegate reads to {@link IOpportunitySelector} and writes to {@link IRecordMutator}.
 */
public interface IOpportunityRepository extends IBaseRepository {
    /**
     * Fetches a single Opportunity by Id.
     *
     * @param opportunityId Opportunity Id
     * @return Opportunity record
     */
    Opportunity getById(Id opportunityId);

    /**
     * Fetches Opportunities by Id as a map keyed by Id.
     *
     * @param opportunityIds Set of Opportunity Ids
     * @return Map of Opportunities keyed by Id
     */
    Map<Id, Opportunity> getByIds(Set<Id> opportunityIds);

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
