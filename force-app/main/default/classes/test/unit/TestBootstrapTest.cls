/**
 * Unit tests for {@link TestBootstrap}.
 */
@isTest
private class TestBootstrapTest extends BaseTest {
    @isTest
    static void defaultsRegistersMocks() {
        TestBootstrap.defaults();

        IHttpClient httpClient = (IHttpClient) ServiceRegistry.resolve(IHttpClient.class);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://example.com');
        request.setMethod('GET');
        HttpResponse response = httpClient.send(request);
        System.assertEquals(200, response.getStatusCode());

        IAsyncEnqueuer enqueuer = (IAsyncEnqueuer) ServiceRegistry.resolve(IAsyncEnqueuer.class);
        MockQueueable queueable = new MockQueueable();
        enqueuer.enqueue(queueable);
        System.assertEquals(1, ((MockAsyncEnqueuer) enqueuer).enqueueCount);

        IEventBus eventBus = (IEventBus) ServiceRegistry.resolve(IEventBus.class);
        eventBus.publish(new List<SObject>{ new Account(Name = 'Test') });
        System.assertEquals(1, ((MockEventBus) eventBus).published.size());
        assertFastTest();
    }

    @isTest
    static void strictModeThrowsOnPlatformDependencies() {
        TestBootstrap.strict();

        IHttpClient httpClient = (IHttpClient) ServiceRegistry.resolve(IHttpClient.class);
        try {
            httpClient.send(new HttpRequest());
            System.assert(false, 'Expected strict mode to throw for HTTP callouts.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('HTTP callouts'));
        }

        IAsyncEnqueuer enqueuer = (IAsyncEnqueuer) ServiceRegistry.resolve(IAsyncEnqueuer.class);
        try {
            enqueuer.enqueue(new MockQueueable());
            System.assert(false, 'Expected strict mode to throw for async enqueue.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('Async enqueue'));
        }

        IEventBus eventBus = (IEventBus) ServiceRegistry.resolve(IEventBus.class);
        try {
            eventBus.publish(new List<SObject>());
            System.assert(false, 'Expected strict mode to throw for event publish.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('Event publishing'));
        }

        IRecordMutator mutator = (IRecordMutator) ServiceRegistry.resolve(IRecordMutator.class);
        try {
            mutator.insertRecords(new List<SObject>());
            System.assert(false, 'Expected strict mode to throw for DML insert.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('DML insert'));
        }

        try {
            mutator.updateRecords(new List<SObject>());
            System.assert(false, 'Expected strict mode to throw for DML update.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('DML update'));
        }

        try {
            mutator.deleteRecords(new List<SObject>());
            System.assert(false, 'Expected strict mode to throw for DML delete.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('DML delete'));
        }

        assertFastTest();
    }

    @isTest
    static void toggleAndInitControlsStrictness() {
        TestBootstrap.setStrictMode(true);
        System.assertEquals(true, TestBootstrap.isStrictMode());
        TestBootstrap.reset();

        IHttpClient httpClient = (IHttpClient) ServiceRegistry.resolve(IHttpClient.class);
        try {
            httpClient.send(new HttpRequest());
            System.assert(false, 'Expected strict mode to throw after reset.');
        } catch (TestBootstrap.TestBootstrapException ex) {
            System.assert(ex.getMessage().contains('HTTP callouts'));
        }

        TestBootstrap.init(false);
        System.assertEquals(false, TestBootstrap.isStrictMode());
        IHttpClient permissiveClient = (IHttpClient) ServiceRegistry.resolve(IHttpClient.class);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://example.com');
        request.setMethod('GET');
        HttpResponse response = permissiveClient.send(request);
        System.assertEquals(200, response.getStatusCode());
        assertFastTest();
    }
}
