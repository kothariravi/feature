trigger UpdateMonthlyGoal on Opportunity_LI_Monthly_Booking__c (after insert, after update, after delete) {
    List<Opportunity_LI_Monthly_Booking__c> bookingList = new List<Opportunity_LI_Monthly_Booking__c>();

    if (Trigger.isDelete) {
        for (Opportunity_LI_Monthly_Booking__c monthlyBooking : Trigger.old) {
            bookingList.add(monthlyBooking);
        }
    } else {
        for (Opportunity_LI_Monthly_Booking__c monthlyBooking : Trigger.new) {
            bookingList.add(monthlyBooking);
        }
    }

    System.debug(bookingList);
    System.debug(bookingList.size());
    Database.executeBatch(new MonthlyGoalUpdater(bookingList), 35);
}