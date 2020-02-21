trigger UpdateOppForecast on Opportunity (after insert) {
    OppForecastCalculator calc = new OppForecastCalculator();
    calc.calculateOppForecast();
}