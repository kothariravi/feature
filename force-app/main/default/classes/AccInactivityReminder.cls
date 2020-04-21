global class AccInactivityReminder implements Database.Batchable<sObject>, Database.Stateful {

    global Integer totalRecordsProcessed = 0;
    global Integer totalTasksCreated = 0;
    global User fallbackOwner;

    global final String query = 'SELECT Id, Kundensegment__c, OwnerId, Letzte_Aktivitaet_Erstelldatum__c FROM Account WHERE Kundensegment__c IN (\'Gold\',\'Silber\',\'Bronze\')';

    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        fallbackOwner = [SELECT Id FROM User WHERE Alias = 'nnied'][0];
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext batchContext, List<Account> scope) {
        for (Account acc : scope) {
            if ((acc.Letzte_Aktivitaet_Erstelldatum__c < (Date.today() - 60) && (acc.Kundensegment__c == 'Gold' || acc.Kundensegment__c == 'Silber'))
                || (acc.Letzte_Aktivitaet_Erstelldatum__c < (Date.today() - 90) && acc.Kundensegment__c == 'Bronze')) {

                List<Task> openReminderTasks = [SELECT Id FROM Task WHERE IsClosed = false AND Type = 'Inactivity Reminder' AND WhatId = :acc.Id LIMIT 1];
                List<Task> openTasksInFuture = [SELECT Id FROM Task WHERE IsClosed = false AND ActivityDate >= TODAY AND WhatId = :acc.Id LIMIT 1];

                if (openReminderTasks.isEmpty() && openTasksInFuture.isEmpty()) {
                    Task reminderTask = new Task(
                        Subject = 'Reminder: Wiederaufnahme Kontakt',
                        Type = 'Inactivity Reminder',
                        WhatId = acc.Id,
                        OwnerId = acc.OwnerId,
                        ActivityDate = Date.today()
                    );
                    try {
                        insert reminderTask;
                    } catch (DmlException e) {
                        System.debug(e.getMessage());
                        reminderTask.OwnerId = fallbackOwner.Id;
                        insert reminderTask;
                    }
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
