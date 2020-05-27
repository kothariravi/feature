@IsTest
private class TestEventRelationBatchQuery {
    @isTest (seeAllData = TRUE)
    static void test() {
        Test.startTest();
        EventRelationBatchQuery evrBq = new EventRelationBatchQuery(); 
        Id batchId = Database.executeBatch(evrBq);
        Test.stopTest();

        System.debug(batchId);
    }
}