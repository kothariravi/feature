@isTest
private class TestUpdateMonthlyGoalTrigger {
    @isTest static void testInsertMonthlyBooking() {

        Goal__c monthlyGoal = new Goal__c(
            Name = 'Test Goal',
            Monatsziel__c = 2000,
            Monat__c = date.parse('01.02.2020'),
            Betrag_im_Zielmonat__c = 0
        );
        insert monthlyGoal;
        
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

        Goal__c goalBeforeInsert = [SELECT id, Betrag_im_Zielmonat__c, Monat__c FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c LIMIT 1];
        System.debug(goalBeforeInsert.Betrag_im_Zielmonat__c);

        Test.startTest();
        insert monthlyBooking;
        Test.stopTest();

        Goal__c goalAfterInsert = [SELECT id, Betrag_im_Zielmonat__c, Monat__c FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c LIMIT 1];
        System.debug(goalAfterInsert.Betrag_im_Zielmonat__c);

        System.assert(goalBeforeInsert.Betrag_im_Zielmonat__c < goalAfterInsert.Betrag_im_Zielmonat__c);
    }
}