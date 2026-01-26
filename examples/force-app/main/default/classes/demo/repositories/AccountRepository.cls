/**
 * Repository implementation for Account access.
 *
 * Delegates reads to {@link IAccountSelector} and writes to {@link IRecordMutator}.
 */
public class AccountRepository implements IAccountRepository {
    private final IAccountSelector selector;
    private final IRecordMutator mutator;

    public AccountRepository(IAccountSelector selector, IRecordMutator mutator) {
        this.selector = selector;
        this.mutator = mutator;
    }

    public Account getById(Id accountId) {
        return selector.getById(accountId);
    }

    public Map<Id, Account> getByIds(Set<Id> accountIds) {
        return selector.getByIds(accountIds);
    }

    public List<Account> getAccountsByRegion(String region) {
        return selector.getAccountsByRegion(region);
    }

    public List<Account> getOwnedByUser(Id ownerId) {
        return selector.getOwnedByUser(ownerId);
    }

    public Database.SaveResult[] insertRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.insertRecords(toSObjects(records));
    }

    public Database.SaveResult[] updateRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.updateRecords(toSObjects(records));
    }

    public Database.DeleteResult[] deleteRecords(List<Account> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        return mutator.deleteRecords(toSObjects(records));
    }

    private static List<SObject> toSObjects(List<Account> records) {
        List<SObject> results = new List<SObject>();
        for (Account record : records) {
            results.add(record);
        }
        return results;
    }
}
