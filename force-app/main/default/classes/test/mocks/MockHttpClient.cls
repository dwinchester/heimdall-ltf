/**
 * Test double for {@link IHttpClient} that returns a deterministic 200 response.
 *
 * Use this when you want to avoid callout mocks and keep tests focused on orchestration logic.
 */
@isTest
public class MockHttpClient implements IHttpClient {
    /**
     * Returns a fixed "mock" response payload.
     */
    public HttpResponse send(HttpRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"mock":true}');
        res.setStatusCode(200);
        return res;
    }
}

