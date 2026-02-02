/**
 * Repository contract for Task data access and persistence.
 *
 * Implementations should delegate reads to {@link ITaskSelector} and writes to {@link IRecordMutator}.
 */
public interface ITaskRepository extends IBaseRepository {
    /**
     * Fetches Tasks for a set of Opportunities with a specific subject.
     *
     * @param opportunityIds Opportunity Ids to filter by
     * @param subject Task subject to filter by
     * @return List of Tasks
     */
    List<Task> getByOpportunityIds(Set<Id> opportunityIds, String subject);
}
