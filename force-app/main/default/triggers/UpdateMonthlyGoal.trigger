trigger UpdateMonthlyGoal on Opportunity_LI_Monthly_Booking__c (after insert, after update, before delete) {
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

    for (Opportunity_LI_Monthly_Booking__c monthlyBooking : bookingList) {
        System.debug(monthlyBooking);
    }
}