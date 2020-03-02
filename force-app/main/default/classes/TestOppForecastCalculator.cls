@isTest
private class TestOppForecastCalculator {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    // method has all data access to query opportunity history
    @isTest (seeAllData = TRUE)
    static void testScheduledMethod() {
        TriggerBypass.bypassUpdateOppForecast = TRUE;

        Opportunity oppWon = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Pitch',
            LeadSource = 'Kundenempfehlung'
        );
        insert oppWon;
        oppWon.stageName = 'Closed Won';
        update oppWon;

        Opportunity oppLost = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Pitch',
            LeadSource = 'Kundenempfehlung',
            Loss_Reason__c = 'Other'
        );
        insert oppLost;
        oppLost.stageName = 'Closed Lost';
        update oppLost;

        Opportunity oppOpen = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            Amount = 10000,
            StageName = 'Pitch',
            LeadSource = 'Kundenempfehlung'
        );
        insert oppOpen;
        TriggerBypass.bypassUpdateOppForecast = FALSE;

        List<Opportunity> allOppsWithHistories = [
            SELECT id, stageName, leadSource, (SELECT stagename FROM opportunityHistories)
            FROM opportunity
        ];
        for (Opportunity opp : allOppsWithHistories) {
            System.debug(opp);
        }

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ScheduledOppForecastCalculator());
        Test.stopTest();

        Opportunity oppAssertion = [SELECT Id, Expected_Amount__c FROM opportunity WHERE Id = :oppOpen.Id LIMIT 1];
        System.debug(oppAssertion.expected_amount__c);
        // cant assert abs value bc seeAllData might change CVR
        System.assert(oppAssertion.expected_amount__c != 0);


        // test trigger
        Opportunity oppTrigger = [SELECT Id, Amount, Expected_Amount__c FROM opportunity WHERE Id = :oppOpen.Id LIMIT 1];
        oppTrigger.amount = 20000;
        update oppTrigger;

        Opportunity oppTriggerAfterUpdate = [SELECT Id, Amount, Expected_Amount__c FROM opportunity WHERE Id = :oppTrigger.Id LIMIT 1];
        System.debug(oppTriggerAfterUpdate.amount);
        System.debug(oppTriggerAfterUpdate.expected_amount__c);
        System.assert(oppTriggerAfterUpdate.expected_amount__c > oppTrigger.expected_amount__c);
    }
}