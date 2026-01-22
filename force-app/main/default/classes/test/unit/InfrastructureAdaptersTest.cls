/**
 * Unit tests for platform adapter classes.
 */
@isTest
private class InfrastructureAdaptersTest extends BaseTest {
    @isTest
    static void systemClockReturnsNow() {
        SystemClock clock = new SystemClock();
        System.assertNotEquals(null, clock.now());
        assertFastTest();
    }

    @isTest
    static void httpClientUsesHttpSend() {
        Test.setMock(HttpCalloutMock.class, new BaseHttpCalloutMock());
        HttpClient client = new HttpClient();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');
        HttpResponse res = client.send(req);
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{}', res.getBody());
        assertSlowTest();
    }

    @isTest
    static void systemAsyncEnqueuerEnqueuesJob() {
        SystemAsyncEnqueuer enqueuer = new SystemAsyncEnqueuer();
        MockQueueable job = new MockQueueable();
        Test.startTest();
        Id jobId = enqueuer.enqueue(job);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
        assertSlowTest();
    }

    @isTest
    static void systemEventBusPublishesEmptyList() {
        SystemEventBus eventBus = new SystemEventBus();
        Database.SaveResult[] results = eventBus.publish(new List<SObject>());
        System.assertEquals(0, results.size());
        assertFastTest();
    }

    @isTest
    static void noopQueueableJobNoops() {
        NoopQueueableJob job = new NoopQueueableJob();
        job.execute();
        assertFastTest();
    }
}
