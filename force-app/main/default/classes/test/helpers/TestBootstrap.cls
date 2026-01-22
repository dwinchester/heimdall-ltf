/**
 * Drop-in test bootstrap helper for DI defaults with optional strict mode.
 *
 * Usage:
 * - TestBootstrap.defaults(); // reset registry + register default mocks
 * - TestBootstrap.strict();   // reset registry + register strict mocks
 * - TestBootstrap.init(true); // choose strict by flag
 */
@isTest
public class TestBootstrap {
    private static Boolean strictMode = false;

    public static void defaults() {
        strictMode = false;
        TestServiceRegistry.reset();
    }

    public static void strict() {
        strictMode = true;
        TestServiceRegistry.reset();
        TestServiceRegistry.registerMock(IHttpClient.class, new StrictHttpClient());
        TestServiceRegistry.registerMock(IAsyncEnqueuer.class, new StrictAsyncEnqueuer());
        TestServiceRegistry.registerMock(IEventBus.class, new StrictEventBus());
        TestServiceRegistry.registerMock(IRecordMutator.class, new StrictRecordMutator());
    }

    public static void init(Boolean strictMode) {
        setStrictMode(strictMode);
        reset();
    }

    public static void setStrictMode(Boolean strictMode) {
        TestBootstrap.strictMode = strictMode == true;
    }

    public static Boolean isStrictMode() {
        return strictMode;
    }

    public static void reset() {
        if (strictMode) {
            strict();
            return;
        }
        defaults();
    }

    private class StrictHttpClient implements IHttpClient {
        public HttpResponse send(HttpRequest request) {
            throw new TestBootstrapException('HTTP callouts are not allowed in strict mode.');
        }
    }

    private class StrictAsyncEnqueuer implements IAsyncEnqueuer {
        public Id enqueue(Queueable job) {
            throw new TestBootstrapException('Async enqueue is not allowed in strict mode.');
        }
    }

    private class StrictEventBus implements IEventBus {
        public Database.SaveResult[] publish(List<SObject> eventsToPublish) {
            throw new TestBootstrapException('Event publishing is not allowed in strict mode.');
        }
    }

    private class StrictRecordMutator implements IRecordMutator {
        public Database.SaveResult[] insertRecords(List<SObject> recordsToInsert) {
            throw new TestBootstrapException('DML insert is not allowed in strict mode.');
        }

        public Database.SaveResult[] updateRecords(List<SObject> recordsToUpdate) {
            throw new TestBootstrapException('DML update is not allowed in strict mode.');
        }

        public Database.DeleteResult[] deleteRecords(List<SObject> recordsToDelete) {
            throw new TestBootstrapException('DML delete is not allowed in strict mode.');
        }
    }

    public class TestBootstrapException extends Exception {}
}
