/**
 * Routes the current trigger context to the matching method on a {@link TriggerHandler}.
 *
 * Intended usage: keep triggers as thin entrypoints (one line) and move logic into handlers.
 *
 * Behavior:
 * - If {@code handler} is null, this method is a no-op.
 * - Passes {@code Trigger.new} / {@code Trigger.oldMap} through unchanged.
 *
 * @see TriggerHandler
 */
public class TriggerRouter {
    public static void run(TriggerHandler handler) {
        if (handler == null) {
            return;
        }

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.new, Trigger.oldMap);
            } else if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.oldMap);
            }
        } else {
            if (Trigger.isInsert) {
                handler.afterInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.new, Trigger.oldMap);
            } else if (Trigger.isDelete) {
                handler.afterDelete(Trigger.oldMap);
            } else if (Trigger.isUndelete) {
                handler.afterUndelete(Trigger.new);
            }
        }
    }
}

