/**
 * Production implementation of {@link IAsyncEnqueuer} that delegates to {@code System.enqueueJob}.
 */
public class SystemAsyncEnqueuer implements IAsyncEnqueuer {
    public Id enqueue(Queueable job) {
        return System.enqueueJob(job);
    }
}

