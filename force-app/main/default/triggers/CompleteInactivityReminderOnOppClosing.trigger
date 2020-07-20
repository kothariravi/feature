trigger CompleteInactivityReminderOnOppClosing on Opportunity (after update) {
    for (Opportunity oppNew : Trigger.new) {
        Opportunity oppOld = Trigger.oldMap.get(oppNew.Id);

        if (oppNew.StageName != oppOld.StageName && (oppNew.StageName == 'Closed Won' || oppNew.StageName == 'Closed Lost')) {
            List<Task> reminderTasks = [
                SELECT Id FROM Task
                WHERE Type = 'Inactivity Reminder' AND isClosed = false
                AND WhatId = :oppNew.Id
            ];

            for (Task reminderTask : reminderTasks) {
                System.debug(reminderTask);
                reminderTask.Status = 'Abgeschlossen';
                update reminderTask;
            }
        }
    }
}