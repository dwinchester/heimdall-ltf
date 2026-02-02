/*
 * Renewal readiness trigger for Opportunity.
 *
 * Uses the TriggerRouter framework to delegate all logic to the
 * RenewalOpportunityTriggerHandler, keeping the trigger slim and testable.
 * The handler recalculates readiness for renewal opportunities when key
 * fields change or new records are inserted.
 */
trigger OpportunityTrigger on Opportunity (after insert, after update) {
    TriggerRouter.run(new RenewalOpportunityTriggerHandler());
}
