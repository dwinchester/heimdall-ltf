/**
 * Data access contract for OpportunityLineItem queries.
 *
 * Implementations should be bulk-safe and clearly document null/exception behavior.
 * Production implementation: {@link OpportunityLineItemSelector}.
 */
public interface IOpportunityLineItemSelector {
    /**
     * Fetches line items for a set of Opportunities.
     *
     * @param opportunityIds Opportunity Ids to filter by
     * @return List of OpportunityLineItems
     */
    List<OpportunityLineItem> getByOpportunityIds(Set<Id> opportunityIds);
}
