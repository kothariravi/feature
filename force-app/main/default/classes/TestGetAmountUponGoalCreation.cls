@IsTest
private class TestGetAmountUponGoalCreation {
    @IsTest
    static void testGetAmountUponGoalCreation(){
        Account acc = new Account(
        	Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test Opp',
            StageName = 'Closed Won',
            CloseDate = date.parse('01.02.2020'),
            Account = acc
        );
        insert opp;

        Opportunity_LI_Monthly_Booking__c monthlyBooking = new Opportunity_LI_Monthly_Booking__c(
            Month__c = date.parse('01.02.2020'),
            Amount__c = 2000,
            Opportunity__c = opp.id
        );
        insert monthlyBooking;

        Goal__c goal = new Goal__c(
            Name = 'Test Goal',
            Monatsziel__c = 2000,
            Monat__c = date.parse('01.02.2020'),
            Record_Type__c = 'All'
        );

        insert goal;

        Goal__c goalAfterInsert = [SELECT Id, Betrag_im_Zielmonat__c FROM Goal__c WHERE Id = :goal.Id LIMIT 1];
        System.debug(goalAfterInsert);
        System.assert(goalAfterInsert.Betrag_im_Zielmonat__c == 2000);

        goal = new Goal__c(
            Name = 'Test Goal',
            Monatsziel__c = 2000,
            Monat__c = date.parse('01.02.2020'),
            Record_Type__c = 'Consulting'
        );

        insert goal;

        goalAfterInsert = [SELECT Id, Betrag_im_Zielmonat__c FROM Goal__c WHERE Id = :goal.Id LIMIT 1];
        System.debug(goalAfterInsert);
        System.assert(goalAfterInsert.Betrag_im_Zielmonat__c == 2000);
    }
}