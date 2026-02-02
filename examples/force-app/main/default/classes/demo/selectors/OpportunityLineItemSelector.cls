/**
 * SOQL-based OpportunityLineItem data access implementation.
 *
 * @see IOpportunityLineItemSelector
 */
public class OpportunityLineItemSelector implements IOpportunityLineItemSelector {
    /**
     * Fetches line items for a set of Opportunities.
     *
     * Returns an empty list when {@code opportunityIds} is null/empty.
     */
    public List<OpportunityLineItem> getByOpportunityIds(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new List<OpportunityLineItem>();
        }

        return [
            SELECT Id, OpportunityId, Quantity, TotalPrice,
                Confirmed__c, RiskFlag__c, RiskReason__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opportunityIds
        ];
    }
}
