/**
 * SOQL-based Opportunity data access implementation.
 *
 * @see IOpportunitySelector
 */
public class OpportunitySelector implements IOpportunitySelector {
    /**
     * Fetches a single Opportunity by Id.
     *
     * Note: current implementation uses a single-row SOQL query, which throws if the record
     * does not exist. If you prefer "null when not found", change the implementation accordingly.
     */
    public Opportunity getById(Id opportunityId) {
        return [
            SELECT Id, Name, Amount, CloseDate, StageName, AccountId, OwnerId,
                Type, IsClosed, RenewalReadinessStatus__c, RenewalHealthScore__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
    }

    /**
     * Fetches Opportunities by Id as a map keyed by Id.
     *
     * Returns an empty map when {@code opportunityIds} is null/empty.
     */
    public Map<Id, Opportunity> getByIds(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new Map<Id, Opportunity>();
        }

        return new Map<Id, Opportunity>([
            SELECT Id, Name, Amount, CloseDate, StageName, AccountId, OwnerId,
                Type, IsClosed, RenewalReadinessStatus__c, RenewalHealthScore__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);
    }

    /**
     * Fetches Opportunities for a given Account.
     *
     * Returns an empty list when {@code accountId} is null.
     */
    public List<Opportunity> getByAccountId(Id accountId) {
        if (accountId == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, Amount, CloseDate, StageName, AccountId,
                Type, IsClosed, RenewalReadinessStatus__c, RenewalHealthScore__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE AccountId = :accountId
        ];
    }

    /**
     * Fetches counts and total amount of Opportunities for a region.
     *
     * Region is modeled by {@code Account.BillingState} in this example.
     * Returns an empty list when {@code region} is blank.
     */
    public List<AggregateResult> getCountsAndAmountsByRegion(String region) {
        if (String.isBlank(region)) {
            return new List<AggregateResult>();
        }

        return [
            SELECT COUNT(Id) totalCount, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE Account.BillingState = :region
        ];
    }

    /**
     * Fetches Opportunities owned by a user, closing this quarter, in a region.
     *
     * Region is modeled by {@code Account.BillingState} in this example.
     * Returns an empty list when {@code region} is blank or {@code ownerId} is null.
     */
    public List<Opportunity> getClosingThisQuarter(String region, Id ownerId) {
        if (String.isBlank(region) || ownerId == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, Amount, CloseDate, StageName, AccountId, OwnerId,
                Type, IsClosed, RenewalReadinessStatus__c, RenewalHealthScore__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE OwnerId = :ownerId
            AND CloseDate = THIS_QUARTER
            AND Account.BillingState = :region
        ];
    }

    /**
     * Fetches open Renewal Opportunities for a set of Accounts.
     *
     * Returns an empty list when {@code accountIds} is null/empty.
     */
    public List<Opportunity> getRenewalsByAccountIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, Amount, CloseDate, StageName, AccountId,
                Type, IsClosed, RenewalReadinessStatus__c, RenewalHealthScore__c, LastReadinessCalc__c
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND Type = 'Renewal'
            AND IsClosed = false
        ];
    }

    /**
     * Returns a query locator for stale open Renewal Opportunities.
     */
    public Database.QueryLocator getStaleRenewalQuery(Datetime cutoff) {
        if (cutoff == null) {
            cutoff = System.now();
        }
        return Database.getQueryLocator([
            SELECT Id
            FROM Opportunity
            WHERE Type = 'Renewal'
            AND IsClosed = false
            AND (LastReadinessCalc__c = null OR LastReadinessCalc__c < :cutoff)
        ]);
    }
}
