/**
 * Template Queueable implementation.
 *
 * Implements {@link IQueueableJob} so the same work can be unit tested synchronously via
 * {@link #execute()} while still supporting asynchronous execution via {@link #execute(QueueableContext)}.
 */
public class AccountQueueable implements Queueable, IQueueableJob {
    /**
     * Queueable entrypoint.
     *
     * Delegates to {@link #execute()} so core work can be tested without a QueueableContext.
     */
    public void execute(QueueableContext context) {
        execute();
    }

    /**
     * Runs the unit of work (template placeholder).
     */
    public void execute() {
        // Example async job. Keep empty for template purposes.
    }
}
