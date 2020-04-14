global class OppForecastCalculator implements Database.Batchable<SObject> {

    List<Opportunity> allClosedOpps;
    List<Opportunity> allWonOpps;
    List<Opportunity> allOpenOpps;
    List<Opportunity> allOppsWithHistories;
    Set<Map<String, String>> oppHistoryTable;

    private final String query = 'SELECT id, amount, closedate, StageName, isClosed, isWon, leadSource FROM opportunity';

    public OppForecastCalculator() {
        // allClosedOpps = new List<Opportunity>();
        // for (Opportunity opp : allOpps) {
        //     if (opp.isClosed) {
        //         allClosedOpps.add(opp);
        //     }
        // }

        // allWonOpps = new List<Opportunity>();
        // for (Opportunity opp : allClosedOpps) {
        //     if (opp.isWon) {
        //         allWonOpps.add(opp);
        //     }
        // }

        // allOpenOpps = new List<Opportunity>();
        // for (Opportunity opp : allOpps) {
        //     if (!opp.isClosed) {
        //         allOpenOpps.add(opp);
        //     }
        // }
    }

    global Database.QueryLocator start(Database.BatchableContext ctxCalc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext ctxCalc, List<Opportunity> scope) {
        System.debug('in execute');
        // only calculate forecast for open opps?
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : scope) {
            Opportunity oppToUpdate = this.calculateOppForecast(opp);
            oppsToUpdate.add(oppToUpdate);
        }
        TriggerBypass.bypassUpdateOppForecast = TRUE;
        // update oppsToUpdate;
        TriggerBypass.bypassUpdateOppForecast = FALSE;
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
        System.debug('in calculate');
        List<Opportunity> oppHistoryEntries = [
            SELECT id, stageName, leadSource, (
                SELECT StageName
                FROM OpportunityHistories
                WHERE StageName = :oppToUpdate.StageName
            )
            FROM opportunity
            WHERE Id != :oppToUpdate.Id
                AND LeadSource = :oppToUpdate.LeadSource
        ];

        for (Opportunity opp : oppHistoryEntries) {
            System.debug(opp);
            for (OpportunityHistory oppHistory : opp.opportunityHistories) {
                System.debug(oppHistory);
            }
        }

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
            // aggregate queries
            Double calculatedCVR = allWonOpps.size() / (Double) allClosedOpps.size();
            calculatedAmount = oppToUpdate.amount * calculatedCVR;
        } else {
            Double calculatedCVR = allWonOppsSameParams.size() / (Double) allOppsSameParams.size();
            calculatedAmount = oppToUpdate.amount * calculatedCVR;
        }

        oppToUpdate.expected_amount__c = calculatedAmount;

        return oppToUpdate;
    }

    global void finish(Database.BatchableContext ctxCalc) {

    }
}