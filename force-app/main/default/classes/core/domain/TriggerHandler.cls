/**
 * Base class for trigger handlers routed by {@link TriggerRouter}.
 *
 * Implement only the trigger-context methods you need (e.g., {@link #afterInsert}).
 * Keep implementations bulk-safe (operate on collections, avoid SOQL/DML in loops).
 *
 * Notes:
 * - This framework does NOT provide recursion control, idempotency, or ordering. Add those concerns
 *   in your concrete handler when needed.
 * - Parameters mirror Salesforce trigger context variables (e.g., Trigger.new, Trigger.oldMap).
 *
 * @see TriggerRouter
 */
public abstract class TriggerHandler {
    public virtual void beforeInsert(List<SObject> newList) {}
    public virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void beforeDelete(Map<Id, SObject> oldMap) {}
    public virtual void afterInsert(List<SObject> newList) {}
    public virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void afterDelete(Map<Id, SObject> oldMap) {}
    public virtual void afterUndelete(List<SObject> newList) {}
}

