trigger LaunchCampaignUserFlow on CampaignUserJunction__c (after insert, after update, after delete) {
    List<CampaignUserJunction__c> cujList = new List<CampaignUserJunction__c>();

    if (Trigger.isDelete) {
        for (CampaignUserJunction__c cujTrigger : Trigger.old) {
            cujList.add(cujTrigger);
        }
    } else {
        for (CampaignUserJunction__c cujTrigger : Trigger.new) {
            cujList.add(cujTrigger);
        }
    }

    for (CampaignUserJunction__c cuj : cujList) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', cuj.Kampagne__c);
        Flow.Interview.Update_Campaign_Users flow = new Flow.Interview.Update_Campaign_Users(params);
        flow.start();
    }
}