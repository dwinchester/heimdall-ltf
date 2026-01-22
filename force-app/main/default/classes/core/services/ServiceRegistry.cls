/**
 * Simple service locator / dependency registry for this org.
 *
 * Use {@link #register(Type, Object)} to bind an interface Type to an implementation instance.
 * Use {@link #resolve(Type)} to retrieve the bound instance.
 *
 * Bootstrap:
 * - Resolution lazily calls {@link ProductionServices#registerAll()} once per transaction,
 *   so callers (e.g., triggers) don't need an explicit init step.
 *
 * Testing:
 * - Tests should call {@link TestServiceRegistry#reset()} to clear bindings, then register mocks.
 *
 * @throws ServiceRegistry.ServiceException if no service is registered for the requested Type
 * @see ProductionServices
 * @see TestServiceRegistry
 */
public class ServiceRegistry {
    private static Map<Type, Object> services = new Map<Type, Object>();
    private static Boolean bootstrapped = false;

    public static void register(Type iface, Object impl) {
        services.put(iface, impl);
    }

    public static Boolean isRegistered(Type iface) {
        return services.containsKey(iface);
    }

    public static Object resolve(Type iface) {
        if (services.containsKey(iface)) {
            return services.get(iface);
        }

        if (Test.isRunningTest()) {
            throw new ServiceException(
                'No service registered for ' + String.valueOf(iface) +
                '. Tests should call TestServiceRegistry.reset() or register a mock before resolving.'
            );
        }

        // Lazy bootstrap so callers (like triggers) don't need an explicit init call.
        if (!bootstrapped) {
            bootstrapped = true;
            ProductionServices.registerAll();
        }

        if (services.containsKey(iface)) {
            return services.get(iface);
        }

        throw new ServiceException(
            'No service registered for ' + String.valueOf(iface) +
            '. Bind an implementation in ProductionServices.registerAll() or register manually.'
        );
    }

    @TestVisible
    static void reset() {
        services.clear();
        bootstrapped = false;
    }

    public class ServiceException extends Exception {}
}

