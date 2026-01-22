/**
 * Coverage for TriggerRouter routing logic.
 */
@isTest
private class TriggerRouterTest extends BaseTest {
    @isTest
    static void routesAllTriggerContexts() {
        TriggerRouterTestHandler.reset();
        Account acc = new Account(Name = 'Router Test');
        insert acc;

        acc.Name = 'Router Updated';
        update acc;

        delete acc;
        undelete acc;

        System.assertEquals(1, TriggerRouterTestHandler.beforeInsertCount);
        System.assertEquals(1, TriggerRouterTestHandler.afterInsertCount);
        System.assertEquals(1, TriggerRouterTestHandler.beforeUpdateCount);
        System.assertEquals(1, TriggerRouterTestHandler.afterUpdateCount);
        System.assertEquals(1, TriggerRouterTestHandler.beforeDeleteCount);
        System.assertEquals(1, TriggerRouterTestHandler.afterDeleteCount);
        System.assertEquals(1, TriggerRouterTestHandler.afterUndeleteCount);
        assertSlowTest();
    }

    @isTest
    static void runNoopsOnNullHandler() {
        TriggerRouter.run(null);
        assertFastTest();
    }
}
