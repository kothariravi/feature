global class ScheduledInactivityReminder implements Schedulable {
    global void execute(SchedulableContext ctx) {
        InactivityReminder reminder = new InactivityReminder();
        reminder.checkAccounts();
        reminder.checkOpportunities();
        reminder.checkLeads();
    }
}
