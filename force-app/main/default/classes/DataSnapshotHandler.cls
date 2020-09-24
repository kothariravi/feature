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
        for (SnapshotSettings__c userSetting : SnapshotSettings__c.getAll().values()) {
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
        final String leadsInPrioQueryString =
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
        snapping.Leads_in_Priorisiert__c = (Decimal) Database.query(leadsInPrioQueryString)[0].get('leadsCount');
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

    private static void takeAvgSnapshot(
            Date dateRangeStart, String snapTitle, Boolean isUserSnapshot, SnapshotSettings__c userSetting) {
        final Date dateToday = Date.today();
        final String userIdString = isUserSnapshot ? userSetting.User_Id__c : null;
        final String userQueryConditions = isUserSnapshot ? 'true AND OwnerId = \'' + userIdString + '\'' : 'false';
        String averageSnapshotQueryString =
                'SELECT AVG(Open_Opps__c) oppsCountAVG,'
                +      ' AVG(Total_Pipeline__c) totalAmountAVG,'
                +      ' AVG(Total_Forecast__c) totalForecastAVG,'
                +      ' AVG(Open_Pitch_Volume__c) PitchAVG,'
                +      ' AVG(Open_Scoping_Volume__c) ScopingAVG,'
                +      ' AVG(Open_LoP_Volume__c) LoPAVG,'
                +      ' AVG(Opps_in_Pitch__c) PitchCountAVG,'
                +      ' AVG(Opps_in_Scoping__c) ScopingCountAVG,'
                +      ' AVG(Opps_in_LoP__c) LoPCountAVG,'
                +      ' AVG(New_Leads__c) newLeadsAVG,'
                +      ' AVG(Leads_in_Priorisiert__c) prioLeadsAVG,'
                +      ' AVG(Converted_Leads__c) convertedLeadsAVG'
                + ' FROM Data_Snapshot__c'
                + ' WHERE Snapshot_Date__c >= :dateRangeStart'
                +       ' AND Snapshot_Date__c < :dateToday'
                +       ' AND Type__c = \'Actual\''
                +       ' AND User_Snapshot__c = ' + userQueryConditions;
        AggregateResult averageSnapshotResult = Database.query(averageSnapshotQueryString);
        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = dateToday,
            Type__c = 'Average',
            Open_Opps__c = (Decimal) averageSnapshotResult.get('oppsCountAVG'),
            Total_Pipeline__c = (Decimal) averageSnapshotResult.get('totalAmountAVG'),
            Total_Forecast__c = (Decimal) averageSnapshotResult.get('totalForecastAVG'),
            Open_Pitch_Volume__c = (Decimal) averageSnapshotResult.get('PitchAVG'),
            Open_Scoping_Volume__c = (Decimal) averageSnapshotResult.get('ScopingAVG'),
            Open_LoP_Volume__c = (Decimal) averageSnapshotResult.get('LoPAVG'),
            Opps_in_Pitch__c = (Decimal) averageSnapshotResult.get('PitchCountAVG'),
            Opps_in_Scoping__c = (Decimal) averageSnapshotResult.get('ScopingCountAVG'),
            Opps_in_LoP__c = (Decimal) averageSnapshotResult.get('LoPCountAVG'),
            New_Leads__c = (Decimal) averageSnapshotResult.get('newLeadsAVG'),
            Leads_in_Priorisiert__c = (Decimal) averageSnapshotResult.get('prioLeadsAVG'),
            Converted_Leads__c = (Decimal) averageSnapshotResult.get('convertedLeadsAVG')
        );
        if (isUserSnapshot) {
            snap.OwnerId = (Id) userIdString;
            snap.User_Snapshot__c = true;
            snap.Title__c = snapTitle + ': '
                    + Date.today().day() + '.'
                    + Date.today().month() + '.'
                    + Date.today().year() + ' ('
                    + userSetting.Name + ')';
        } else {
            snap.Title__c = snapTitle
                    + ': ' + Date.today().day() + '.'
                    + Date.today().month() + '.'
                    + Date.today().year();
        }
        insert snap;
    }
}