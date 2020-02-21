global class OppForecastCalculator {

    List<Opportunity> allWonOpps;
    List<Opportunity> allLostOpps;

    public OppForecastCalculator() {
    }

    public void calculateOppForecast() {
        allWonOpps = [
            SELECT id, amount, closedate
            FROM opportunity
            WHERE stagename = 'Closed Won'
        ];
        allLostOpps = [
            SELECT id, amount, closedate
            FROM opportunity
            WHERE stagename = 'Closed Lost'
        ];
        System.debug(allWonOpps.size() / allLostOpps.size());
    }
}
