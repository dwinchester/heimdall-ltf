/**
 * Repository implementation for Task access.
 *
 * Delegates reads to {@link ITaskSelector} and writes to {@link IRecordMutator}.
 */
public class TaskRepository implements ITaskRepository {
    private final ITaskSelector selector;
    private final IRecordMutator mutator;

    public TaskRepository(ITaskSelector selector, IRecordMutator mutator) {
        this.selector = selector;
        this.mutator = mutator;
    }

    public List<Task> getByOpportunityIds(Set<Id> opportunityIds, String subject) {
        return selector.getByOpportunityIds(opportunityIds, subject);
    }

    public Database.SaveResult[] insertRecords(List<Task> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.insertRecords(toSObjects(records));
    }

    public Database.SaveResult[] updateRecords(List<Task> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.updateRecords(toSObjects(records));
    }

    public Database.DeleteResult[] deleteRecords(List<Task> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        return mutator.deleteRecords(toSObjects(records));
    }

    private static List<SObject> toSObjects(List<Task> records) {
        List<SObject> results = new List<SObject>();
        for (Task record : records) {
            results.add(record);
        }
        return results;
    }
}
