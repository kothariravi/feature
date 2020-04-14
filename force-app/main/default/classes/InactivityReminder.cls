global class InactivityReminder {

    List<Task> allTasks;

    public InactivityReminder() {
        allTasks = [
            SELECT Id, WhatId, WhoId, isClosed, Subject
            FROM Task
        ];
    }

    public void checkAccounts() {
        List<Account> allAccs = [SELECT Id, Name, OwnerId, Kundensegment__c, LastActivityDate, CreatedDate FROM Account];

        for (Account acc : allAccs) {
            Boolean hasOpenReminderTasks = FALSE;
            Boolean needsReminder = FALSE;
            Date lastActivityDate;
            
            if (acc.lastActivityDate == null) {
                lastActivityDate = acc.createdDate.date();
            } else {
                lastActivityDate = acc.lastActivityDate;
            }
            
            for (Task task : allTasks) {
                if (task.whatId == acc.id && !task.isClosed && task.subject.contains('Kontaktieren:')) {
                    hasOpenReminderTasks = TRUE;
                    break;
                }
            }

            if (!hasOpenReminderTasks) {
                if (acc.kundensegment__c == 'Gold' || acc.kundensegment__c == 'Silber') {
                    if (lastActivityDate <= (Date.today() - 60)) {
                        needsReminder = TRUE;
                    }
                } else if (acc.kundensegment__c == 'Bronze') {
                    if (lastActivityDate <= (Date.today() - 90)) {
                        needsReminder = TRUE;
                    }
                }
            }

            if (needsReminder) {
                Date nextReminderDate = lastActivityDate;
                if (acc.kundensegment__c == 'Gold' || acc.kundensegment__c == 'Silber') {
                    nextReminderDate += 60;
                } else if (acc.kundensegment__c == 'Bronze') {
                    nextReminderDate += 90;
                }

                Task reminderTask = new Task(
                    ActivityDate = Date.today(),
                    OwnerId = acc.ownerId,
                    Priority = 'Normal',
                    Subject = 'Kontaktieren: ' + acc.name,
                    WhatId = acc.id
                );
                System.debug(reminderTask);
                insert reminderTask;
            }
        }
    }

    public void checkOpportunities() {
        List<Opportunity> allOpps = [SELECT Id, Name, OwnerId, IsClosed, StageName, LastActivityDate, CreatedDate FROM Opportunity];

        for (Opportunity opp : allOpps) {
            Boolean hasOpenReminderTasks = FALSE;
            Date lastActivityDate;
            
            if (opp.lastActivityDate == null) {
                lastActivityDate = opp.createdDate.date();
            } else {
                lastActivityDate = opp.lastActivityDate;
            }
            
            for (Task task : allTasks) {
                if (task.whatId == opp.id && !task.isClosed && task.subject.contains('Kontaktieren:')) {
                    hasOpenReminderTasks = TRUE;
                    break;
                }
            }

            if (!opp.isClosed && !hasOpenReminderTasks && lastActivityDate <= (Date.today() - 7) && opp.stageName != 'Postponed') {
                Date nextReminderDate = lastActivityDate + 7;

                Task reminderTask = new Task(
                    ActivityDate = Date.today(),
                    OwnerId = opp.ownerId,
                    Priority = 'Normal',
                    Subject = 'Kontaktieren: ' + opp.name,
                    WhatId = opp.id
                );
                System.debug(reminderTask);
                insert reminderTask;
            }
        }
    }

    public void checkLeads() {
        List<Lead> allLeads = [SELECT Id, Name, OwnerId, IsConverted, Status, LastActivityDate, CreatedDate FROM Lead];

        for (Lead lead : allLeads) {
            Boolean hasOpenReminderTasks = FALSE;
            Date lastActivityDate;
            
            if (lead.lastActivityDate == null) {
                lastActivityDate = lead.createdDate.date();
            } else {
                lastActivityDate = lead.lastActivityDate;
            }
            
            for (Task task : allTasks) {
                if (task.whoId == lead.id && !task.isClosed && task.subject.contains('Kontaktieren:')) {
                    hasOpenReminderTasks = TRUE;
                    break;
                }
            }

            if (!lead.isConverted && !hasOpenReminderTasks && lastActivityDate <= (Date.today() - 30) && lead.status != 'Postponed' && lead.status != 'Dropped') {
                Date nextReminderDate = lastActivityDate + 30;

                Task reminderTask = new Task(
                    ActivityDate = Date.today(),
                    OwnerId = lead.ownerId,
                    Priority = 'Normal',
                    Subject = 'Kontaktieren: ' + lead.name,
                    WhoId = lead.id
                );
                System.debug(reminderTask);
                insert reminderTask;
            }
        }
    }
}
