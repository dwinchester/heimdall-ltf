/**
 * DTO for Renewal Readiness UI interactions.
 */
public class RenewalReadinessDto {
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public Integer score;
    @AuraEnabled public String status;
    @AuraEnabled public Datetime lastCalculated;
    @AuraEnabled public List<LineItemRow> lineItems;

    public class LineItemRow {
        @AuraEnabled public Id id;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPrice;
        @AuraEnabled public Boolean confirmed;
        @AuraEnabled public Boolean riskFlag;
        @AuraEnabled public String riskReason;
    }

    public static RenewalReadinessDto fromOpportunity(
        Opportunity opp,
        List<OpportunityLineItem> items
    ) {
        if (opp == null) {
            return null;
        }
        RenewalReadinessDto dto = new RenewalReadinessDto();
        dto.opportunityId = opp.Id;
        dto.score = opp.RenewalHealthScore__c == null
            ? null
            : Integer.valueOf(opp.RenewalHealthScore__c);
        dto.status = opp.RenewalReadinessStatus__c;
        dto.lastCalculated = opp.LastReadinessCalc__c;
        dto.lineItems = new List<LineItemRow>();

        if (items != null) {
            for (OpportunityLineItem item : items) {
                LineItemRow row = new LineItemRow();
                row.id = item.Id;
                row.quantity = item.Quantity;
                row.totalPrice = item.TotalPrice;
                row.confirmed = item.Confirmed__c;
                row.riskFlag = item.RiskFlag__c;
                row.riskReason = item.RiskReason__c;
                dto.lineItems.add(row);
            }
        }
        return dto;
    }
}
