global class ScheduledOppForecastCalculator implements Schedulable {
    global void execute(SchedulableContext ctxCalc) {
        OppForecastCalculator calc = new OppForecastCalculator();
        // adjust batch size based on amount of SOQL queries
        String batchId = Database.executeBatch(calc, 100);
        System.debug(batchId);
    }
}
