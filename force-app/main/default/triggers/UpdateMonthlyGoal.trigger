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
        AggregateResult monthlyBookingsByMonth = [
            SELECT Month__c, SUM(Amount__c)
            FROM Opportunity_LI_Monthly_Booking__c
            WHERE Month__c = :monthlyBooking.Month__c
            GROUP BY Month__c
            LIMIT 1
        ];
        Double monthlyBookingsAmountInMonth = (Double) monthlyBookingsByMonth.get('expr0');
        Goal__c monthlyGoal = [SELECT id, Betrag_im_Zielmonat__c, Monat__c FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c LIMIT 1];
        monthlyGoal.Betrag_im_Zielmonat__c = monthlyBookingsAmountInMonth;
        update monthlyGoal;
    }
}
