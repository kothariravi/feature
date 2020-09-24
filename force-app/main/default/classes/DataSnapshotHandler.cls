global class DataSnapshotHandler {

    //-//-//-//-// INNER CLASSES //-//-//-//-//

    private class NoSuchRecordTypeException extends Exception {}

    //-//-//-//-// STATIC VARIABLES //-//-//-//-//

    private final static Date date4Weeks = Date.today() - 28;
    private final static Date date1Year = Date.today() - 365;
    private final static Id consultingOppRecordTypeId = getOppRecordTypeId('Consulting');

    //-//-//-//-// PUBLIC METHODS //-//-//-//-//

    public static void takeSnapshot() {

        takeOrgSnapshot();
        takeAvgSnapshot(date4Weeks, 'Avg 4 Weeks', false, null);
        takeAvgSnapshot(date1Year, 'Avg 1 Year', false, null);
        List<SnapshotSettings__c> userSettings = SnapshotSettings__c.getAll().values();
        for (SnapshotSettings__c userSetting : userSettings) {
            takeUserSnapshot(userSetting);
            takeAvgSnapshot(date4Weeks, 'Avg 4 Weeks', true, userSetting);
            takeAvgSnapshot(date1Year, 'Avg 1 Year', true, userSetting);
        }
    }

    //-//-//-//-// PRIVATE METHODS //-//-//-//-//
            
    private static void takeOrgSnapshot() {
        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Type__c = 'Actual',
            Title__c = 'Org: '
                    + Date.today().day()
                    + '.' + Date.today().month() + '.'
                    + Date.today().year()
        );
        loadOppValuesInSnapshot(snap, queryOpportunityValues(''));
        queryLeadCountsAndLoadInSnapshot(snap, '');
        insert snap;
    }

    private static void takeUserSnapshot(SnapshotSettings__c userSetting) {
        final String userIdString = userSetting.User_Id__c;
        final String additionalUserCondition = 'AND  OwnerId = \'' + userIdString + '\'';
        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Type__c = 'Actual',
            User_Snapshot__c = true,
            OwnerId = (Id) userIdString,
            Title__c = 'User: '
                    + Date.today().day()
                    + '.' + Date.today().month()
                    + '.' + Date.today().year()
                    + ' (' + userSetting.Name + ')'
        );
        loadOppValuesInSnapshot(snap, queryOpportunityValues(additionalUserCondition));
        queryLeadCountsAndLoadInSnapshot(snap, additionalUserCondition);
        insert snap;
    }

    private static List<AggregateResult> queryOpportunityValues(String additionalCondition) {
        String additionalConditionCompleteString =
                additionalCondition != '' ? ' ' + additionalCondition : additionalCondition;
        final String oppAggregateResultsQueryString =
                'SELECT StageName, COUNT(Id) oppsCount, SUM(Amount) totalAmount, SUM(Forecast__c) totalForecast'
                + ' FROM Opportunity'
                + ' WHERE Opportunity.RecordTypeId = :consultingOppRecordTypeId'
                +       ' AND ('
                +           'StageName = \'Pitch\''
                +           ' OR StageName = \'Scoping\''
                +           ' OR StageName = \'LoP\''
                +       ')'
                +       additionalConditionCompleteString
                + ' GROUP BY StageName';
        return Database.query(oppAggregateResultsQueryString);
    }

    private static void loadOppValuesInSnapshot(
            Data_Snapshot__c snapping, List<AggregateResult> groupedOpportunityAggregateResults) {
        Map<String,AggregateResult> oppAggregateResultByStage = new Map<String,AggregateResult>();
        for (AggregateResult opportunityAggregateResult : groupedOpportunityAggregateResults) {
            oppAggregateResultByStage.put(
                    (String) opportunityAggregateResult.get('StageName'), opportunityAggregateResult);
        }
        Decimal pitchForecast;
        Decimal scopingForecast;
        Decimal LoPForecast;
        try {
            AggregateResult pitchOppsAggregateResult = oppAggregateResultByStage.get('Pitch');
            snapping.Opps_in_Pitch__c = (Decimal) pitchOppsAggregateResult.get('oppsCount');
            snapping.Open_Pitch_Volume__c = (Decimal) pitchOppsAggregateResult.get('totalAmount');
            pitchForecast = (Decimal) pitchOppsAggregateResult.get('totalForecast');   
        } catch (Exception ignoredException) {
            System.debug('No Opportunities in Pitch Stage matching criteria');
        }
        try {
            AggregateResult scopingOppsAggregateResult = oppAggregateResultByStage.get('Scoping');
            snapping.Opps_in_Scoping__c = (Decimal) scopingOppsAggregateResult.get('oppsCount');
            snapping.Open_Scoping_Volume__c = (Decimal) scopingOppsAggregateResult.get('totalAmount');
            scopingForecast = (Decimal) scopingOppsAggregateResult.get('totalForecast');
        } catch (Exception ignoredException) {
            System.debug('No Opportunities in Scoping Stage matching criteria');
        }
        try {
            AggregateResult LoPOppsAggregateResult = oppAggregateResultByStage.get('LoP');
            snapping.Opps_in_LoP__c = (Decimal) LoPOppsAggregateResult.get('oppsCount');
            snapping.Open_LoP_Volume__c = (Decimal) LoPOppsAggregateResult.get('totalAmount');
            LoPForecast = (Decimal) LoPOppsAggregateResult.get('totalForecast');            
        } catch (Exception ignoredException) {
            System.debug('No Opportunities in LoP Stage matching criteria');
        }
        snapping.Open_Opps__c = decimalZeroForNull(snapping.Opps_in_Pitch__c)
                + decimalZeroForNull(snapping.Opps_in_Scoping__c)
                + decimalZeroForNull(snapping.Opps_in_LoP__c);
        snapping.Total_Pipeline__c = decimalZeroForNull(snapping.Open_Pitch_Volume__c)
                + decimalZeroForNull(snapping.Open_Scoping_Volume__c)
                + decimalZeroForNull(snapping.Open_LoP_Volume__c);
        snapping.Total_Forecast__c = decimalZeroForNull(pitchForecast)
                + decimalZeroForNull(scopingForecast)
                + decimalZeroForNull(LoPForecast);
    }

    private static void queryLeadCountsAndLoadInSnapshot(Data_Snapshot__c snapping, String additionalCondition) {
        final Date oneWeekAgo = Date.today() - 7;
        final String lastWeekLeadsQueryString =
                ('SELECT COUNT(Id) leadsCount'
                + ' FROM Lead'
                + ' WHERE CreatedDate >= :oneWeekAgo'
                + ' ' + additionalCondition).trim();
        final String leadsInPriorisiertQueryString =
                ('SELECT COUNT(Id) leadsCount'
                + ' FROM Lead'
                + ' WHERE Status = \'Call/Pitch Follow Up\''
                + ' ' + additionalCondition).trim();
        final String convertedLeadsQueryString =
                ('SELECT COUNT(Id) leadsCount'
                + ' FROM Lead'
                + ' WHERE Konvertiert_am__c >= :oneWeekAgo'
                + ' ' + additionalCondition).trim();
        snapping.New_Leads__c = (Decimal) Database.query(lastWeekLeadsQueryString)[0].get('leadsCount');
        snapping.Leads_in_Priorisiert__c = (Decimal) Database.query(leadsInPriorisiertQueryString)[0].get('leadsCount');
        snapping.Converted_Leads__c = (Decimal) Database.query(convertedLeadsQueryString)[0].get('leadsCount');
    }

    private static Id getOppRecordTypeId(String recordTypeDevName) {
        try {
            return Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeDevName).getRecordTypeId();
        } catch (Exception ignoredException) {
            throw new NoSuchRecordTypeException('Opportunity Record Type ' + recordTypeDevName + ' not found');
        }
    }

    private static Decimal decimalZeroForNull(Decimal input) {
        return (input == null) ? 0 : input;
    }

    private static void takeAvgSnapshot(Date dateRange, String snapTitle, Boolean isUserSnapshot, SnapshotSettings__c userSetting) {
        AggregateResult avgSnap;

        if (isUserSnapshot) {
            avgSnap = [
                SELECT AVG(Open_Opps__c),
                    AVG(Total_Pipeline__c),
                    AVG(Total_Forecast__c),
                    AVG(Open_Pitch_Volume__c),
                    AVG(Open_Scoping_Volume__c),
                    AVG(Open_LoP_Volume__c),
                    AVG(Opps_in_Pitch__c),
                    AVG(Opps_in_Scoping__c),
                    AVG(Opps_in_LoP__c),
                    AVG(New_Leads__c),
                    AVG(Leads_in_Priorisiert__c),
                    AVG(Converted_Leads__c)
                FROM Data_Snapshot__c
                WHERE Snapshot_Date__c >= :dateRange
                    AND Snapshot_Date__c < :Date.today()
                    AND Type__c = 'Actual'
                    AND User_Snapshot__c = true
                    AND OwnerId = :userSetting.User_Id__c
            ];
        } else {
            avgSnap = [
                SELECT AVG(Open_Opps__c),
                    AVG(Total_Pipeline__c),
                    AVG(Total_Forecast__c),
                    AVG(Open_Pitch_Volume__c),
                    AVG(Open_Scoping_Volume__c),
                    AVG(Open_LoP_Volume__c),
                    AVG(Opps_in_Pitch__c),
                    AVG(Opps_in_Scoping__c),
                    AVG(Opps_in_LoP__c),
                    AVG(New_Leads__c),
                    AVG(Leads_in_Priorisiert__c),
                    AVG(Converted_Leads__c)
                FROM Data_Snapshot__c
                WHERE Snapshot_Date__c >= :dateRange
                    AND Snapshot_Date__c < :Date.today()
                    AND Type__c = 'Actual'
                    AND User_Snapshot__c = false
            ];
        }

        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Open_Opps__c = (Decimal) avgSnap.get('expr0'),
            Total_Pipeline__c = (Decimal) avgSnap.get('expr1'),
            Total_Forecast__c = (Decimal) avgSnap.get('expr2'),
            Open_Pitch_Volume__c = (Decimal) avgSnap.get('expr3'),
            Open_Scoping_Volume__c = (Decimal) avgSnap.get('expr4'),
            Open_LoP_Volume__c = (Decimal) avgSnap.get('expr5'),
            Opps_in_Pitch__c = (Decimal) avgSnap.get('expr6'),
            Opps_in_Scoping__c = (Decimal) avgSnap.get('expr7'),
            Opps_in_LoP__c = (Decimal) avgSnap.get('expr8'),
            New_Leads__c = (Decimal) avgSnap.get('expr9'),
            Leads_in_Priorisiert__c = (Decimal) avgSnap.get('expr10'),
            Converted_Leads__c = (Decimal) avgSnap.get('expr11'),
            Type__c = 'Average'
        );

        if (isUserSnapshot) {
            snap.OwnerId = userSetting.User_Id__c;
            snap.User_Snapshot__c = true;
            snap.Title__c = snapTitle + ': ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year() + ' (' + userSetting.Name + ')';
        } else {
            snap.Title__c = snapTitle + ': ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year();
        }

        insert snap;
    }
}