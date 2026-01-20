/**
 * Test-only helpers for controlling {@link ServiceRegistry}.
 *
 * Use {@link #registerMock(Type, Object)} to override a binding for a test.
 * Use {@link #reset()} to clear bindings between tests for isolation.
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
    }
}

