/**
 * Coverage for TriggerHandler no-op defaults.
 */
@isTest
private class TriggerHandlerTest extends BaseTest {
    private class NoopHandler extends TriggerHandler {}

    @isTest
    static void supportsAllContextsWithData() {
        NoopHandler handler = new NoopHandler();
        Account acc = new Account(Name = 'Trigger Handler Test');
        insert acc;

        List<SObject> newList = new List<SObject>{ acc };
        Map<Id, SObject> oldMap = new Map<Id, SObject>{ acc.Id => acc };

        handler.beforeInsert(newList);
        handler.beforeUpdate(newList, oldMap);
        handler.beforeDelete(oldMap);
        handler.afterInsert(newList);
        handler.afterUpdate(newList, oldMap);
        handler.afterDelete(oldMap);
        handler.afterUndelete(newList);

        assertFastTest();
    }

    @isTest
    static void supportsAllContextsWithEmptyInputs() {
        NoopHandler handler = new NoopHandler();
        List<SObject> emptyList = new List<SObject>();
        Map<Id, SObject> emptyMap = new Map<Id, SObject>();

        handler.beforeInsert(emptyList);
        handler.beforeUpdate(emptyList, emptyMap);
        handler.beforeDelete(emptyMap);
        handler.afterInsert(emptyList);
        handler.afterUpdate(emptyList, emptyMap);
        handler.afterDelete(emptyMap);
        handler.afterUndelete(emptyList);

        assertFastTest();
    }
}
