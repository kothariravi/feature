public with sharing class UpdateAllOppsNewRecurring {
    public static void updateAllOppsNewRecurring() {

        List<Opportunity> allOpps = [
            SELECT id, closeDate, accountId, isWon, isClosed
            FROM Opportunity
        ];

        for (Opportunity oppToUpdate : allOpps) {
            List<Opportunity> wonOppsFromAccount = new List<Opportunity>();
            for (Opportunity oppToCompare : allOpps) {
                if (oppToUpdate.accountId == oppToCompare.accountId && oppToCompare.isWon && oppToUpdate.id != oppToCompare.id) {
                    wonOppsFromAccount.add(oppToCompare);
                }
            }

            oppToUpdate.type = 'New Business';

            if (!oppToUpdate.isClosed && wonOppsFromAccount.size() > 0) {
                System.debug('oppToUpdate is open & existing won opps in acc -> existing business');
                oppToUpdate.type = 'Existing Business';
            } else {
                for (Opportunity oppFromAccount : wonOppsFromAccount) {
                    if (oppToUpdate.closeDate > oppFromAccount.closeDate) {
                        System.debug('oppToUpdate.closeDate is later -> existing business');
                        oppToUpdate.type = 'Existing Business';
                        oppFromAccount.type = 'New Business';
                    }
                }
            }
        }
        TriggerBypass.bypassAllOppTriggers(TRUE);
        update allOpps;
        TriggerBypass.bypassAllOppTriggers(FALSE);
    }
}
