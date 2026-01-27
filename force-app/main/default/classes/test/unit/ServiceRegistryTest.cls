/**
 * Unit tests for {@link ServiceRegistry} and {@link ProductionServices}.
 */
@isTest
private class ServiceRegistryTest extends BaseTest {
    private interface UnregisteredService {}
    @isTest
    static void registerAndResolveReturnsInstance() {
        ServiceRegistry.reset();
        MockHttpClient mock = new MockHttpClient();
        ServiceRegistry.register(IHttpClient.class, mock);

        IHttpClient resolved = (IHttpClient) ServiceRegistry.resolve(IHttpClient.class);
        System.assertEquals(mock, resolved);
        System.assert(ServiceRegistry.isRegistered(IHttpClient.class));
        assertFastTest();
    }

    @isTest
    static void resolveThrowsWhenMissingInTests() {
        ServiceRegistry.reset();
        try {
            ServiceRegistry.resolve(IClock.class);
            System.assert(false, 'Expected ServiceException for missing registration.');
        } catch (ServiceRegistry.ServiceException ex) {
            System.assert(ex.getMessage().contains('No service registered'));
        }
        assertFastTest();
    }

    @isTest
    static void productionServicesRegisterDefaults() {
        ServiceRegistry.reset();
        ProductionServices.registerAll();

        System.assert(ServiceRegistry.isRegistered(IClock.class));
        System.assert(ServiceRegistry.resolve(IClock.class) instanceof SystemClock);
        System.assert(ServiceRegistry.resolve(IHttpClient.class) instanceof HttpClient);
        System.assert(ServiceRegistry.resolve(IAsyncEnqueuer.class) instanceof SystemAsyncEnqueuer);
        System.assert(ServiceRegistry.resolve(IEventBus.class) instanceof SystemEventBus);
        System.assert(ServiceRegistry.resolve(IRecordMutator.class) instanceof SystemRecordMutator);
        System.assert(ServiceRegistry.resolve(IQueueableJob.class) instanceof NoopQueueableJob);
        assertFastTest();
    }

    @isTest
    static void resolveBootstrapsInTestsWhenEnabled() {
        ServiceRegistry.reset();
        ServiceRegistry.allowTestBootstrap = true;

        System.assert(ServiceRegistry.resolve(IClock.class) instanceof SystemClock);
        System.assert(ServiceRegistry.isRegistered(IHttpClient.class));
        System.assert(ServiceRegistry.isRegistered(IQueueableJob.class));
        assertFastTest();
    }

    @isTest
    static void resolveThrowsAfterBootstrapWhenMissing() {
        ServiceRegistry.reset();
        ServiceRegistry.allowTestBootstrap = true;
        try {
            ServiceRegistry.resolve(UnregisteredService.class);
            System.assert(false, 'Expected ServiceException for missing registration after bootstrap.');
        } catch (ServiceRegistry.ServiceException ex) {
            System.assert(ex.getMessage().contains('Bind an implementation'));
        }
        assertFastTest();
    }
}
