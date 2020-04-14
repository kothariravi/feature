@isTest
private class TestOppInactivityReminder {
    @isTest static void testOppInactivityReminder() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity firstOpp = new Opportunity(
            Name = 'First Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Pitch',
            AccountId = acc.Id
        );

        Opportunity secondOpp = new Opportunity(
            Name = 'Second Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Closed Won',
            AccountId = acc.Id
        );

        Opportunity thirdOpp = new Opportunity(
            Name = 'Third Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Postponed',
            AccountId = acc.Id
        );

        TriggerBypass.bypassAllOppTriggers(TRUE);
        insert firstOpp;
        insert secondOpp;
        insert thirdOpp;
        TriggerBypass.bypassAllOppTriggers(FALSE);

        Test.startTest();
        Id batchId = Database.executeBatch(new OppInactivityReminder());
        Test.stopTest();

        System.debug(batchId);
    }
}