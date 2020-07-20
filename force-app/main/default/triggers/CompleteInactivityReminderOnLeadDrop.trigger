trigger CompleteInactivityReminderOnLeadDrop on Lead (after update) {
    for (Lead leadNew : Trigger.new) {
        Lead leadOld = Trigger.oldMap.get(leadNew.Id);

        if (leadNew.Status != leadOld.Status && leadNew.Status == 'Dropped') {
            List<Task> reminderTasks = [
                SELECT Id FROM Task
                WHERE Type = 'Inactivity Reminder' AND isClosed = false
                AND WhoId = :leadNew.Id
            ];

            for (Task reminderTask : reminderTasks) {
                System.debug(reminderTask);
                reminderTask.Status = 'Abgeschlossen';
                update reminderTask;
            }
        }
    }
}