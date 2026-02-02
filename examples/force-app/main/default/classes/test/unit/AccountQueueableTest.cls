/**
 * Unit tests for AccountQueueable.
 */
@isTest
private class AccountQueueableTest extends BaseTest {
    @isTest
    static void executesSynchronously() {
        AccountQueueable job = new AccountQueueable();
        job.execute();
        assertFastTest();
    }

    @isTest
    static void executesWithQueueableContext() {
        AccountQueueable job = new AccountQueueable();
        job.execute(null);
        assertFastTest();
    }
}
