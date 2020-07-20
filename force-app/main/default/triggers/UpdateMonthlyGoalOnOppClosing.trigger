trigger UpdateMonthlyGoalOnOppClosing on Opportunity (after update) {
    for (Opportunity OppNew : Trigger.new) {
        Opportunity OppOld = Trigger.oldMap.get(OppNew.Id);

        if (OppNew.StageName != OppOld.StageName && OppNew.StageName == 'Closed Won') {
            List<Opportunity_LI_Monthly_Booking__c> bookingList = [SELECT Id, Opportunity__c, Month__c FROM Opportunity_LI_Monthly_Booking__c WHERE Opportunity__c = :OppNew.Id];
            Database.executeBatch(new MonthlyGoalUpdater(bookingList), 35);
        }
    }
}