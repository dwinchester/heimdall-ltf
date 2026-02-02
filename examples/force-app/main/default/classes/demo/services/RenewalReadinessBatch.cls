/**
 * Nightly batch job to recalculate stale Renewal readiness.
 */
public class RenewalReadinessBatch implements Database.Batchable<SObject> {
    public static final Integer DEFAULT_STALE_DAYS = 7;

    private final Integer staleDays;
    private final IClock clock;
    private final IOpportunityRepository opportunityRepository;
    private final IRenewalReadinessService readinessService;

    public RenewalReadinessBatch() {
        this(DEFAULT_STALE_DAYS, null);
    }

    public RenewalReadinessBatch(Integer staleDays) {
        this(staleDays, null);
    }

    public RenewalReadinessBatch(Integer staleDays, IClock clock) {
        this.staleDays = staleDays == null ? DEFAULT_STALE_DAYS : staleDays;
        this.clock = clock == null ? resolveClock() : clock;
        this.opportunityRepository = resolveOpportunityRepository();
        this.readinessService = resolveReadinessService();
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        if (opportunityRepository == null) {
            return Database.getQueryLocator([
                SELECT Id
                FROM Opportunity
                WHERE Id = null
            ]);
        }
        Datetime now = clock == null ? System.now() : clock.now();
        Datetime cutoff = now.addDays(-staleDays);
        return opportunityRepository.getStaleRenewalQuery(cutoff);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }
        if (readinessService == null) {
            return;
        }
        Set<Id> oppIds = new Set<Id>();
        for (SObject record : scope) {
            oppIds.add(record.Id);
        }
        try {
            readinessService.recalcByOpportunityIds(oppIds);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'RenewalReadinessBatch failed: ' + ex.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {
        if (context == null) {
            return;
        }
        AsyncApexJob job = [
            SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :context.getJobId()
            LIMIT 1
        ];
        System.debug(
            LoggingLevel.INFO,
            'RenewalReadinessBatch finished. Status=' + job.Status +
            ', Errors=' + job.NumberOfErrors +
            ', Processed=' + job.JobItemsProcessed + '/' + job.TotalJobItems
        );
    }

    private static IClock resolveClock() {
        if (Test.isRunningTest() && !ServiceRegistry.isRegistered(IClock.class)) {
            return null;
        }
        return (IClock) ServiceRegistry.resolve(IClock.class);
    }

    private static IOpportunityRepository resolveOpportunityRepository() {
        DemoServices.registerAll();
        if (Test.isRunningTest() &&
            !ServiceRegistry.isRegistered(IOpportunityRepository.class)) {
            return null;
        }
        return (IOpportunityRepository) ServiceRegistry.resolve(IOpportunityRepository.class);
    }

    private static IRenewalReadinessService resolveReadinessService() {
        DemoServices.registerAll();
        if (Test.isRunningTest() &&
            !ServiceRegistry.isRegistered(IRenewalReadinessService.class)) {
            return null;
        }
        return (IRenewalReadinessService)
            ServiceRegistry.resolve(IRenewalReadinessService.class);
    }
}
