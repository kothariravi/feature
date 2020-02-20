@isTest
private class TestUpdateMonthlyGoalTrigger {
    @isTest static void testInsertMonthlyBooking() {

        Goal__c monthlyGoal = new Goal__c(
            Name = 'asd',
            Monatsziel__c = 2000,
            Monat__c = date.parse('01.02.2020'),
            Betrag_im_Zielmonat__c = 0
        );
        insert monthlyGoal;

        Opportunity_LI_Monthly_Booking__c monthlyBooking = new Opportunity_LI_Monthly_Booking__c(
            Month__c = date.parse('01.02.2020'),
            Amount__c = 2000
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