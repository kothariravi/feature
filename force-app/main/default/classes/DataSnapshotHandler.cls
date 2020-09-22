global class DataSnapshotHandler {
    public static void takeSnapshot() {
        Date date4Weeks = Date.today() - 28;
        Date date1Year = Date.today() - 365;

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

    private static void takeOrgSnapshot() {
        AggregateResult agr;

        agr = [
            SELECT COUNT(Id), SUM(Amount), SUM(Forecast__c)
            FROM Opportunity
            WHERE isClosed = false
        ];
        Decimal openOpps = (Decimal) agr.get('expr0');
        Decimal totalPipeline = (Decimal) agr.get('expr1');
        Decimal totalForecast = (Decimal) agr.get('expr2');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'Pitch'
        ];
        Decimal openPitchVolume = (Decimal) agr.get('expr0');
        Decimal oppsInPitch = (Decimal) agr.get('expr1');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'Scoping'
        ];
        Decimal openScopingVolume = (Decimal) agr.get('expr0');
        Decimal oppsInScoping = (Decimal) agr.get('expr1');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'LoP'
        ];
        Decimal openLoPVolume = (Decimal) agr.get('expr0');
        Decimal oppsInLoP = (Decimal) agr.get('expr1');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE CreatedDate >= :(Date.today() - 7)
        ];
        Decimal newLeads = (Decimal) agr.get('expr0');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE Status = 'Call/Pitch Follow Up'
        ];
        Decimal leadsInPriorisiert = (Decimal) agr.get('expr0');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE Konvertiert_am__c >= :(Date.today() - 7)
        ];
        Decimal convertedLeads = (Decimal) agr.get('expr0');

        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Open_Opps__c = openOpps,
            Total_Pipeline__c = totalPipeline,
            Total_Forecast__c = totalForecast,
            Open_Pitch_Volume__c = openPitchVolume,
            Open_Scoping_Volume__c = openScopingVolume,
            Open_LoP_Volume__c = openLoPVolume,
            Opps_in_Pitch__c = oppsInPitch,
            Opps_in_Scoping__c = oppsInScoping,
            Opps_in_LoP__c = oppsInLoP,
            New_Leads__c = newLeads,
            Leads_in_Priorisiert__c = leadsInPriorisiert,
            Converted_Leads__c = convertedLeads,
            Type__c = 'Actual',
            Title__c = 'Org: ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year()
        );
        insert snap;
    }

    private static void takeUserSnapshot(SnapshotSettings__c userSetting) {
        String userId = userSetting.User_Id__c;
        AggregateResult agr;

        agr = [
            SELECT COUNT(Id), SUM(Amount), SUM(Forecast__c)
            FROM Opportunity
            WHERE isClosed = false AND OwnerId = :userId
        ];
        Decimal openOpps = (Decimal) agr.get('expr0');
        Decimal totalPipeline = (Decimal) agr.get('expr1');
        Decimal totalForecast = (Decimal) agr.get('expr2');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'Pitch' AND OwnerId = :userId
        ];
        Decimal openPitchVolume = (Decimal) agr.get('expr0');
        Decimal oppsInPitch = (Decimal) agr.get('expr1');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'Scoping' AND OwnerId = :userId
        ];
        Decimal openScopingVolume = (Decimal) agr.get('expr0');
        Decimal oppsInScoping = (Decimal) agr.get('expr1');

        agr = [
            SELECT SUM(Amount), COUNT(Id)
            FROM Opportunity
            WHERE isClosed = false AND StageName = 'LoP' AND OwnerId = :userId
        ];
        Decimal openLoPVolume = (Decimal) agr.get('expr0');
        Decimal oppsInLoP = (Decimal) agr.get('expr1');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE CreatedDate >= :(Date.today() - 7) AND OwnerId = :userId
        ];
        Decimal newLeads = (Decimal) agr.get('expr0');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE Status = 'Call/Pitch Follow Up' AND OwnerId = :userId
        ];
        Decimal leadsInPriorisiert = (Decimal) agr.get('expr0');

        agr = [
            SELECT COUNT(Id)
            FROM Lead
            WHERE Konvertiert_am__c >= :(Date.today() - 7) AND OwnerId = :userId
        ];
        Decimal convertedLeads = (Decimal) agr.get('expr0');

        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Open_Opps__c = openOpps,
            Total_Pipeline__c = totalPipeline,
            Total_Forecast__c = totalForecast,
            Open_Pitch_Volume__c = openPitchVolume,
            Open_Scoping_Volume__c = openScopingVolume,
            Open_LoP_Volume__c = openLoPVolume,
            Opps_in_Pitch__c = oppsInPitch,
            Opps_in_Scoping__c = oppsInScoping,
            Opps_in_LoP__c = oppsInLoP,
            New_Leads__c = newLeads,
            Leads_in_Priorisiert__c = leadsInPriorisiert,
            Converted_Leads__c = convertedLeads,
            OwnerId = userId,
            User_Snapshot__c = true,
            Type__c = 'Actual',
            Title__c = 'User: ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year() + ' (' + userSetting.Name + ')'
        );
        insert snap;
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