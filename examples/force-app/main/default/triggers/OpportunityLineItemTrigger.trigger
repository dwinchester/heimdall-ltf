/*
 * Renewal readiness trigger for OpportunityLineItem.
 *
 * before update: validate risk items have a reason.
 * after insert/update/delete: recalculate readiness for parent renewal
 * opportunities based on line item changes.
 */
trigger OpportunityLineItemTrigger on OpportunityLineItem (
    before update,
    after insert,
    after update,
    after delete
) {
    TriggerRouter.run(new RenewalLineItemTriggerHandler());
}
