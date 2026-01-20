/**
 * Test double for {@link IEventBus} that records published events.
 */
@isTest
public class MockEventBus implements IEventBus {
    public List<SObject> published = new List<SObject>();

    public Database.SaveResult[] publish(List<SObject> eventsToPublish) {
        if (eventsToPublish != null) {
            published.addAll(eventsToPublish);
        }
        return new Database.SaveResult[] {};
    }
}

