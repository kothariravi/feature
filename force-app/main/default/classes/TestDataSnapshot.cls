@isTest
private class TestDataSnapshot {
    @isTest
    static void testDataSnapshot() {
        Account acc = new Account(
            Name = 'Test Acc'
        );
        insert acc;

        for (Integer i = 1; i <= 5; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Pitch',
                CloseDate = Date.today(),
                Amount = 100,
                Account = acc
            );
            insert opp;
        }

        SnapshotSettings__c setting = new SnapshotSettings__c(
            Name = 'Test',
            User_Id__c = UserInfo.getUserId()
        );
        insert setting;

        Test.startTest();
        System.schedule('ScheduledApexTest', '0 0 0 15 3 ? 2022', new ScheduledDataSnapshot());
        Test.stopTest();

        Data_Snapshot__c snap = [
            SELECT Id, Open_Opps__c, Total_Pipeline__c 
            FROM Data_Snapshot__c
            WHERE Type__c = 'Actual'
                AND User_Snapshot__c = false
            LIMIT 1
        ];

        System.assert(snap.Open_Opps__c == 5);
        System.assert(snap.Total_Pipeline__c == 500);
    }
}