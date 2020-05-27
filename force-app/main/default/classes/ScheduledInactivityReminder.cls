global class ScheduledInactivityReminder implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new LeadInactivityReminder(), 100);
        Database.executeBatch(new OppInactivityReminder(), 100);
        Database.executeBatch(new AccInactivityReminder(), 100);
    }
}