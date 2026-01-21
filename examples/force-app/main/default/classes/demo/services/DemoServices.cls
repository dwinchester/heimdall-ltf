/**
 * Demo composition root for example-specific bindings.
 */
public class DemoServices {
    private static Boolean registered = false;

    public static void registerAll() {
        if (registered) {
            return;
        }
        registered = true;

        if (!ServiceRegistry.isRegistered(IAccountSelector.class)) {
            ServiceRegistry.register(IAccountSelector.class, new AccountSelector());
        }
    }
}
