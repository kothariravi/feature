global class OppInactivityReminder implements Database.Batchable<sObject>, Database.Stateful {

    global Integer totalRecordsProcessed = 0;
    global Integer totalTasksCreated = 0;

    global final String query = 'SELECT Id, OwnerId, Letzte_Aktivitaet_Erstelldatum__c FROM Opportunity WHERE IsClosed = false AND StageName != \'Postponed\'';

    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext batchContext, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            if (opp.Letzte_Aktivitaet_Erstelldatum__c < Date.today() - 7) {

                List<Task> openReminderTasks = [SELECT Id FROM Task WHERE IsClosed = false AND Type = 'Inactivity Reminder' AND WhatId = :opp.Id LIMIT 1];
                List<Task> openTasksInFuture = [SELECT Id FROM Task WHERE IsClosed = false AND ActivityDate >= TODAY AND WhatId = :opp.Id LIMIT 1];

                if (openReminderTasks.isEmpty() && openTasksInFuture.isEmpty()) {
                    Task reminderTask = new Task(
                        Subject = 'Reminder: Opportunity vorantreiben',
                        Type = 'Inactivity Reminder',
                        WhatId = opp.Id,
                        OwnerId = opp.OwnerId,
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
