@isTest
private class TestInactivityReminder {
    @isTest static void testInactivityReminderAccounts() {
        Account acc = new Account(
            Name = 'Test Acc',
            Kundensegment__c = 'Gold'
        );
        insert acc;
        Test.setCreatedDate(acc.Id, Date.today() - 70);

        InactivityReminder reminder = new InactivityReminder();
        reminder.checkAccounts();

        List<Task> taskList = [SELECT Id, Subject FROM Task WHERE WhatId = :acc.id];
        System.assert(taskList.size() > 0);
    }

    @isTest static void testInactivityReminderOpps() {
        TriggerBypass.bypassAllOppTriggers(TRUE);

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Pitch'
        );
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today() - 8);
        
        InactivityReminder reminder = new InactivityReminder();
        reminder.checkOpportunities();
        
        List<Task> taskList = [SELECT Id, Subject FROM Task WHERE WhatId = :opp.id];
        System.assert(taskList.size() > 0);

        TriggerBypass.bypassAllOppTriggers(FALSE);
    }

    @isTest static void testInactivityReminderLeads() {
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Status = 'In_Kontakt',
            Company = 'Test Co.'
        );
        insert lead;
        Test.setCreatedDate(lead.Id, Date.today() - 31);
        
        InactivityReminder reminder = new InactivityReminder();
        reminder.checkLeads();
        
        List<Task> taskList = [SELECT Id, Subject FROM Task WHERE WhoId = :lead.id];
        System.assert(taskList.size() > 0);
    }
}
