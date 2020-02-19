@isTest
private class TestTriggerLaunchCampaignFlow {
    @isTest static void testInsertCampaignUserJunction() {
        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;
        
        Profile sysadmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE ProfileId = :sysadmin.Id AND isActive = TRUE LIMIT 1];

        CampaignUserJunction__c cuj = new CampaignUserJunction__c(
            User__c = u.Id,
            Kampagne__c = c.Id
        );
        
        Test.startTest();
        insert cuj;
        Test.stopTest();
        
		Campaign cAfterInsert = [SELECT users_on_campaign__c FROM campaign WHERE id = :c.id];

        System.assert(!String.isEmpty(cAfterInsert.users_on_campaign__c));
    }
}