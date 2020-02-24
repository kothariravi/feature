global class ScheduledOppForecastCalculator implements Schedulable {
    global void execute(SchedulableContext ctx) {
        OppForecastCalculator calc = new OppForecastCalculator();
        calc.updateOpenOpps();
    }
}
