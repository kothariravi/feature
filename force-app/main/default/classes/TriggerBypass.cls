global class TriggerBypass {
    public static Boolean bypassUpdateOppForecast = FALSE;
    public static Boolean bypassUpdateOppNewRecurring = FALSE;

    public static void bypassAllOppTriggers(Boolean bypass) {
        bypassUpdateOppForecast = bypass;
        bypassUpdateOppNewRecurring = bypass;
    }
}
