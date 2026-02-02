/**
 * Unit tests for RenewalReadinessService calculations.
 */
@isTest
private class RenewalReadinessServiceTest extends BaseTest {
    @isTest
    static void calculatesCanonicalScores() {
        Date today = Date.today();
        Datetime now = Datetime.newInstance(today, Time.newInstance(0, 0, 0, 0));

        RenewalReadinessService.ReadinessResult o1 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(7), 'Renewal'),
            new List<OpportunityLineItem>(),
            account('Low'),
            today,
            now
        );
        System.assertEquals(40, o1.score);
        System.assertEquals('Red', o1.status);

        RenewalReadinessService.ReadinessResult o2 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(60), 'Renewal'),
            new List<OpportunityLineItem>{
                oli(true, false, null),
                oli(true, false, null),
                oli(true, false, null),
                oli(true, false, null)
            },
            account('Medium'),
            today,
            now
        );
        System.assertEquals(85, o2.score);
        System.assertEquals('Green', o2.status);

        RenewalReadinessService.ReadinessResult o3 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(60), 'Renewal'),
            new List<OpportunityLineItem>{
                oli(false, true, 'Pricing concern')
            },
            account('High'),
            today,
            now
        );
        System.assertEquals(45, o3.score);
        System.assertEquals('Red', o3.status);

        RenewalReadinessService.ReadinessResult o4 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(60), 'Renewal'),
            new List<OpportunityLineItem>{
                oli(false, true, '')
            },
            account('Low'),
            today,
            now
        );
        System.assertEquals(true, o4.blocked);
        System.assertEquals(null, o4.score);
        System.assertEquals(null, o4.status);

        RenewalReadinessService.ReadinessResult o5 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(7), 'Renewal'),
            new List<OpportunityLineItem>{
                oli(true, false, null),
                oli(true, false, null),
                oli(false, true, 'Legal review')
            },
            account('High'),
            today,
            now
        );
        System.assertEquals(65, o5.score);
        System.assertEquals('Amber', o5.status);

        RenewalReadinessService.ReadinessResult o6 = RenewalReadinessService.calculateReadiness(
            opp(today.addDays(60), 'Renewal'),
            new List<OpportunityLineItem>{
                oli(false, true, 'Waiting for PO')
            },
            account('Medium'),
            today,
            now
        );
        System.assertEquals(40, o6.score);
        System.assertEquals('Red', o6.status);

        assertFastTest();
    }

    @isTest
    static void buildsAccountSummary() {
        RenewalReadinessService.SummaryCounts counts =
            new RenewalReadinessService.SummaryCounts();
        counts.total = 2;
        counts.green = 1;
        counts.amber = 0;
        counts.red = 1;
        System.assertEquals(
            '2 renewals: 1 Green, 0 Amber, 1 Red',
            RenewalReadinessService.buildSummary(counts)
        );
        assertFastTest();
    }

    private static Opportunity opp(Date closeDate, String typeValue) {
        return new Opportunity(
            CloseDate = closeDate,
            Type = typeValue,
            StageName = 'Prospecting'
        );
    }

    private static Account account(String priority) {
        return new Account(CustomerPriority__c = priority);
    }

    private static OpportunityLineItem oli(Boolean confirmed, Boolean riskFlag, String reason) {
        return new OpportunityLineItem(
            Confirmed__c = confirmed,
            RiskFlag__c = riskFlag,
            RiskReason__c = reason
        );
    }
}
