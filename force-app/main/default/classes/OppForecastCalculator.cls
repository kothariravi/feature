global class OppForecastCalculator {

    List<Opportunity> allOpps;
    List<Opportunity> allClosedOpps;
    List<Opportunity> allOpenOpps;
    List<AggregateResult> allOppsHistory;

    public OppForecastCalculator() {
        allOpps = [
            SELECT id, amount, closedate, StageName, isClosed, leadSource
            FROM opportunity
        ];

        allClosedOpps = new List<Opportunity>();
        for (Opportunity opp : allOpps) {
            if (opp.isClosed) {
                allClosedOpps.add(opp);
            }
        }

        allOpenOpps = new List<Opportunity>();
        for (Opportunity opp : allOpps) {
            if (!opp.isClosed) {
                allOpenOpps.add(opp);
            }
        }

        allOppsHistory = [
            SELECT stagename, count_distinct(opportunityid)
            FROM opportunityHistory
            GROUP BY stageName
        ];
    }

    public void updateOpenOpps() {
        for (Opportunity opp : allOpenOpps) {
            Opportunity oppToUpdate = this.calculateOppForecast(opp);
            update oppToUpdate;
        }
    }

    public Opportunity calculateOppForecast(Opportunity oppToUpdate) {
        List<Opportunity> allClosedOppsSameSource = new List<Opportunity>();
        for (Opportunity opp : allClosedOpps) {
            if (opp.leadSource == oppToUpdate.leadSource) {
                allClosedOppsSameSource.add(opp);
            }
        }

        List<Opportunity> allWonOppsSameSource = new List<Opportunity>();
        for (Opportunity opp : allClosedOppsSameSource) {
            if (opp.StageName == 'Closed Won') {
                allWonOppsSameSource.add(opp);
            }
        }

        Double calculatedCVR = allWonOppsSameSource.size() / (Double) allClosedOppsSameSource.size();
        Double calculatedAmount = oppToUpdate.amount * calculatedCVR;

        oppToUpdate.expected_amount__c = calculatedAmount;
        return oppToUpdate;
    }
}