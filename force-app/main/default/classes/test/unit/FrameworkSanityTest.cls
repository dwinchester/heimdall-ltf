/**
 * Baseline sanity checks for the core framework wiring.
 */
@isTest
private class FrameworkSanityTest extends BaseTest {
    @isTest
    static void registryDefaultsAreResolvable() {
        TestServiceRegistry.reset();

        System.assertNotEquals(null, ServiceRegistry.resolve(IClock.class));
        System.assertNotEquals(null, ServiceRegistry.resolve(IHttpClient.class));
        System.assertNotEquals(null, ServiceRegistry.resolve(IAsyncEnqueuer.class));
        System.assertNotEquals(null, ServiceRegistry.resolve(IEventBus.class));
        System.assertNotEquals(null, ServiceRegistry.resolve(IRecordMutator.class));
        assertFastTest();
    }

    @isTest
    static void baseTestHelpersWork() {
        resetRegistry();
        assertFastTest();
    }
}
