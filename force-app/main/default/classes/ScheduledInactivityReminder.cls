global class ScheduledInactivityReminder implements Schedulable {
    global void execute(SchedulableContext ctxReminder) {
        InactivityReminder reminder = new InactivityReminder();
        reminder.checkAccounts();
        reminder.checkOpportunities();
        reminder.checkLeads();
    }
}
