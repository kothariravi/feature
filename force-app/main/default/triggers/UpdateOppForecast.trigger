trigger UpdateOppForecast on Opportunity (before insert, before update) {

    if (TriggerBypass.bypassUpdateOppForecast) {
        return;
    }

    for (Opportunity opp : Trigger.new) {
        System.debug('Trigger UpdateOppForecast is fired');
        OppForecastCalculator calc = new OppForecastCalculator();
        // can stay w/o batch apex, more SOQL queries possible to reduce CPU Time
        calc.calculateOppForecast(opp);
        System.debug('Trigger Opp Expected Amount: ' + opp.expected_amount__c);
    }
}