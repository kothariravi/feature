@IsTest
private class TestCompleteInactivityReminderOnTask {
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

        Task newTask = new Task(
            Subject = 'Test New Task',
            ActivityDate = Date.today(),
            WhoId = lead.Id
        );
        insert newTask;

        Task reminderTaskAfterTest = [SELECT Id, isClosed FROM Task WHERE Id = :reminderTask.Id][0];
        System.assert(reminderTaskAfterTest.isClosed == true);
    }
}