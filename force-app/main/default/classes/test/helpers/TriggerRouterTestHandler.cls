/**
 * Test-only handler used by TriggerRouterTestTrigger.
 */
public class TriggerRouterTestHandler extends TriggerHandler {
    public static Integer beforeInsertCount = 0;
    public static Integer beforeUpdateCount = 0;
    public static Integer beforeDeleteCount = 0;
    public static Integer afterInsertCount = 0;
    public static Integer afterUpdateCount = 0;
    public static Integer afterDeleteCount = 0;
    public static Integer afterUndeleteCount = 0;

    public static void reset() {
        beforeInsertCount = 0;
        beforeUpdateCount = 0;
        beforeDeleteCount = 0;
        afterInsertCount = 0;
        afterUpdateCount = 0;
        afterDeleteCount = 0;
        afterUndeleteCount = 0;
    }

    public override void beforeInsert(List<SObject> newList) {
        beforeInsertCount++;
    }

    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        beforeUpdateCount++;
    }

    public override void beforeDelete(Map<Id, SObject> oldMap) {
        beforeDeleteCount++;
    }

    public override void afterInsert(List<SObject> newList) {
        afterInsertCount++;
    }

    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        afterUpdateCount++;
    }

    public override void afterDelete(Map<Id, SObject> oldMap) {
        afterDeleteCount++;
    }

    public override void afterUndelete(List<SObject> newList) {
        afterUndeleteCount++;
    }
}
