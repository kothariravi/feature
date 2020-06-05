@IsTest
private class TestCompleteInactivityReminderOnTask {
    @IsTest
    static void test() {
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Co.'
        );
        insert lead;

        Task reminderTaskLead = new Task(
            Subject = 'Test Reminder Task',
            ActivityDate = Date.today(),
            Type = 'Inactivity Reminder',
            WhoId = lead.Id
        );
        insert reminderTaskLead;

        Task newTaskLead = new Task(
            Subject = 'Test New Task',
            ActivityDate = Date.today(),
            WhoId = lead.Id
        );
        insert newTaskLead;

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Task reminderTaskAccount = new Task(
            Subject = 'Test Reminder Task',
            ActivityDate = Date.today(),
            Type = 'Inactivity Reminder',
            WhatId = acc.Id
        );
        insert reminderTaskAccount;

        Task newTaskAccount = new Task(
            Subject = 'Test New Task',
            ActivityDate = Date.today(),
            WhatId = acc.Id
        );
        insert newTaskAccount;

        Task reminderTaskLeadAfterTest = [SELECT Id, isClosed FROM Task WHERE Id = :reminderTaskLead.Id][0];
        System.assert(reminderTaskLeadAfterTest.isClosed == true);

        Task reminderTaskAccountAfterTest = [SELECT Id, isClosed FROM Task WHERE Id = :reminderTaskAccount.Id][0];
        System.assert(reminderTaskAccountAfterTest.isClosed == true);
    }
}