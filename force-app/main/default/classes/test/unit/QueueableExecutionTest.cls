/**
 * Unit test that demonstrates queueable execution via {@code Test.startTest/stopTest}.
 *
 * Note: enqueue within {@code startTest()} so {@code stopTest()} flushes async execution and lets
 * us assert on side effects.
 */
@isTest
private class QueueableExecutionTest extends BaseTest {
    @isTest
    static void testQueueableExecution() {
        resetRegistry();
        MockQueueable mockJob = new MockQueueable();
        Test.startTest();
        Id jobId = System.enqueueJob(mockJob);
        Test.stopTest();
        AsyncApexJob job = [
            SELECT Status, JobType, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];
        System.assertEquals('Queueable', job.JobType);
        System.assertEquals('Completed', job.Status);
        System.assertEquals(0, job.NumberOfErrors);
        assertSlowTest();
    }
}

