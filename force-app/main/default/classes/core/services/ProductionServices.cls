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
        // Platform services
        ServiceRegistry.register(IClock.class, new SystemClock());
        ServiceRegistry.register(IHttpClient.class, new HttpClient());
        ServiceRegistry.register(IAsyncEnqueuer.class, new SystemAsyncEnqueuer());
        ServiceRegistry.register(IEventBus.class, new SystemEventBus());
        ServiceRegistry.register(IRecordMutator.class, new SystemRecordMutator());

        // Async
        ServiceRegistry.register(IQueueableJob.class, new NoopQueueableJob());
    }
}

