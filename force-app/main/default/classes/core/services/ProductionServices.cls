/**
 * Composition root for production bindings.
 *
 * Central place to declare which concrete classes back each interface in {@link ServiceRegistry}.
 * Add new services here when introducing new interfaces/implementations.
 *
 * @see ServiceRegistry
 */
public class ProductionServices {
    public static void registerAll() {
        // Selectors
        ServiceRegistry.register(IAccountSelector.class, new AccountSelector());

        // Platform services
        ServiceRegistry.register(IClock.class, new SystemClock());
        ServiceRegistry.register(IHttpClient.class, new HttpClient());
        ServiceRegistry.register(IAsyncEnqueuer.class, new SystemAsyncEnqueuer());
        ServiceRegistry.register(IEventBus.class, new SystemEventBus());

        // Async
        ServiceRegistry.register(IQueueableJob.class, new AccountQueueable());
    }
}

