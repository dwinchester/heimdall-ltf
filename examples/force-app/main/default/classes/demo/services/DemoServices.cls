/**
 * Demo composition root for example-specific bindings.
 */
public class DemoServices {
    private static Boolean registered = false;

    public static void registerAll() {
        if (Test.isRunningTest()) {
            return;
        }
        if (registered) {
            return;
        }
        registered = true;

        if (!ServiceRegistry.isRegistered(IAccountSelector.class)) {
            ServiceRegistry.register(IAccountSelector.class, new AccountSelector());
        }
        if (!ServiceRegistry.isRegistered(IOpportunitySelector.class)) {
            ServiceRegistry.register(IOpportunitySelector.class, new OpportunitySelector());
        }
        if (!ServiceRegistry.isRegistered(IAccountRepository.class)) {
            ServiceRegistry.register(
                IAccountRepository.class,
                new AccountRepository(
                    new AccountSelector(),
                    (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class)
                )
            );
        }
        if (!ServiceRegistry.isRegistered(IOpportunityRepository.class)) {
            ServiceRegistry.register(
                IOpportunityRepository.class,
                new OpportunityRepository(
                    new OpportunitySelector(),
                    (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class)
                )
            );
        }
    }
}
