/**
 * SOQL-based Task data access implementation.
 *
 * @see ITaskSelector
 */
public class TaskSelector implements ITaskSelector {
    /**
     * Fetches Tasks for a set of Opportunities with a specific subject.
     *
     * Returns an empty list when {@code opportunityIds} is null/empty or subject is blank.
     */
    public List<Task> getByOpportunityIds(Set<Id> opportunityIds, String subject) {
        if (opportunityIds == null || opportunityIds.isEmpty() || String.isBlank(subject)) {
            return new List<Task>();
        }

        return [
            SELECT Id, Subject, Status, Priority, WhatId
            FROM Task
            WHERE WhatId IN :opportunityIds
            AND Subject = :subject
            AND Status != 'Completed'
        ];
    }
}
