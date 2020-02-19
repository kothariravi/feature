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
        List<AggregateResult> monthlyBookingsByMonth = [
            SELECT Month__c, SUM(Amount__c) amount
            FROM Opportunity_LI_Monthly_Booking__c
            WHERE Month__c = :monthlyBooking.Month__c
            GROUP BY Month__c
        ];
        
    }
}
