@isTest
private class TestOppForecastCalculator {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @isTest static void testScheduledMethod() {
        String[] stages = new List<String>();
        stages.add('Pitch');
        stages.add('Closed Won');
        stages.add('Closed Lost');

        String[] sources = new List<String>();
        sources.add('Netzwerk (CK)');
        sources.add('Importiert');
        sources.add('Vortrag (CK)');
        sources.add('Kundenempfehlung');

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i=1; i<=60; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Opportunity ' + i,
                CloseDate = Date.today(),
                Amount = 2000 * i,
                StageName = stages[Math.mod(i, stages.size())],
                LeadSource = sources[Math.mod(i, sources.size())],
                Loss_Reason__c = 'Other'
            );
            opps.add(opp);
        }
        insert opps;

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ScheduledOppForecastCalculator());
        Test.stopTest();

        List<Opportunity> oppsAfterUpdate = [SELECT id, expected_amount__c FROM opportunity];
        for (Opportunity opp : oppsAfterUpdate) {
            System.debug(opp.expected_amount__c);
        }
    }
}