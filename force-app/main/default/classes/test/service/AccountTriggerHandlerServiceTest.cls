/**
 * Service-style test that exercises real DML and validates persistence behavior.
 *
 * This is a template example; extend it to validate your actual trigger/service side effects.
 */
@isTest
private class AccountTriggerHandlerServiceTest extends BaseTest {
    @isTest
    static void updatesFieldOnInsert() {
        resetRegistry();
        Account a = TestDataFactory.account(true);
        a.Description = 'Updated';
        update a;

        Account saved = [
            SELECT Description
            FROM Account
            WHERE Id = :a.Id
        ];
        System.assertEquals('Updated', saved.Description);
        assertFastTest();
    }
}

