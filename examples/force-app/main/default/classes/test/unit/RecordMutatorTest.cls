/**
 * Unit test for mutator abstraction wiring in AccountTriggerHandler.
 */
@isTest
private class RecordMutatorTest extends BaseTest {
    @isTest
    static void usesMockMutatorOnAfterInsert() {
        resetRegistry();

        MockAccountSelector selector = new MockAccountSelector();
        MockRecordMutator mutator = new MockRecordMutator();
        TestServiceRegistry.registerMock(IAccountSelector.class, selector);
        TestServiceRegistry.registerMock(IRecordMutator.class, mutator);

        Account a = TestDataFactory.account(false);
        a.Id = Id.valueOf('001000000000001AAA');

        AccountTriggerHandler handler = new AccountTriggerHandler();
        handler.afterInsert(new List<SObject>{ a });

        System.assertEquals(1, mutator.updateCount, 'Expected mutator to be invoked once.');
        System.assertEquals(1, mutator.updated.size(), 'Expected one record updated.');

        Account updated = (Account) mutator.updated[0];
        System.assertEquals(a.Id, updated.Id);
        System.assertEquals('Processed: Mock', updated.Description);
        assertFastTest();
    }

    @isTest
    static void noRecordsDoesNotInvokeMutator() {
        resetRegistry();

        MockRecordMutator mutator = new MockRecordMutator();
        TestServiceRegistry.registerMock(IRecordMutator.class, mutator);

        AccountTriggerHandler handler = new AccountTriggerHandler();
        handler.afterInsert(new List<SObject>());

        System.assertEquals(0, mutator.updateCount, 'Expected no update attempt.');
        System.assertEquals(0, mutator.updated.size(), 'Expected no records updated.');
        assertFastTest();
    }
}
