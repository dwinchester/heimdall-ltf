/**
 * Example integration orchestrator (template).
 *
 * Demonstrates dependency resolution via {@link ServiceRegistry} and usage of:
 * - {@link IHttpClient} for callouts
 * - {@link IAsyncEnqueuer} for queueables
 * - {@link IEventBus} for platform event publishing
 *
 * In real services, validate inputs, handle errors explicitly, and consider retries/timeouts.
 */
public class ExampleIntegrationService {
    private final IHttpClient httpClient;
    private final IAsyncEnqueuer asyncEnqueuer;
    private final IEventBus eventBus;

    public ExampleIntegrationService() {
        this(
            (IHttpClient) ServiceRegistry.resolve(IHttpClient.class),
            (IAsyncEnqueuer) ServiceRegistry.resolve(IAsyncEnqueuer.class),
            (IEventBus) ServiceRegistry.resolve(IEventBus.class)
        );
    }

    public ExampleIntegrationService(
        IHttpClient httpClient,
        IAsyncEnqueuer asyncEnqueuer,
        IEventBus eventBus
    ) {
        this.httpClient = httpClient;
        this.asyncEnqueuer = asyncEnqueuer;
        this.eventBus = eventBus;
    }

    /**
     * Runs the example workflow: callout + enqueue + publish.
     *
     * @param request HTTP request to send
     * @param job Queueable to enqueue
     * @param eventsToPublish Platform events to publish
     * @return A summary of the actions performed
     */
    public ExampleResult runExample(HttpRequest request, Queueable job, List<SObject> eventsToPublish) {
        HttpResponse response = httpClient.send(request);
        Id jobId = asyncEnqueuer.enqueue(job);
        Database.SaveResult[] results = eventBus.publish(eventsToPublish);
        Integer publishedCount = results == null ? 0 : results.size();
        return new ExampleResult(response.getStatusCode(), jobId, publishedCount);
    }

    public class ExampleResult {
        public Integer statusCode;
        public Id jobId;
        public Integer publishedCount;

        /**
         * Result summary for {@link ExampleIntegrationService#runExample(HttpRequest, Queueable, List<SObject>)}.
         */
        public ExampleResult(Integer statusCode, Id jobId, Integer publishedCount) {
            this.statusCode = statusCode;
            this.jobId = jobId;
            this.publishedCount = publishedCount;
        }
    }
}

