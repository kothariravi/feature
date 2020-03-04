global class UpdateAllOppsNewRecurring implements Database.Batchable<sObject> {

    global final String query = 'SELECT Id, CloseDate, AccountId, IsWon, IsClosed FROM Opportunity';

    global Database.QueryLocator start(Database.BatchableContext ctxBtch) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext ctxBtch, List<Opportunity> scope) {
        Set<Opportunity> oppsToUpdateBeyondScope = new Set<Opportunity>();

        for (Opportunity oppToUpdate : scope) {
            List<Opportunity> wonOppsFromAccount = [
                SELECT Id, CloseDate, AccountId, IsWon, IsClosed
                FROM Opportunity
                WHERE AccountId = :oppToUpdate.accountId
                    AND IsWon = TRUE
                    AND Id != :oppToUpdate.Id
            ];

            oppToUpdate.type = 'New Business';

            if (!oppToUpdate.isClosed && wonOppsFromAccount.size() > 0) {
                oppToUpdate.type = 'Existing Business';
            } else {
                for (Opportunity wonOppFromAccount : wonOppsFromAccount) {
                    if (oppToUpdate.closeDate > wonOppFromAccount.closeDate) {
                        oppToUpdate.type = 'Existing Business';
                        wonOppFromAccount.type = 'New Business';
                        oppsToUpdateBeyondScope.add(wonOppFromAccount);
                    }
                }
            }
        }
        TriggerBypass.bypassAllOppTriggers(TRUE);
        update scope;
        update new List<Opportunity>(oppsToUpdateBeyondScope);
        TriggerBypass.bypassAllOppTriggers(FALSE);
    }

    global void finish(Database.BatchableContext ctxBtch) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                methodname, extendedstatus, jobtype, createddate, completeddate
            FROM AsyncApexJob
            WHERE Id = :ctxBtch.getJobId()
        ];
        System.debug(job);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { job.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Job Completed: ' + job.Id);
        mail.setPlainTextBody(String.valueOf(job));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
