/**
 * Account trigger domain logic (template example).
 *
 * Demonstrates:
 * - Dependency resolution via {@link ServiceRegistry} (selector + mutator)
 * - Bulk-safe shaping of data (collect Ids, query once, update as a list)
 *
 * Caution:
 * - This example performs DML in an {@code afterInsert} trigger. In real implementations you may
 *   need recursion protection / idempotency to prevent re-entry.
 *
 * @see TriggerRouter
 * @see ServiceRegistry
 * @see IAccountSelector
 * @see IRecordMutator
 */
public class AccountTriggerHandler extends TriggerHandler {
    private final IAccountSelector selector;
    private final IRecordMutator recordMutator;

    public AccountTriggerHandler() {
        DemoServices.registerAll();
        this.selector = (IAccountSelector) ServiceRegistry.resolve(IAccountSelector.class);
        this.recordMutator = (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class);
    }

    public override void afterInsert(List<SObject> newList) {
        if (newList == null || newList.isEmpty()) {
            return;
        }

        List<Account> newAccounts = new List<Account>();
        for (SObject record : newList) {
            if (record instanceof Account) {
                newAccounts.add((Account) record);
            }
        }
        if (newAccounts.isEmpty()) {
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

        recordMutator.updateRecords(updates);
    }
}
