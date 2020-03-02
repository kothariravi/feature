@isTest
private class TestTriggerUpdateOppNewRecurring {
    @isTest static void TestTriggerUpdateOppNewRecurring() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        TriggerBypass.bypassUpdateOppForecast = TRUE;

        Opportunity firstOpp = new Opportunity(
            Name = 'First Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Closed Won',
            AccountId = acc.Id
        );
        insert firstOpp;

        Opportunity firstOppAfterInsert = [SELECT Id, Type FROM opportunity WHERE Id = :firstOpp.Id LIMIT 1];
        System.debug(firstOppAfterInsert.type);
        System.assert(firstOppAfterInsert.type == 'New Business');

        Opportunity secondOpp = new Opportunity(
            Name = 'Second Opp',
            CloseDate = Date.today(),
            Amount = 2000,
            StageName = 'Closed Won',
            AccountId = acc.Id
        );
        insert secondOpp;

        Opportunity secondOppAfterInsert = [SELECT Id, Type FROM opportunity WHERE Id = :secondOpp.Id LIMIT 1];
        System.debug(secondOppAfterInsert.type);
        System.assert(secondOppAfterInsert.type == 'Existing Business');

        TriggerBypass.bypassUpdateOppForecast = FALSE;
    }
}
