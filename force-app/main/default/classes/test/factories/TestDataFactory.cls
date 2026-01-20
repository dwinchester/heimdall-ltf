/**
 * Minimal test data factory for common sObjects used in tests.
 *
 * Keep these helpers small and predictable to avoid hiding important setup details.
 */
@isTest
public class TestDataFactory {
    public static Account account(Boolean doInsert) {
        Account a = new Account(Name = 'Test');
        if (doInsert) {
            insert a;
        }
        return a;
    }
}

