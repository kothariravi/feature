global class ScheduledMatchContactEventsToOpp implements Schedulable {
    private Id eventId;

    public ScheduledMatchContactEventsToOpp(Id eventId) {
        this.eventId = eventId;
    }

    global void execute(SchedulableContext schedulableContext) {
        ContactEventsMatcher cem = new ContactEventsMatcher(this.eventId);
    }
}