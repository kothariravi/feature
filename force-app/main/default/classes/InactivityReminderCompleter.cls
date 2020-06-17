global class InactivityReminderCompleter {
    public InactivityReminderCompleter(Id eventId) {
        List<EventRelation> evrList = [SELECT Id, RelationId, Relation.Type FROM EventRelation WHERE EventId = :eventId AND Relation.Type != 'User'];
        System.debug(evrList);

        for (EventRelation evr : evrList) {
            System.debug(evr);

            List<Task> reminderTasks = [
                SELECT Id, Subject FROM Task
                WHERE Type = 'Inactivity Reminder' AND isClosed = false
                AND (WhoId = :evr.RelationId OR WhatId = :evr.RelationId)
            ];

            for (Task reminderTask : reminderTasks) {
                System.debug(reminderTask);
                reminderTask.Status = 'Abgeschlossen';
                update reminderTask;
            }
        }
    }
}