/**
 * Unit test for {@link ExampleIntegrationService} showing the intended DI usage pattern.
 *
 * Binds mocks into {@link ServiceRegistry} and asserts orchestration behavior without real callouts,
 * async execution, or event publishing.
 */
@isTest
private class ExampleIntegrationServiceTest extends BaseTest {
    @isTest
    static void endToEndUsagePattern() {
        resetRegistry();

        MockHttpClient httpClient = new MockHttpClient();
        MockAsyncEnqueuer asyncEnqueuer = new MockAsyncEnqueuer();
        MockEventBus eventBus = new MockEventBus();

        TestServiceRegistry.registerMock(IHttpClient.class, httpClient);
        TestServiceRegistry.registerMock(IAsyncEnqueuer.class, asyncEnqueuer);
        TestServiceRegistry.registerMock(IEventBus.class, eventBus);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');

        ExampleIntegrationService svc = new ExampleIntegrationService();
        ExampleIntegrationService.ExampleResult result = svc.runExample(
            req,
            new AccountQueueable(),
            new List<SObject> { new Account(Name = 'Test') }
        );

        System.assertEquals(200, result.statusCode);
        System.assertEquals(1, asyncEnqueuer.enqueueCount);
        System.assertEquals(1, eventBus.published.size());
        assertFastTest();
    }
}

