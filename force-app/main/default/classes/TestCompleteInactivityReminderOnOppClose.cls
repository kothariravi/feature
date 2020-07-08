@IsTest
private class TestCompleteInactivityReminderOnOppClose {
    @IsTest
    static void test() {
        Account acc = new Account(
            Name = 'Test Acc'
        );
        insert acc;

        Opportunity opp = new Opportunity(
        	Name = 'Test Opp',
            StageName = 'Pitch',
            CloseDate = Date.today(),
            Account = acc
        );
        insert opp;

        Task reminderTask = new Task(
            Subject = 'Test Reminder Task',
            ActivityDate = Date.today(),
            Type = 'Inactivity Reminder',
            WhatId = opp.Id
        );
        insert reminderTask;

        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();

        Task reminderTaskAfterUpdate = [SELECT Id, isClosed FROM Task WHERE Id = :reminderTask.Id LIMIT 1];
        System.assert(reminderTaskAfterUpdate.isClosed == true);
    }
}