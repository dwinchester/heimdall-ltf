/**
 * Default no-op implementation of {@link IQueueableJob}.
 *
 * Useful as a safe placeholder binding in templates/tests.
 */
public class NoopQueueableJob implements IQueueableJob {
    public void execute() {
        // Intentionally empty default implementation.
    }
}

