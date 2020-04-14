global class ScheduledInactivityReminder implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new LeadInactivityReminder());
        Database.executeBatch(new OppInactivityReminder());
        Database.executeBatch(new AccInactivityReminder()); 
    }
}
