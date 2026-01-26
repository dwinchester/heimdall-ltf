/**
 * Repository contract for Account data access and persistence.
 *
 * Implementations should delegate reads to {@link IAccountSelector} and writes to {@link IRecordMutator}.
 */
public interface IAccountRepository extends IBaseRepository {
    /**
     * Fetches a single Account by Id.
     *
     * @param accountId Account Id
     * @return Account record
     */
    Account getById(Id accountId);

    /**
     * Fetches Accounts by Id as a map keyed by Id.
     *
     * @param accountIds Set of Account Ids
     * @return Map of Accounts keyed by Id
     */
    Map<Id, Account> getByIds(Set<Id> accountIds);

    /**
     * Fetches Accounts for a given region.
     *
     * Region is modeled by {@code BillingState} in this example.
     *
     * @param region Billing state to filter by
     * @return List of Accounts in the region
     */
    List<Account> getAccountsByRegion(String region);

    /**
     * Fetches Accounts owned by a user.
     *
     * @param ownerId Owner Id to filter by
     * @return List of Accounts owned by the user
     */
    List<Account> getOwnedByUser(Id ownerId);
}
