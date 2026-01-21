/**
 * Production implementation of {@link IEventBus} that delegates to {@code EventBus.publish}.
 */
public class SystemEventBus implements IEventBus {
    public Database.SaveResult[] publish(List<SObject> eventsToPublish) {
        return EventBus.publish(eventsToPublish);
    }
}
