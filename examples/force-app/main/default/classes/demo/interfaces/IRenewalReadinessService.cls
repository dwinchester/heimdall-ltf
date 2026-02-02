/**
 * Service contract for Renewal Readiness operations.
 */
public interface IRenewalReadinessService {
    /**
     * Recalculate readiness for the provided Opportunities.
     */
    void recalcByOpportunityIds(Set<Id> opportunityIds);

    /**
     * Create review tasks for high-priority renewal Opportunities.
     */
    void createReviewTasksForHighPriority(List<Opportunity> newOpps);

    /**
     * Load a DTO for UI rendering.
     */
    RenewalReadinessDto loadDto(Id opportunityId);

    /**
     * Update line items for UI save.
     */
    void updateLineItems(List<OpportunityLineItem> items);
}
