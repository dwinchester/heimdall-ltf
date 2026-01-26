/**
 * Repository implementation for Opportunity access.
 *
 * Delegates reads to {@link IOpportunitySelector} and writes to {@link IRecordMutator}.
 */
public class OpportunityRepository implements IOpportunityRepository {
    private final IOpportunitySelector selector;
    private final IRecordMutator mutator;

    public OpportunityRepository(IOpportunitySelector selector, IRecordMutator mutator) {
        this.selector = selector;
        this.mutator = mutator;
    }

    public Opportunity getById(Id opportunityId) {
        return selector.getById(opportunityId);
    }

    public Map<Id, Opportunity> getByIds(Set<Id> opportunityIds) {
        return selector.getByIds(opportunityIds);
    }

    public List<Opportunity> getByAccountId(Id accountId) {
        return selector.getByAccountId(accountId);
    }

    public List<AggregateResult> getCountsAndAmountsByRegion(String region) {
        return selector.getCountsAndAmountsByRegion(region);
    }

    public List<Opportunity> getClosingThisQuarter(String region, Id ownerId) {
        return selector.getClosingThisQuarter(region, ownerId);
    }

    public Database.SaveResult[] insertRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.insertRecords(toSObjects(records));
    }

    public Database.SaveResult[] updateRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.SaveResult[] {};
        }
        return mutator.updateRecords(toSObjects(records));
    }

    public Database.DeleteResult[] deleteRecords(List<Opportunity> records) {
        if (records == null || records.isEmpty()) {
            return new Database.DeleteResult[] {};
        }
        return mutator.deleteRecords(toSObjects(records));
    }

    private static List<SObject> toSObjects(List<Opportunity> records) {
        List<SObject> results = new List<SObject>();
        for (Opportunity record : records) {
            results.add(record);
        }
        return results;
    }
}
