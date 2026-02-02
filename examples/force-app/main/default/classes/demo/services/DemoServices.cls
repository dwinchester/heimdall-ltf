/**
 * Demo composition root for example-specific bindings.
 */
public class DemoServices {
    private static Boolean registered = false;

    public static void registerAll() {
        registerAllInternal(false);
    }

    @TestVisible
    static void registerAllForTest() {
        registerAllInternal(true);
    }

    private static void registerAllInternal(Boolean allowTest) {
        if (Test.isRunningTest() && !allowTest) {
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
        if (!ServiceRegistry.isRegistered(IOpportunityLineItemSelector.class)) {
            ServiceRegistry.register(
                IOpportunityLineItemSelector.class,
                new OpportunityLineItemSelector()
            );
        }
        if (!ServiceRegistry.isRegistered(ITaskSelector.class)) {
            ServiceRegistry.register(ITaskSelector.class, new TaskSelector());
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
        if (!ServiceRegistry.isRegistered(IOpportunityLineItemRepository.class)) {
            ServiceRegistry.register(
                IOpportunityLineItemRepository.class,
                new OpportunityLineItemRepository(
                    new OpportunityLineItemSelector(),
                    (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class)
                )
            );
        }
        if (!ServiceRegistry.isRegistered(ITaskRepository.class)) {
            ServiceRegistry.register(
                ITaskRepository.class,
                new TaskRepository(
                    new TaskSelector(),
                    (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class)
                )
            );
        }
        if (!ServiceRegistry.isRegistered(IRenewalReadinessService.class)) {
            ServiceRegistry.register(
                IRenewalReadinessService.class,
                new RenewalReadinessService(
                    (IOpportunityRepository) ServiceRegistry.resolve(IOpportunityRepository.class),
                    (IOpportunityLineItemRepository) ServiceRegistry.resolve(
                        IOpportunityLineItemRepository.class
                    ),
                    (IAccountRepository) ServiceRegistry.resolve(IAccountRepository.class),
                    (ITaskRepository) ServiceRegistry.resolve(ITaskRepository.class),
                    (IClock) ServiceRegistry.resolve(IClock.class)
                )
            );
        }
    }
}
