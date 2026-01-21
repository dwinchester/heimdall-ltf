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

    private static final List<Account> MOCK_ACCOUNTS = new List<Account>{
        new Account(Name = 'Mock 1', BillingState = 'East'),
        new Account(Name = 'Mock 2', BillingState = 'West'),
        new Account(Name = 'Mock 3', BillingState = 'North'),
        new Account(Name = 'Mock 4', BillingState = 'South'),
        new Account(Name = 'Mock 5', BillingState = 'East'),
        new Account(Name = 'Mock 6', BillingState = 'West'),
        new Account(Name = 'Mock 7', BillingState = 'North'),
        new Account(Name = 'Mock 8', BillingState = 'South'),
        new Account(Name = 'Mock 9', BillingState = 'East'),
        new Account(Name = 'Mock 10', BillingState = 'West'),
        new Account(Name = 'Mock 11', BillingState = 'North'),
        new Account(Name = 'Mock 12', BillingState = 'South'),
        new Account(Name = 'Mock 13', BillingState = 'East'),
        new Account(Name = 'Mock 14', BillingState = 'West'),
        new Account(Name = 'Mock 15', BillingState = 'North'),
        new Account(Name = 'Mock 16', BillingState = 'South'),
        new Account(Name = 'Mock 17', BillingState = 'East'),
        new Account(Name = 'Mock 18', BillingState = 'West'),
        new Account(Name = 'Mock 19', BillingState = 'North'),
        new Account(Name = 'Mock 20', BillingState = 'South')
    };

    public static List<Account> mockAccounts() {
        return new List<Account>(MOCK_ACCOUNTS);
    }

    public static List<Account> mockAccounts(Boolean doInsert) {
        List<Account> accounts = new List<Account>(MOCK_ACCOUNTS);
        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }
}
