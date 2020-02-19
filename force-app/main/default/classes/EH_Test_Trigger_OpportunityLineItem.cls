@isTest
private class EH_Test_Trigger_OpportunityLineItem {
 /*
 * Eigenherd GmbH, Robert Kutzner, 05.09.2018
 * A test class to test the Apex trigger EH_Trigger_OpportunityLineItem_AI_AU_BD
 */
	@isTest static void TestInsertOpportunityLineItem() {
        Test.startTest();        
        
        // Create Product, Pricebook, Account, Opportunity and Opportunity line item
         
       	Product2 prod = new Product2(Name = 'BriefingsTest', Family = 'BriefingsTest');
		insert prod; 
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Test Pricebook', isActive=true);
		insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 1200, IsActive = true);
		insert customPrice;
        
        Account acc = new Account(Name='TestAccount');
		insert acc;
        
        Opportunity opp = new Opportunity(	Name = 'Test Eigenherd Testklasse',
                                          	AccountId=acc.Id,
                                          	Probability = 50,
                                         	StageName = 'LoP',
                                          	Pricebook2Id = customPB.Id,
                                         	CloseDate = Date.Today() + 100);
        Database.SaveResult resultOpp = Database.insert(opp, false);
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(	ServiceDate = Date.Today() + 10,
                                                          	Leistungsenddatum__c = Date.Today() + 80,
                                       					 	OpportunityId = opp.Id,
                                                         	PricebookEntryId = customPrice.Id,
                                                            //Product2Id = '01t0Y0000099bHrQAI',
                                                            Quantity = 1,
     	                                                 	TotalPrice = 1000);
		Database.SaveResult resultOppLineItemInsert = Database.insert(oppLineItem, false);
        
        oppLineItem.Leistungsenddatum__c = Date.Today() + 70;
        Database.SaveResult resultOppLineItemUpdate = Database.update(oppLineItem, false);
        
        Database.DeleteResult resultOppLineItemDelete = Database.delete(oppLineItem);        
        
        Test.stopTest();
       
        // Verify 
        System.assert(resultOpp.isSuccess());
       	System.assert(resultOppLineItemInsert.isSuccess());
        System.assert(resultOppLineItemUpdate.isSuccess());
        System.assert(resultOppLineItemDelete.isSuccess());
    }
}