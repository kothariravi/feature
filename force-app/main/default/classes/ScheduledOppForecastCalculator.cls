global class ScheduledOppForecastCalculator implements Schedulable {
    global void execute(SchedulableContext ctxCalc) {
        OppForecastCalculator calc = new OppForecastCalculator();
        calc.updateOpenOpps();
    }
}