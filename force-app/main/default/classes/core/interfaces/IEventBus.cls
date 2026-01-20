/**
 * Abstraction over {@code EventBus.publish} to allow mocking event publishing in tests.
 *
 * Production implementation: {@link SystemEventBus}.
 */
public interface IEventBus {
    /**
     * Publishes platform events.
     *
     * @param eventsToPublish List of platform event sObjects
     * @return Per-record publish results
     */
    Database.SaveResult[] publish(List<SObject> eventsToPublish);
}

