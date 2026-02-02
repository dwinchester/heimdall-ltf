/**
 * Test data factory for Renewal Readiness scenarios.
 */
@isTest
public class RenewalTestDataFactory {
    public static final String KEY_A_HIGH = 'A_HIGH';
    public static final String KEY_A_MED = 'A_MED';
    public static final String KEY_A_LOW = 'A_LOW';

    public static final String KEY_O1 = 'O1';
    public static final String KEY_O2 = 'O2';
    public static final String KEY_O3 = 'O3';
    public static final String KEY_O4 = 'O4';
    public static final String KEY_O5 = 'O5';
    public static final String KEY_O6 = 'O6';

    public class CanonicalData {
        public Map<String, Account> accountsByKey = new Map<String, Account>();
        public Map<String, Opportunity> oppsByKey = new Map<String, Opportunity>();
        public Map<String, OpportunityLineItem> lineItemsByKey = new Map<String, OpportunityLineItem>();
        public Id pricebookEntryId;
    }

    public static CanonicalData createCanonicalData(Boolean doInsert) {
        CanonicalData data = new CanonicalData();
        Date t0 = Date.today();

        Account aHigh = new Account(Name = 'A_HIGH', CustomerPriority__c = 'High');
        Account aMed = new Account(Name = 'A_MED', CustomerPriority__c = 'Medium');
        Account aLow = new Account(Name = 'A_LOW', CustomerPriority__c = 'Low');
        data.accountsByKey.put(KEY_A_HIGH, aHigh);
        data.accountsByKey.put(KEY_A_MED, aMed);
        data.accountsByKey.put(KEY_A_LOW, aLow);

        if (doInsert) {
            insert new List<Account>{ aHigh, aMed, aLow };
        }

        Id pricebookId = Test.getStandardPricebookId();
        data.pricebookEntryId = doInsert
            ? createPricebookEntry(pricebookId)
            : null;

        Opportunity o1 = new Opportunity(
            Name = 'O1_NO_OLIS_URGENT',
            AccountId = aLow.Id,
            CloseDate = t0.addDays(7),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );
        Opportunity o2 = new Opportunity(
            Name = 'O2_CONFIRMED_CAP',
            AccountId = aMed.Id,
            CloseDate = t0.addDays(60),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );
        Opportunity o3 = new Opportunity(
            Name = 'O3_RISK_WITH_REASON',
            AccountId = aHigh.Id,
            CloseDate = t0.addDays(60),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );
        Opportunity o4 = new Opportunity(
            Name = 'O4_RISK_MISSING_REASON',
            AccountId = aLow.Id,
            CloseDate = t0.addDays(60),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );
        Opportunity o5 = new Opportunity(
            Name = 'O5_MIXED_URGENT',
            AccountId = aHigh.Id,
            CloseDate = t0.addDays(7),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );
        Opportunity o6 = new Opportunity(
            Name = 'O6_DELETE_LAST_RISK',
            AccountId = aMed.Id,
            CloseDate = t0.addDays(60),
            StageName = 'Prospecting',
            Type = 'Renewal',
            Amount = 100,
            Pricebook2Id = pricebookId
        );

        data.oppsByKey.put(KEY_O1, o1);
        data.oppsByKey.put(KEY_O2, o2);
        data.oppsByKey.put(KEY_O3, o3);
        data.oppsByKey.put(KEY_O4, o4);
        data.oppsByKey.put(KEY_O5, o5);
        data.oppsByKey.put(KEY_O6, o6);

        if (doInsert) {
            insert new List<Opportunity>{ o1, o2, o3, o4, o5, o6 };
        }

        if (doInsert) {
            List<OpportunityLineItem> items = new List<OpportunityLineItem>{
                lineItem(o2.Id, data.pricebookEntryId, true, false, null),
                lineItem(o2.Id, data.pricebookEntryId, true, false, null),
                lineItem(o2.Id, data.pricebookEntryId, true, false, null),
                lineItem(o2.Id, data.pricebookEntryId, true, false, null),
                lineItem(o3.Id, data.pricebookEntryId, false, true, 'Pricing concern'),
                lineItem(o4.Id, data.pricebookEntryId, false, true, ''),
                lineItem(o5.Id, data.pricebookEntryId, true, false, null),
                lineItem(o5.Id, data.pricebookEntryId, true, false, null),
                lineItem(o5.Id, data.pricebookEntryId, false, true, 'Legal review'),
                lineItem(o6.Id, data.pricebookEntryId, false, true, 'Waiting for PO')
            };
            insert items;
            Integer index = 1;
            for (OpportunityLineItem item : items) {
                data.lineItemsByKey.put('LI_' + index, item);
                index++;
            }
        }

        return data;
    }

