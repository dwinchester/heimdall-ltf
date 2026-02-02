/**
 * Repository contract for OpportunityLineItem data access and persistence.
 *
 * Implementations should delegate reads to {@link IOpportunityLineItemSelector} and writes to
 * {@link IRecordMutator}.
 */
public interface IOpportunityLineItemRepository extends IBaseRepository {
    /**
     * Fetches line items for a set of Opportunities.
     *
     * @param opportunityIds Opportunity Ids to filter by
     * @return List of OpportunityLineItems
     */
    List<OpportunityLineItem> getByOpportunityIds(Set<Id> opportunityIds);
}
