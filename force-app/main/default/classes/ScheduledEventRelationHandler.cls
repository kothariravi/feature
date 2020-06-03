global class ScheduledEventRelationHandler implements Schedulable {
    private Event event;

    public ScheduledEventRelationHandler(Event event) {
        this.event = event;
    }

    global void execute(SchedulableContext schedulableContext) {
        if (event.WhatId == null) {
            ContactEventsMatcher cem = new ContactEventsMatcher(this.event.Id);
        }
        InactivityReminderCompleter irc = new InactivityReminderCompleter(this.event.Id);
    }
}