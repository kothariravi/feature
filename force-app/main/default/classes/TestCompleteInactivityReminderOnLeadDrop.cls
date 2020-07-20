@IsTest
private class TestCompleteInactivityReminderOnLeadDrop {
    @IsTest
    static void test() {
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Co.'
        );
        insert lead;

        Task reminderTask = new Task(
            Subject = 'Test Reminder Task',
            ActivityDate = Date.today(),
            Type = 'Inactivity Reminder',
            WhoId = lead.Id
        );
        insert reminderTask;

        Test.startTest();
        lead.Status = 'Dropped';
        lead.Dropped_Reason__c = 'Keine Entscheidung';
        update lead;
        Test.stopTest();

        Task reminderTaskAfterUpdate = [SELECT Id, isClosed FROM Task WHERE Id = :reminderTask.Id LIMIT 1];
        System.assert(reminderTaskAfterUpdate.isClosed == true);
    }
}