    public class BulkData {
        public List<Opportunity> opportunities = new List<Opportunity>();
        public List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
    }

    public static BulkData createBulkData(Account account, Id pricebookEntryId) {
        BulkData data = new BulkData();
        Date t0 = Date.today();

        for (Integer i = 1; i <= 50; i++) {
            Boolean urgent = i <= 25;
            Opportunity opp = new Opportunity(
                Name = 'O_BULK_' + String.valueOf(i).leftPad(3, '0'),
                AccountId = account.Id,
                CloseDate = urgent ? t0.addDays(7) : t0.addDays(60),
                StageName = 'Prospecting',
                Type = 'Renewal',
                Amount = 100,
                Pricebook2Id = Test.getStandardPricebookId()
            );
            data.opportunities.add(opp);
        }

        insert data.opportunities;

        Integer oppIndex = 0;
        for (Opportunity opp : data.opportunities) {
            oppIndex++;
            List<OpportunityLineItem> items = buildPatternLineItems(
                opp,
                pricebookEntryId,
                patternForIndex(oppIndex)
            );
            data.lineItems.addAll(items);
        }
        insert data.lineItems;
        return data;
    }

    private static Id createPricebookEntry(Id pricebookId) {
        Product2 product = new Product2(Name = 'Renewal Product', IsActive = true);
        insert product;
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true,
            UseStandardPrice = false
        );
        insert entry;
        return entry.Id;
    }

    private static OpportunityLineItem lineItem(
        Id opportunityId,
        Id pricebookEntryId,
        Boolean confirmed,
        Boolean riskFlag,
        String riskReason
    ) {
        return new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 1,
            UnitPrice = 100,
            Confirmed__c = confirmed,
            RiskFlag__c = riskFlag,
            RiskReason__c = riskReason
        );
    }

    private static String patternForIndex(Integer index) {
        if (index <= 20) {
            return 'P1';
        }
        if (index <= 35) {
            return 'P2';
        }
        if (index <= 45) {
            return 'P3';
        }
        return 'P4';
    }

    private static List<OpportunityLineItem> buildPatternLineItems(
        Opportunity opp,
        Id pricebookEntryId,
        String pattern
    ) {
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        if (pattern == 'P1') {
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
        } else if (pattern == 'P2') {
            items.add(lineItem(opp.Id, pricebookEntryId, false, true, 'Risk'));
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, false, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, false, false, null));
        } else if (pattern == 'P3') {
            items.add(lineItem(opp.Id, pricebookEntryId, false, true, 'Risk'));
            items.add(lineItem(opp.Id, pricebookEntryId, false, true, 'Risk'));
            items.add(lineItem(opp.Id, pricebookEntryId, false, true, 'Risk'));
            items.add(lineItem(opp.Id, pricebookEntryId, false, false, null));
        } else {
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, true, false, null));
            items.add(lineItem(opp.Id, pricebookEntryId, false, true, 'Risk'));
            items.add(lineItem(opp.Id, pricebookEntryId, false, false, null));
        }
        return items;
    }
}
