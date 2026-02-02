/**
 * Unit tests for repositories/selectors/DTOs.
 */
@isTest
private class RenewalReadinessRepositoryTest extends BaseTest {
    @isTest
    static void selectorShortCircuitsOnEmptyInput() {
        OpportunityLineItemSelector oliSelector = new OpportunityLineItemSelector();
        List<OpportunityLineItem> oliResults =
            oliSelector.getByOpportunityIds(new Set<Id>());
        System.assertEquals(0, oliResults.size());

        TaskSelector taskSelector = new TaskSelector();
        List<Task> tasks = taskSelector.getByOpportunityIds(new Set<Id>(), '');
        System.assertEquals(0, tasks.size());

        assertFastTest();
    }

    @isTest
    static void repositoriesDelegateToMutatorAndSelector() {
        MockRecordMutator mutator = new MockRecordMutator();
        StubLineItemSelector oliSelector = new StubLineItemSelector();
        StubTaskSelector taskSelector = new StubTaskSelector();

        OpportunityLineItemRepository oliRepo =
            new OpportunityLineItemRepository(oliSelector, mutator);
        TaskRepository taskRepo = new TaskRepository(taskSelector, mutator);

        List<OpportunityLineItem> oliResults =
            oliRepo.getByOpportunityIds(new Set<Id>{ '006000000000001AAA' });
        System.assertEquals(1, oliResults.size());

        List<Task> taskResults =
            taskRepo.getByOpportunityIds(new Set<Id>{ '006000000000001AAA' }, 'Subject');
        System.assertEquals(1, taskResults.size());

        oliRepo.insertRecords(new List<OpportunityLineItem>{
            new OpportunityLineItem(Id = '00k000000000001AAA')
        });
        taskRepo.updateRecords(new List<Task>{
            new Task(Id = '00T000000000001AAA')
        });
        taskRepo.deleteRecords(new List<Task>{
            new Task(Id = '00T000000000002AAA')
        });

        System.assertEquals(1, mutator.insertCount);
        System.assertEquals(1, mutator.updateCount);
        System.assertEquals(1, mutator.deleteCount);

        assertFastTest();
    }

    @isTest
    static void dtoMapsOpportunityAndLineItems() {
        Opportunity opp = new Opportunity(
            Id = '006000000000001AAA',
            RenewalHealthScore__c = 80,
            RenewalReadinessStatus__c = 'Green',
            LastReadinessCalc__c = System.now()
        );
        List<OpportunityLineItem> items = new List<OpportunityLineItem>{
            new OpportunityLineItem(
                Id = '00k000000000001AAA',
                Quantity = 1,
                TotalPrice = 100,
                Confirmed__c = true,
                RiskFlag__c = false,
                RiskReason__c = null
            )
        };

        RenewalReadinessDto dto = RenewalReadinessDto.fromOpportunity(opp, items);
        System.assertEquals(opp.Id, dto.opportunityId);
        System.assertEquals(80, dto.score);
        System.assertEquals('Green', dto.status);
        System.assertEquals(1, dto.lineItems.size());
        System.assertEquals(true, dto.lineItems[0].confirmed);

        assertFastTest();
    }

    private class StubLineItemSelector implements IOpportunityLineItemSelector {
        public List<OpportunityLineItem> getByOpportunityIds(Set<Id> opportunityIds) {
            return new List<OpportunityLineItem>{
                new OpportunityLineItem(Id = '00k000000000003AAA')
            };
        }
    }

    private class StubTaskSelector implements ITaskSelector {
        public List<Task> getByOpportunityIds(Set<Id> opportunityIds, String subject) {
            return new List<Task>{
                new Task(Id = '00T000000000003AAA')
            };
        }
    }
}
