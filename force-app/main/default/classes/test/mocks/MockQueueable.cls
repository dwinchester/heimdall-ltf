/**
 * Test double for queueable execution.
 *
 * Implements both {@link Queueable} and {@link IQueueableJob} so tests can validate behavior
 * in both "async" and direct invocation scenarios.
 */
@isTest
public class MockQueueable implements Queueable, IQueueableJob {
    public Boolean executed = false;

    public void execute(QueueableContext context) {
        execute();
    }

    public void execute() {
        executed = true;
    }
}

