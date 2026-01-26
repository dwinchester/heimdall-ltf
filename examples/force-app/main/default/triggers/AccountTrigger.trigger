// Entrypoint trigger: keep this file thin.
// All domain logic belongs in AccountTriggerHandler; routing is handled by TriggerRouter.
trigger AccountTrigger on Account (after insert) {
    if (Test.isRunningTest() && !ServiceRegistry.isRegistered(IAccountRepository.class)) {
        return;
    }
    TriggerRouter.run(new AccountTriggerHandler());
}
