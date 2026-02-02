/**
 * Unit tests for DemoServices registrations.
 */
@isTest
private class DemoServicesTest extends BaseTest {
    @isTest
    static void registerAllForTestRegistersBindings() {
        TestServiceRegistry.reset();
        DemoServices.registerAllForTest();

        System.assert(ServiceRegistry.isRegistered(IAccountSelector.class));
        System.assert(ServiceRegistry.isRegistered(IOpportunitySelector.class));
        System.assert(ServiceRegistry.isRegistered(IOpportunityLineItemSelector.class));
        System.assert(ServiceRegistry.isRegistered(ITaskSelector.class));
        System.assert(ServiceRegistry.isRegistered(IAccountRepository.class));
        System.assert(ServiceRegistry.isRegistered(IOpportunityRepository.class));
        System.assert(ServiceRegistry.isRegistered(IOpportunityLineItemRepository.class));
        System.assert(ServiceRegistry.isRegistered(ITaskRepository.class));
        System.assert(ServiceRegistry.isRegistered(IRenewalReadinessService.class));

        assertFastTest();
    }
}
