/**
 * Production implementation of {@link IHttpClient} that delegates to {@code Http.send}.
 */
public class HttpClient implements IHttpClient {
    public HttpResponse send(HttpRequest request) {
        Http http = new Http();
        return http.send(request);
    }
}
