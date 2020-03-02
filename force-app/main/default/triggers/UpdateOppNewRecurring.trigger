trigger UpdateOppNewRecurring on Opportunity (before insert, before update) {
    for (Opportunity opp : Trigger.new) {
        List<Opportunity> oppsFromAccount = [
            SELECT id
            FROM Opportunity
            WHERE AccountId = :opp.AccountId
                AND isWon = TRUE
        ];

        if (oppsFromAccount.size() > 0) {
            opp.type = 'Existing Business';
        } else {
            opp.type = 'New Business';
        }
    }
}