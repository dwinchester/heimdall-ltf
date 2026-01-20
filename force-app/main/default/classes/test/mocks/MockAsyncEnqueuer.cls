/**
 * Test double for {@link IAsyncEnqueuer} that records enqueued jobs.
 *
 * Useful for asserting that orchestration code attempted to enqueue work without actually
 * starting async execution.
 */
@isTest
public class MockAsyncEnqueuer implements IAsyncEnqueuer {
    public Integer enqueueCount = 0;
    public Queueable lastJob;

    public Id enqueue(Queueable job) {
        enqueueCount++;
        lastJob = job;
        return null;
    }
}

