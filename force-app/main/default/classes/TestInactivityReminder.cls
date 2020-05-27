@isTest
private class TestInactivityReminder {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest static void testScheduledMethod() {
        Account acc = new Account(
            Name = 'Test Acc',
            Kundensegment__c = 'Gold'
        );
        insert acc;
        Test.setCreatedDate(acc.Id, Date.today() - 70);

        TriggerBypass.bypassAllOppTriggers(TRUE);
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Pitch'
        );
        insert opp;
        Test.setCreatedDate(opp.Id, Date.today() - 8);
        TriggerBypass.bypassAllOppTriggers(FALSE);

        Lead lead = new Lead(
            LastName = 'Test Lead',
            Status = 'In_Kontakt',
            Company = 'Test Co.'
        );
        insert lead;
        Test.setCreatedDate(lead.Id, Date.today() - 31);

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ScheduledInactivityReminder());
        Test.stopTest();

        List<Task> taskList = new List<Task>();

        taskList = [SELECT Id, Subject FROM Task WHERE WhatId = :acc.id];
        System.assert(taskList.size() > 0);
        
        taskList = [SELECT Id, Subject FROM Task WHERE WhatId = :opp.id];
        System.assert(taskList.size() > 0);
        
        taskList = [SELECT Id, Subject FROM Task WHERE WhoId = :lead.id];
        System.assert(taskList.size() > 0);
    }
}