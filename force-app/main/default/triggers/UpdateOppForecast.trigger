trigger UpdateOppForecast on Opportunity (before insert, before update) {
    for (Opportunity opp : Trigger.new) {
        // OppForecastCalculator calc = new OppForecastCalculator();
        // calc.calculateOppForecast(opp);
        System.debug('Trigger is fired');
    }
}