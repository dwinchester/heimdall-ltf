/**
 * Unit test illustrating platform HTTP callout mocking via {@link HttpCalloutMock}.
 *
 * This test exercises the {@code Http.send} path directly (as opposed to mocking {@link IHttpClient}).
 */
@isTest
private class HttpCalloutMockTest extends BaseTest {
    @isTest
    static void testCallout() {
        resetRegistry();
        Test.setMock(HttpCalloutMock.class, new BaseHttpCalloutMock());

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');

        HttpResponse res = http.send(req);
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{}', res.getBody());
        assertSlowTest();
    }
}

