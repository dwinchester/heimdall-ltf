/**
 * Simple {@link HttpCalloutMock} that returns a deterministic 200 response.
 *
 * Use this in tests that exercise the platform callout mechanism (vs. mocking {@link IHttpClient}).
 */
@isTest
global class BaseHttpCalloutMock implements HttpCalloutMock {
    /**
     * Returns a default empty JSON response.
     */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(200);
        return res;
    }
}

