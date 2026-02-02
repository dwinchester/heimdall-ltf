/**
 * Data access contract for Task queries.
 *
 * Implementations should be bulk-safe and clearly document null/exception behavior.
 * Production implementation: {@link TaskSelector}.
 */
public interface ITaskSelector {
    /**
     * Fetches Tasks for a set of Opportunities with a specific subject.
     *
     * @param opportunityIds Opportunity Ids to filter by
     * @param subject Task subject to filter by
     * @return List of Tasks
     */
    List<Task> getByOpportunityIds(Set<Id> opportunityIds, String subject);
}
