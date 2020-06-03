@isTest
private class TestPostponeOppLineItems {
    @isTest (seeAllData = TRUE)
    static void test() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today(),
            StageName = 'Pitch',
            Account = acc
        );
        insert opp;

        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE IsActive = true][0];

        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = entry.Id,
            OpportunityId = opp.id,
            Quantity = 1,
            UnitPrice = 100,
            ServiceDate = Date.today(),
            Leistungsenddatum__c = Date.today() + 1
        );
        insert oli;
        System.debug(oli);

        Test.startTest();
        opp.StageName = 'Postponed';
        opp.Wiedervorlage_am__c = Date.today() + 10;
        update opp;
        Test.stopTest();

        OpportunityLineItem oliAfterUpdate = [SELECT ServiceDate, Leistungsenddatum__c FROM OpportunityLineItem WHERE Id = :oli.Id][0];
        System.debug(oliAfterUpdate);
        System.assert(oliAfterUpdate.ServiceDate == oli.ServiceDate + 10);
        System.assert(oliAfterUpdate.Leistungsenddatum__c == oli.Leistungsenddatum__c + 10);
    }
}