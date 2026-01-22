trigger TriggerRouterTestTrigger on Account (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Test.isRunningTest()) {
        TriggerRouter.run(new TriggerRouterTestHandler());
    }
}
