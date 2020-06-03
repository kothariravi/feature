trigger CompleteInactivityReminderOnTask on Task (after insert, after update) {
    for (Task task : Trigger.new) {
        if (task.Type != 'Inactivity Reminder') {
            Boolean proceedOnUpdate = false;

            if (Trigger.isUpdate) {
                Task oldTask = Trigger.oldMap.get(task.Id);
                if (task.ActivityDate != oldTask.ActivityDate) {
                    proceedOnUpdate = true;
                }
            }

            if ((Trigger.isInsert || proceedOnUpdate) && task.ActivityDate != null) {
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
    }
}