/**
 * SOQL-based Account data access implementation.
 *
 * @see IAccountSelector
 */
public class AccountSelector implements IAccountSelector {
    /**
     * Fetches a single Account by Id.
     *
     * Note: current implementation uses a single-row SOQL query, which throws if the record
     * does not exist. If you prefer "null when not found", change the implementation accordingly.
     */
    public Account getById(Id accountId) {
        return [
            SELECT Id, Name, Description
            FROM Account
            WHERE Id = :accountId
        ];
    }

    /**
     * Fetches Accounts by Id as a map keyed by Id.
     *
     * Returns an empty map when {@code accountIds} is null/empty.
     */
    public Map<Id, Account> getByIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new Map<Id, Account>();
        }

        return new Map<Id, Account>([
            SELECT Id, Name, Description
            FROM Account
            WHERE Id IN :accountIds
        ]);
    }

    /**
     * Fetches Accounts for a given region.
     *
     * Region is modeled by {@code BillingState} in this example.
     * Returns an empty list when {@code region} is blank.
     */
    public List<Account> getAccountsByRegion(String region) {
        if (String.isBlank(region)) {
            return new List<Account>();
        }

        return [
            SELECT Id, Name, Description, BillingState
            FROM Account
            WHERE BillingState = :region
        ];
    }
}
