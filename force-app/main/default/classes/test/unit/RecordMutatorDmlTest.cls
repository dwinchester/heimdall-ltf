/**
 * DML-focused tests for {@link SystemRecordMutator}.
 */
@isTest
private class RecordMutatorDmlTest extends BaseTest {
    @isTest
    static void insertsAccount() {
        IRecordMutator mutator = new SystemRecordMutator();

        Account acc = new Account(Name = 'Insert Test');
        Database.SaveResult[] results = mutator.insertRecords(new List<SObject>{ acc });

        System.assertEquals(1, results.size(), 'Expected one insert result.');
        System.assert(results[0].isSuccess(), 'Expected insert to succeed.');

        Account saved = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Insert Test', saved.Name);
        assertSlowTest();
    }

    @isTest
    static void updatesAccount() {
        IRecordMutator mutator = new SystemRecordMutator();

        Account acc = new Account(Name = 'Update Test');
        insert acc;

        acc.Name = 'Updated';
        Database.SaveResult[] results = mutator.updateRecords(new List<SObject>{ acc });

        System.assertEquals(1, results.size(), 'Expected one update result.');
        System.assert(results[0].isSuccess(), 'Expected update to succeed.');

        Account saved = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated', saved.Name);
        assertSlowTest();
    }

    @isTest
    static void deletesAccount() {
        IRecordMutator mutator = new SystemRecordMutator();

        Account acc = new Account(Name = 'Delete Test');
        insert acc;

        Database.DeleteResult[] results = mutator.deleteRecords(new List<SObject>{ acc });

        System.assertEquals(1, results.size(), 'Expected one delete result.');
        System.assert(results[0].isSuccess(), 'Expected delete to succeed.');

        Integer remaining = [SELECT count() FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, remaining);
        assertSlowTest();
    }
}
