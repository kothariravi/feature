global class OppForecastCalculator {

    List<Opportunity> allOpps;
    List<Opportunity> allClosedOpps;
    List<Opportunity> allWonOpps;
    List<Opportunity> allOpenOpps;
    List<Opportunity> allOppsWithHistories;
    Set<Map<String, String>> oppHistoryTable;

    public OppForecastCalculator() {
        allOpps = [
            SELECT id, amount, closedate, StageName, isClosed, isWon, leadSource
            FROM opportunity
        ];

        allClosedOpps = new List<Opportunity>();
        for (Opportunity opp : allOpps) {
            if (opp.isClosed) {
                allClosedOpps.add(opp);
            }
        }

        allWonOpps = new List<Opportunity>();
        for (Opportunity opp : allClosedOpps) {
            if (opp.isWon) {
                allWonOpps.add(opp);
            }
        }

        allOpenOpps = new List<Opportunity>();
        for (Opportunity opp : allOpps) {
            if (!opp.isClosed) {
                allOpenOpps.add(opp);
            }
        }

        allOppsWithHistories = [
            SELECT id, stageName, leadSource, (SELECT stagename FROM opportunityHistories)
            FROM opportunity
        ];

        oppHistoryTable = new Set<Map<String, String>>();
        for (Opportunity opp : allOppsWithHistories) {
            for (OpportunityHistory oppHistory : opp.opportunityHistories) {
                oppHistoryTable.add(new Map<String, String>{
                    'opportunityId' => opp.id,
                    'oppLeadSource' => opp.leadSource,
                    'oppCurrentStage' => opp.stageName,
                    'oppHistoryStage' => oppHistory.stageName
                });
            }
        }
    }

    public void updateOpenOpps() {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : allOpenOpps) {
            Opportunity oppToUpdate = this.calculateOppForecast(opp);
            oppsToUpdate.add(oppToUpdate);
        }
        TriggerBypass.bypassUpdateOppForecast = TRUE;
        update oppsToUpdate;
        TriggerBypass.bypassUpdateOppForecast = FALSE;
    }

    public Opportunity calculateOppForecast(Opportunity oppToUpdate) {
        Set<Map<String, String>> allOppsSameParams = new Set<Map<String, String>>();
        for (Map<String, String> oppEntry : oppHistoryTable) {
            if (oppEntry.get('oppHistoryStage') == oppToUpdate.stageName
                && oppEntry.get('oppLeadSource') == oppToUpdate.leadSource
                && oppEntry.get('opportunityId') != oppToUpdate.Id
            ) {
                allOppsSameParams.add(oppEntry);
            }
        }
        System.debug('allOppsSameParams: ' + allOppsSameParams);

        Set<Map<String, String>> allWonOppsSameParams = new Set<Map<String, String>>();
        for (Map<String, String> oppEntry : allOppsSameParams) {
            if (oppEntry.get('oppCurrentStage') == 'Closed Won') {
                allWonOppsSameParams.add(oppEntry);
            }
        }
        System.debug('allWonOppsSameParams: ' + allWonOppsSameParams);

        Double calculatedAmount;
        if (allOppsSameParams.size() == 0) {
            // org-wide avg cvr
            Double calculatedCVR = allWonOpps.size() / (Double) allClosedOpps.size();
            calculatedAmount = oppToUpdate.amount * calculatedCVR;
        } else {
            Double calculatedCVR = allWonOppsSameParams.size() / (Double) allOppsSameParams.size();
            calculatedAmount = oppToUpdate.amount * calculatedCVR;
        }

        oppToUpdate.expected_amount__c = calculatedAmount;

        return oppToUpdate;
    }
}