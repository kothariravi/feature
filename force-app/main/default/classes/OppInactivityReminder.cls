global class OppInactivityReminder implements Database.Batchable<sObject>, Database.Stateful {

    private Static Date cutoff = Date.today() - 7;
    global Integer totalRecordsProcessed = 0;
    global Integer totalTasksCreated = 0;

    global final String query = 'SELECT Id, Letzte_Aktivitaet_Erstelldatum__c FROM Opportunity WHERE IsClosed = false AND StageName != \'Postponed\'';

    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext batchContext, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            if (opp.Letzte_Aktivitaet_Erstelldatum__c <= cutoff) {
                List<Task> openReminderTasks = [SELECT Id FROM Task WHERE Status = 'Offen' AND Type = 'Inactivity Reminder' AND WhatId = :opp.Id LIMIT 1];
                if (openReminderTasks.isEmpty()) {
                    Task reminderTask = new Task(
                        Subject = 'Test Reminder Task',
                        Type = 'Inactivity Reminder',
                        WhatId = opp.Id,
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
