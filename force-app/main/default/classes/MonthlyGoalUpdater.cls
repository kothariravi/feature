public class MonthlyGoalUpdater implements Database.Batchable<sObject> {
    public List<Opportunity_LI_Monthly_Booking__c> bookingList;

    public MonthlyGoalUpdater(List<Opportunity_LI_Monthly_Booking__c> bookingList) {
        this.bookingList = bookingList;
    }

    public List<Opportunity_LI_Monthly_Booking__c> start(Database.BatchableContext batchContext) {
        return bookingList;
    }

    public void execute(Database.BatchableContext batchContext, List<Opportunity_LI_Monthly_Booking__c> scope) {
        System.debug(scope.size());
        for (Opportunity_LI_Monthly_Booking__c monthlyBooking : scope) {
            System.debug(monthlyBooking);
            System.debug(monthlyBooking.Id);

            Opportunity opp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id = :monthlyBooking.Opportunity__c][0];
            String oppRecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName();

            try {
                Goal__c monthlyGoal = [SELECT Id FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c AND Record_Type__c = 'All' LIMIT 1];
                update monthlyGoal;
            } catch (QueryException e) {
                System.debug(e.getMessage());
            }

            try {
                Goal__c monthlyGoalRT = [SELECT Id FROM Goal__c WHERE Monat__c = :monthlyBooking.Month__c AND Record_Type__c = :oppRecordTypeName LIMIT 1];
                update monthlyGoalRT;
            } catch (QueryException e) {
                System.debug(e.getMessage());
            }
            System.debug('SOQL: ' + Limits.getQueries());
            System.debug('DML: ' + Limits.getDmlStatements());
        }
    }

    public void finish(Database.BatchableContext batchContext) {
        System.debug('batch apex finished');
    }
}