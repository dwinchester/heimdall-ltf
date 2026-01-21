/**
 * Data access contract for Account queries.
 *
 * Implementations should be bulk-safe and clearly document null/exception behavior.
 * Production implementation: {@link AccountSelector}.
 */
public interface IAccountSelector {
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
}
