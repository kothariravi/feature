global class MonthlyGoalUpdater {
    public static void updateMonthlyGoal(List<Opportunity_LI_Monthly_Booking__c> bookingList) {
        for (Opportunity_LI_Monthly_Booking__c monthlyBooking : bookingList) {
            Opportunity opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :monthlyBooking.Opportunity__c][0];
            String oppRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName();

            try {
                AggregateResult monthlyBookingsByMonth = [
                    SELECT Month__c, SUM(Amount__c)
                    FROM Opportunity_LI_Monthly_Booking__c
                    WHERE Month__c = :monthlyBooking.Month__c
                        AND opp_is_closed_won__c = TRUE
                    GROUP BY Month__c
                    LIMIT 1
                ];
                Double monthlyBookingsAmountInMonth = (Double) monthlyBookingsByMonth.get('expr0');
                Goal__c monthlyGoal = [SELECT Id FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c AND Record_Type__c = 'All' LIMIT 1];
                monthlyGoal.Betrag_im_Zielmonat__c = monthlyBookingsAmountInMonth;
                update monthlyGoal;
            } catch (QueryException e) {
                System.debug(e.getMessage());
            }

            try {
                AggregateResult monthlyBookingsByMonthRT = [
                    SELECT Month__c, SUM(Amount__c)
                    FROM Opportunity_LI_Monthly_Booking__c
                    WHERE Month__c = :monthlyBooking.Month__c
                        AND opp_is_closed_won__c = TRUE
                        AND Opportunity__r.RecordTypeId = :opp.RecordTypeId
                    GROUP BY Month__c
                    LIMIT 1
                ];
                Double monthlyBookingsAmountInMonthRT = (Double) monthlyBookingsByMonthRT.get('expr0');
                Goal__c monthlyGoalRT = [SELECT Id FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c AND Record_Type__c = :oppRecordTypeName LIMIT 1];
                monthlyGoalRT.Betrag_im_Zielmonat__c = monthlyBookingsAmountInMonthRT;
                update monthlyGoalRT;
            } catch (QueryException e) {
                System.debug(e.getMessage());
            }
        }
    }
}