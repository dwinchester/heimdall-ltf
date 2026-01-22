/**
 * Unit tests for {@link AccountService}.
 *
 * These tests validate constructor injection by supplying a mock selector directly.
 */
@isTest
private class AccountServiceTest extends BaseTest {
    @isTest
    static void returnsMockedAccount() {
        resetRegistry();
        AccountService svc = new AccountService(new MockAccountSelector());
        Account acc = svc.getAccount(Id.valueOf('001000000000001'));
        System.assertEquals('Mock', acc.Name);
        assertSlowTest();
    }
}
