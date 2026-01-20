/**
 * Account trigger domain logic (template example).
 *
 * Demonstrates:
 * - Dependency resolution via {@link ServiceRegistry} (selector lookup)
 * - Bulk-safe shaping of data (collect Ids, query once, update as a list)
 *
 * Caution:
 * - This example performs DML in an {@code afterInsert} trigger. In real implementations you may
 *   need recursion protection / idempotency to prevent re-entry.
 *
 * @see TriggerRouter
 * @see ServiceRegistry
 * @see IAccountSelector
 */
public class AccountTriggerHandler extends TriggerHandler {
    private final IAccountSelector selector;

    public AccountTriggerHandler() {
        this.selector = (IAccountSelector) ServiceRegistry.resolve(IAccountSelector.class);
    }

    public override void afterInsert(List<SObject> newList) {
        List<Account> newAccounts = (List<Account>) newList;
        if (newAccounts == null || newAccounts.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newAccounts) {
            accountIds.add(acc.Id);
        }

        Map<Id, Account> fullAccounts = selector.getByIds(accountIds);
        List<Account> updates = new List<Account>();
        for (Account acc : newAccounts) {
            Account fullAcc = fullAccounts.get(acc.Id);
            updates.add(new Account(
                Id = acc.Id,
                Description = 'Processed: ' + (fullAcc == null ? '' : fullAcc.Name)
            ));
        }

        update updates;
    }
}

