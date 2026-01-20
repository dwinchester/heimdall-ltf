/**
 * Abstraction over {@code System.enqueueJob} for queueable scheduling in tests.
 *
 * Production implementation: {@link SystemAsyncEnqueuer}.
 */
public interface IAsyncEnqueuer {
    /**
     * Enqueues a Queueable job.
     *
     * @param job The Queueable to enqueue
     * @return The enqueued job Id (or null if the implementation chooses not to return one)
     */
    Id enqueue(Queueable job);
}

