/**
 * Production DML implementation for {@link IRecordMutator}.
 */
public class SystemRecordMutator implements IRecordMutator {
    public Database.SaveResult[] insertRecords(List<SObject> recordsToInsert) {
        if (recordsToInsert == null || recordsToInsert.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return Database.insert(recordsToInsert, true);
    }

    public Database.SaveResult[] updateRecords(List<SObject> recordsToUpdate) {
        if (recordsToUpdate == null || recordsToUpdate.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return Database.update(recordsToUpdate, true);
    }

    public Database.DeleteResult[] deleteRecords(List<SObject> recordsToDelete) {
        if (recordsToDelete == null || recordsToDelete.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        return Database.delete(recordsToDelete, true);
    }
}
