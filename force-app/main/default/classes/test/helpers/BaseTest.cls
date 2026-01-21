/**
 * Shared base class for unit/integration tests.
 *
 * Provides:
 * - registry reset helpers (clean DI bindings between tests)
 * - small guardrails to keep tests fast and deterministic
 */
public abstract class BaseTest {
    public static void resetRegistry() {
        TestServiceRegistry.reset();
    }

    public static void assertFastTest() {
        TestLimits.assertFastDefaults();
    }

    public static void assertSlowTest() {
        TestLimits.assertWithin(20, 10, 250);
    }
}
