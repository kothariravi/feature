trigger GetAmountUponGoalCreation on Goal__c (before insert, before update) {
    for (Goal__c goal : Trigger.new) {
        try {
            AggregateResult monthlyBookingsByMonth;

            if (goal.Record_Type__c == 'All') {
                monthlyBookingsByMonth = [
                    SELECT Month__c, SUM(Amount__c)
                    FROM Opportunity_LI_Monthly_Booking__c
                    WHERE Month__c = :goal.Monat__c
                        AND opp_is_closed_won__c = TRUE
                    GROUP BY Month__c
                    LIMIT 1
                ];
            } else {
                monthlyBookingsByMonth = [
                    SELECT Month__c, SUM(Amount__c)
                    FROM Opportunity_LI_Monthly_Booking__c
                    WHERE Month__c = :goal.Monat__c
                        AND opp_is_closed_won__c = TRUE
                        AND Opportunity__r.Record_Type_Name__c = :goal.Record_Type__c
                    GROUP BY Month__c
                    LIMIT 1
                ];
            }

            Double monthlyBookingsAmountInMonth = (Double) monthlyBookingsByMonth.get('expr0');
            goal.Betrag_im_Zielmonat__c = monthlyBookingsAmountInMonth;
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
    }
}