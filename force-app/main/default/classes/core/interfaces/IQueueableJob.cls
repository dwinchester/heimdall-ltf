/**
 * Adapter interface for queueable work that can be executed without a QueueableContext.
 *
 * Useful for:
 * - unit testing queueable logic without enqueuing jobs
 * - invoking the same business logic synchronously when appropriate
 *
 * @see AccountQueueable
 * @see NoopQueueableJob
 */
public interface IQueueableJob {
    /**
     * Runs the unit of work.
     */
    void execute();
}

