@isTest
private class TestInactivityReminder {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest static void testScheduledMethod() {

        String accId;

        for (Integer i = 0; i < 25; i++) {
            Account acc = new Account(
                Name = 'Test Account',
                Kundensegment__c = 'Gold'
            );
            insert acc;
            Test.setCreatedDate(acc.Id, Date.today() - 61);
            accId = acc.Id;
        }

        TriggerBypass.bypassAllOppTriggers(TRUE);
        for (Integer i = 0; i < 25; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                CloseDate = Date.today(),
                Amount = 2000,
                StageName = 'Pitch',
                AccountId = accId
            );
            insert opp;
            Test.setCreatedDate(opp.Id, Date.today() - 8);
        }
        TriggerBypass.bypassAllOppTriggers(FALSE);

        for (Integer i = 0; i < 25; i++) {
            Lead lead = new Lead(
                LastName = 'Test Lead',
                Company = 'Test Co.',
                Status = 'Call/Pitch Follow Up'
            );
            insert lead;
            Test.setCreatedDate(lead.Id, Date.today() - 8);
        }

        Test.startTest();
        ScheduledInactivityReminder scheduler = new ScheduledInactivityReminder();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            scheduler);
        scheduler.execute(null);
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task WHERE Type = 'Inactivity Reminder'];

        System.debug(taskList.size());
        System.assert(taskList.size() == 75);
    }
}