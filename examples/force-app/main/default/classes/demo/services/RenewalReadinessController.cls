/**
 * Aura/LWC-facing controller for Renewal Readiness UI.
 */
public with sharing class RenewalReadinessController {
    @AuraEnabled(cacheable=true)
    public static RenewalReadinessDto load(Id opportunityId) {
        IRenewalReadinessService service = resolveService();
        if (service == null) {
            return null;
        }
        return service.loadDto(opportunityId);
    }

    @AuraEnabled
    public static RenewalReadinessDto save(
        Id opportunityId,
        List<RenewalReadinessDto.LineItemRow> changes
    ) {
        IRenewalReadinessService service = resolveService();
        if (service == null) {
            return null;
        }
        if (opportunityId == null) {
            throw new AuraHandledException('Opportunity Id is required.');
        }
        if (changes == null || changes.isEmpty()) {
            return service.loadDto(opportunityId);
        }

        List<OpportunityLineItem> updates = new List<OpportunityLineItem>();
        for (RenewalReadinessDto.LineItemRow change : changes) {
            if (change == null || change.id == null) {
                continue;
            }
            updates.add(new OpportunityLineItem(
                Id = change.id,
                Confirmed__c = change.confirmed,
                RiskFlag__c = change.riskFlag,
                RiskReason__c = change.riskReason
            ));
        }

        try {
            if (updates.isEmpty()) {
                return service.loadDto(opportunityId);
            }
            service.updateLineItems(updates);
        } catch (DmlException ex) {
            throw new AuraHandledException(formatDmlError(ex));
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        return service.loadDto(opportunityId);
    }

    private static IRenewalReadinessService resolveService() {
        DemoServices.registerAll();
        if (Test.isRunningTest() &&
            !ServiceRegistry.isRegistered(IRenewalReadinessService.class)) {
            return null;
        }
        return (IRenewalReadinessService)
            ServiceRegistry.resolve(IRenewalReadinessService.class);
    }

    private static String formatDmlError(DmlException ex) {
        if (ex == null) {
            return 'Unable to save changes.';
        }
        if (ex.getNumDml() > 0) {
            return ex.getDmlMessage(0);
        }
        return ex.getMessage();
    }
}
