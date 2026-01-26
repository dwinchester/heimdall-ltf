/**
 * Base repository contract for common persistence operations.
 *
 * Read methods are defined per-object in repository interfaces.
 */
public interface IBaseRepository {
    /**
     * Inserts the provided records using the configured mutator.
     */
    Database.SaveResult[] insertRecords(List<SObject> records);

    /**
     * Updates the provided records using the configured mutator.
     */
    Database.SaveResult[] updateRecords(List<SObject> records);

    /**
     * Deletes the provided records using the configured mutator.
     */
    Database.DeleteResult[] deleteRecords(List<SObject> records);
}
