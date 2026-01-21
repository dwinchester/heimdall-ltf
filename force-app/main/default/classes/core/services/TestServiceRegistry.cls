/**
 * Test-only helpers for controlling {@link ServiceRegistry}.
 *
 * Use {@link #registerMock(Type, Object)} to override a binding for a test.
 * Use {@link #reset()} to clear bindings between tests for isolation.
 * Use {@link #registerDefaults()} to install safe, DML-less defaults.
 *
 * @see ServiceRegistry
 */
@isTest
public class TestServiceRegistry {
    public static void registerMock(Type iface, Object mock) {
        ServiceRegistry.register(iface, mock);
    }

    public static void reset() {
        ServiceRegistry.reset();
        registerDefaults();
    }

    /**
     * Registers deterministic, DML-less defaults for tests.
     *
     * Call this after {@link #reset()} if you want to ensure no production services are used.
     */
    public static void registerDefaults() {
        ServiceRegistry.register(IClock.class, new SystemClock());
        ServiceRegistry.register(IHttpClient.class, new MockHttpClient());
        ServiceRegistry.register(IAsyncEnqueuer.class, new MockAsyncEnqueuer());
        ServiceRegistry.register(IEventBus.class, new MockEventBus());
        ServiceRegistry.register(IRecordMutator.class, new MockRecordMutator());
    }
}

