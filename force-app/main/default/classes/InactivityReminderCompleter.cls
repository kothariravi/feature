global class InactivityReminderCompleter {
    public InactivityReminderCompleter(Id eventId) {
        List<EventRelation> evrList = [SELECT Id, RelationId, Relation.Type FROM EventRelation WHERE EventId = :eventId];
        System.debug(evrList);

        for (EventRelation evr : evrList) {
            System.debug(evr);

            String WhoId;
            String WhatId;

            if (evr.Relation.Type == 'Lead' || evr.Relation.Type == 'Contact') {
                WhoId = evr.RelationId;
            } else {
                WhatId = evr.RelationId;
            }

            List<Task> reminderTasks = [
                SELECT Id, Subject FROM Task
                WHERE Type = 'Inactivity Reminder' AND isClosed = false
                AND (WhoId = :WhoId OR WhatId = :WhatId)
            ];

            for (Task reminderTask : reminderTasks) {
                System.debug(reminderTask);
                reminderTask.Status = 'Abgeschlossen';
                update reminderTask;
            }
        }
    }
}