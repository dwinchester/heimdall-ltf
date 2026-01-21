/**
 * Test double for {@link IRecordMutator} that records mutations.
 */
@isTest
public class MockRecordMutator implements IRecordMutator {
    public Integer insertCount = 0;
    public Integer updateCount = 0;
    public Integer deleteCount = 0;
    public List<SObject> inserted = new List<SObject>();
    public List<SObject> updated = new List<SObject>();
    public List<SObject> deleted = new List<SObject>();

    public Database.SaveResult[] insertRecords(List<SObject> recordsToInsert) {
        insertCount++;
        if (recordsToInsert != null) {
            inserted.addAll(recordsToInsert);
        }
        return new Database.SaveResult[] {};
    }

    public Database.SaveResult[] updateRecords(List<SObject> recordsToUpdate) {
        updateCount++;
        if (recordsToUpdate != null) {
            updated.addAll(recordsToUpdate);
        }
        return new Database.SaveResult[] {};
    }

    public Database.DeleteResult[] deleteRecords(List<SObject> recordsToDelete) {
        deleteCount++;
        if (recordsToDelete != null) {
            deleted.addAll(recordsToDelete);
        }
        return new Database.DeleteResult[] {};
    }
}
