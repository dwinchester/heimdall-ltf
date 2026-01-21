/**
 * Abstraction over DML insert/update/delete to allow mocking in tests.
 *
 * Production implementation: {@link SystemRecordMutator}.
 */
public interface IRecordMutator {
    /**
     * Inserts records.
     *
     * @param recordsToInsert Records to insert
     * @return Per-record save results (empty when no records are provided)
     */
    Database.SaveResult[] insertRecords(List<SObject> recordsToInsert);

    /**
     * Updates records.
     *
     * @param recordsToUpdate Records to update
     * @return Per-record save results (empty when no records are provided)
     */
    Database.SaveResult[] updateRecords(List<SObject> recordsToUpdate);

    /**
     * Deletes records.
     *
     * @param recordsToDelete Records to delete
     * @return Per-record delete results (empty when no records are provided)
     */
    Database.DeleteResult[] deleteRecords(List<SObject> recordsToDelete);
}
