/**
 * Trigger handler for Renewal OpportunityLineItem events.
 */
public class RenewalLineItemTriggerHandler extends TriggerHandler {
    private IRenewalReadinessService service;

    /**
     * Register services and resolve the readiness service dependency.
     * In tests, allows a missing registration so mocks can be injected.
     */
    public RenewalLineItemTriggerHandler() {
        DemoServices.registerAll();
        if (Test.isRunningTest() && !ServiceRegistry.isRegistered(IRenewalReadinessService.class)) {
            return;
        }
        this.service = (IRenewalReadinessService)
            ServiceRegistry.resolve(IRenewalReadinessService.class);
    }

    /**
     * Enforce required risk reason when marking an item as at risk.
     */
    public override void beforeInsert(List<SObject> newList) {
        validateRiskReason(newList);
    }

    /**
     * Enforce required risk reason when marking an item as at risk.
     */
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        validateRiskReason(newList);
    }

    /**
     * Recalculate readiness for parent opportunities after item inserts.
     */
    public override void afterInsert(List<SObject> newList) {
        recalcFromItems(newList);
    }

    /**
     * Recalculate readiness for parent opportunities after item updates.
     */
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        recalcFromItems(newList);
    }

    /**
     * Recalculate readiness for parent opportunities after item deletes.
     */
    public override void afterDelete(Map<Id, SObject> oldMap) {
        if (oldMap == null || oldMap.isEmpty()) {
            return;
        }
        List<SObject> records = new List<SObject>();
        records.addAll(oldMap.values());
        recalcFromItems(records);
    }

    /**
     * Collect parent opportunity ids from line items and delegate to service.
     */
    private void recalcFromItems(List<SObject> records) {
        if (service == null) {
            return;
        }
        Set<Id> oppIds = new Set<Id>();
        if (records != null) {
            for (SObject record : records) {
                if (record instanceof OpportunityLineItem) {
                    OpportunityLineItem item = (OpportunityLineItem) record;
                    if (item.OpportunityId != null) {
                        oppIds.add(item.OpportunityId);
                    }
                }
            }
        }
        if (!oppIds.isEmpty()) {
            service.recalcByOpportunityIds(oppIds);
        }
    }

    private static void validateRiskReason(List<SObject> records) {
        if (records == null) {
            return;
        }
        for (SObject record : records) {
            if (!(record instanceof OpportunityLineItem)) {
                continue;
            }
            OpportunityLineItem item = (OpportunityLineItem) record;
            if (item.RiskFlag__c == true && String.isBlank(item.RiskReason__c)) {
                item.addError('Risk reason is required when item is marked at risk.');
            }
        }
    }
}
