@isTest
private class TestUpdateAllOppsNewRecurring {
    @isTest static void testUpdateAllOppsNewRecurring() {

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

        TriggerBypass.bypassAllOppTriggers(TRUE);
        insert firstOpp;
        insert secondOpp;
        TriggerBypass.bypassAllOppTriggers(FALSE);

        UpdateAllOppsNewRecurring.updateAllOppsNewRecurring();
    }
}
