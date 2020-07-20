global class DataSnapshotHandler {
    public static void takeSnapshot() {
        takeOrgSnapshot();
        takeUserSnapshot();
        takeAvg4WeeksSnapshot();
        takeAvg1YearSnapshot();
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
            WHERE CreatedDate >= :(Date.today() - 6)
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
            WHERE Konvertiert_am__c >= :(Date.today() - 6)
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

    private static void takeUserSnapshot() {
        List<SnapshotSettings__c> settings = SnapshotSettings__c.getAll().values();
        for (SnapshotSettings__c setting : settings) {
            String userId = setting.User_Id__c;
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
                WHERE CreatedDate >= :(Date.today() - 6) AND OwnerId = :userId
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
                WHERE Konvertiert_am__c >= :(Date.today() - 6) AND OwnerId = :userId
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
                Title__c = 'User: ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year() + ' (' + setting.Name + ')'
            );
            insert snap;
        }
    }

    private static void takeAvg4WeeksSnapshot() {
        AggregateResult snaps4Weeks = [
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
            WHERE Snapshot_Date__c >= :(Date.today() - 28)
                AND Snapshot_Date__c < :Date.today()
                AND Type__c = 'Actual'
                AND User_Snapshot__c = false
        ];

        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Open_Opps__c = (Decimal) snaps4Weeks.get('expr0'),
            Total_Pipeline__c = (Decimal) snaps4Weeks.get('expr1'),
            Total_Forecast__c = (Decimal) snaps4Weeks.get('expr2'),
            Open_Pitch_Volume__c = (Decimal) snaps4Weeks.get('expr3'),
            Open_Scoping_Volume__c = (Decimal) snaps4Weeks.get('expr4'),
            Open_LoP_Volume__c = (Decimal) snaps4Weeks.get('expr5'),
            Opps_in_Pitch__c = (Decimal) snaps4Weeks.get('expr6'),
            Opps_in_Scoping__c = (Decimal) snaps4Weeks.get('expr7'),
            Opps_in_LoP__c = (Decimal) snaps4Weeks.get('expr8'),
            New_Leads__c = (Decimal) snaps4Weeks.get('expr9'),
            Leads_in_Priorisiert__c = (Decimal) snaps4Weeks.get('expr10'),
            Converted_Leads__c = (Decimal) snaps4Weeks.get('expr11'),
            Type__c = 'Average',
            Title__c = 'Avg 4 Weeks: ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year()
        );
        insert snap;
    }

    private static void takeAvg1YearSnapshot() {
        AggregateResult snaps1Year = [
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
            WHERE Snapshot_Date__c >= :(Date.today() - 365)
                AND Snapshot_Date__c < :Date.today()
                AND Type__c = 'Actual'
                AND User_Snapshot__c = false
        ];

        Data_Snapshot__c snap = new Data_Snapshot__c(
            Snapshot_Date__c = Date.today(),
            Open_Opps__c = (Decimal) snaps1Year.get('expr0'),
            Total_Pipeline__c = (Decimal) snaps1Year.get('expr1'),
            Total_Forecast__c = (Decimal) snaps1Year.get('expr2'),
            Open_Pitch_Volume__c = (Decimal) snaps1Year.get('expr3'),
            Open_Scoping_Volume__c = (Decimal) snaps1Year.get('expr4'),
            Open_LoP_Volume__c = (Decimal) snaps1Year.get('expr5'),
            Opps_in_Pitch__c = (Decimal) snaps1Year.get('expr6'),
            Opps_in_Scoping__c = (Decimal) snaps1Year.get('expr7'),
            Opps_in_LoP__c = (Decimal) snaps1Year.get('expr8'),
            New_Leads__c = (Decimal) snaps1Year.get('expr9'),
            Leads_in_Priorisiert__c = (Decimal) snaps1Year.get('expr10'),
            Converted_Leads__c = (Decimal) snaps1Year.get('expr11'),
            Type__c = 'Average',
            Title__c = 'Avg 1 Year: ' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year()
        );
        insert snap;
    }
}