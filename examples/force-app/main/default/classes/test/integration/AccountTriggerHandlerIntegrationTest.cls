/**
 * Integration test for the Account trigger + handler working together.
 *
 * Demonstrates overriding dependencies via {@link ServiceRegistry} by registering a mock selector,
 * then performing real DML to ensure the trigger path uses the mock as intended.
 */
@isTest
private class AccountTriggerHandlerIntegrationTest extends BaseTest {
    @isTest
    static void afterInsertUsesMockSelector() {
        resetRegistry();
        TestServiceRegistry.registerMock(IAccountSelector.class, new MockAccountSelector());
        Account acc = TestDataFactory.account(false);
        insert acc;

        Account saved = [
            SELECT Description
            FROM Account
            WHERE Id = :acc.Id
        ];
        System.assertEquals('Processed: Mock', saved.Description);
        assertSlowTest();
    }
}
