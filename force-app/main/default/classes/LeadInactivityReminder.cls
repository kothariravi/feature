global class LeadInactivityReminder implements Database.Batchable<sObject>, Database.Stateful {

    global Integer totalRecordsProcessed = 0;
    global Integer totalTasksCreated = 0;

    global final String query = 'SELECT Id, Status, OwnerId, Letzte_Aktivitaet_Erstelldatum__c FROM Lead WHERE Status IN (\'In_Kontakt\', \'Call/Pitch Follow Up\')';

    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext batchContext, List<Lead> scope) {
        for (Lead lead : scope) {
            if ((lead.Letzte_Aktivitaet_Erstelldatum__c <= (Date.today() - 30) && lead.status == 'In_Kontakt')
                || (lead.Letzte_Aktivitaet_Erstelldatum__c <= (Date.today() - 7) && lead.status == 'Call/Pitch Follow Up')) {

                List<Task> openReminderTasks = [SELECT Id FROM Task WHERE IsClosed = false AND Type = 'Inactivity Reminder' AND WhoId = :lead.Id LIMIT 1];

                String taskSubject;
                if (lead.status == 'In_Kontakt') {
                    taskSubject = 'Reminder: Wiederaufnahme Kontakt';
                } else {
                    taskSubject = 'Reminder: Lead vorantreiben';
                }

                if (openReminderTasks.isEmpty()) {
                    Task reminderTask = new Task(
                        Subject = taskSubject,
                        Type = 'Inactivity Reminder',
                        WhoId = lead.Id,
                        OwnerId = lead.OwnerId,
                        ActivityDate = Date.today()
                    );
                    insert reminderTask;
                    totalTasksCreated++;
                }
            }
        }
        totalRecordsProcessed = totalRecordsProcessed + scope.size();
    }

    global void finish(Database.BatchableContext batchContext) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                methodname, extendedstatus, jobtype, createddate, completeddate
            FROM AsyncApexJob
            WHERE Id = :batchContext.getJobId()
        ];
        System.debug(job);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { job.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Job Completed: ' + job.Id);
        mail.setPlainTextBody(
            'Job: ' + String.valueOf(job) + '\n' +
            'totalRecordsProcessed: ' + totalRecordsProcessed + '\n' +
            'totalTasksCreated: ' + totalTasksCreated + ''
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
