/**
 * Abstraction over {@code Http.send} to enable deterministic unit tests.
 *
 * Production implementation: {@link HttpClient}.
 */
public interface IHttpClient {
    /**
     * Sends an HTTP request.
     *
     * @param request Request to send (must be fully configured by caller)
     * @return The HTTP response
     */
    HttpResponse send(HttpRequest request);
}

