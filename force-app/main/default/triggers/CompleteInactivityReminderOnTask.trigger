trigger CompleteInactivityReminderOnTask on Task (after insert) {
    for (Task task : Trigger.new) {
        List<Task> reminderTasks = [
            SELECT Id, Subject FROM Task
            WHERE Type = 'Inactivity Reminder' AND isClosed = false
            AND (WhoId = :task.WhoId OR WhatId = :task.WhatId)
        ];
        for (Task reminderTask : reminderTasks) {
            System.debug(reminderTask);
            reminderTask.Status = 'Abgeschlossen';
            update reminderTask;
        }
    }
}