/**
 * Repository implementation for OpportunityLineItem access.
 *
 * Delegates reads to {@link IOpportunityLineItemSelector} and writes to {@link IRecordMutator}.
 */
public class OpportunityLineItemRepository implements IOpportunityLineItemRepository {
    private final IOpportunityLineItemSelector selector;
    private final IRecordMutator mutator;

    public OpportunityLineItemRepository(
        IOpportunityLineItemSelector selector,
        IRecordMutator mutator
    ) {
        this.selector = selector;
        this.mutator = mutator;
    }

    public List<OpportunityLineItem> getByOpportunityIds(Set<Id> opportunityIds) {
        return selector.getByOpportunityIds(opportunityIds);
    }

    public Database.SaveResult[] insertRecords(List<OpportunityLineItem> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.insertRecords(toSObjects(records));
    }

    public Database.SaveResult[] updateRecords(List<OpportunityLineItem> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.updateRecords(toSObjects(records));
    }

    public Database.DeleteResult[] deleteRecords(List<OpportunityLineItem> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        return mutator.deleteRecords(toSObjects(records));
    }

    private static List<SObject> toSObjects(List<OpportunityLineItem> records) {
        List<SObject> results = new List<SObject>();
        for (OpportunityLineItem record : records) {
            results.add(record);
        }
        return results;
    }
}
