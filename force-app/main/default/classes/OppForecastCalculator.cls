global class OppForecastCalculator {

    List<Opportunity> allOpps;
    List<Opportunity> allClosedOpps;
    List<Opportunity> allWonOpps;
    List<Opportunity> allOpenOpps;

    public OppForecastCalculator() {
        allOpps = [
            SELECT id, amount, closedate, StageName, isClosed
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
            if (opp.StageName == 'Closed Won') {
                allWonOpps.add(opp);
            }
        }

        allOpenOpps = new List<Opportunity>();
        for (Opportunity opp : allOpps) {
            if (!opp.isClosed) {
                allOpenOpps.add(opp);
            }
        }
    }

    public void calculateOppForecast() {
        System.debug((allWonOpps.size() / (Double) allClosedOpps.size())*100 + '%');
    }
}