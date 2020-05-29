trigger PostponeOppLineItems on Opportunity (after update) {
    for (Opportunity newOpp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);

        if (
            newOpp.Wiedervorlage_am__c != oldOpp.Wiedervorlage_am__c
            && newOpp.StageName == 'Postponed'
            && newOpp.Wiedervorlage_am__c != null
        ) {
            System.debug(newOpp);
            List<OpportunityLineItem> oppLineItems = [SELECT Id, ServiceDate, Leistungsenddatum__c FROM OpportunityLineItem WHERE OpportunityId = :newOpp.Id];
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                System.debug(oppLineItem);
                Integer daysPostponed = Date.today().daysBetween(newOpp.Wiedervorlage_am__c);
                System.debug(daysPostponed);

                Date referenceDate;
                if (oldOpp.Wiedervorlage_am__c == null) {
                    referenceDate = Date.today();
                } else {
                    referenceDate = oldOpp.Wiedervorlage_am__c;
                }

                Integer daysToStartDate = referenceDate.daysBetween(oppLineItem.ServiceDate);
                System.debug(daysToStartDate);

                Integer daysToEndDate = referenceDate.daysBetween(oppLineItem.Leistungsenddatum__c);
                System.debug(daysToEndDate);

                oppLineItem.ServiceDate = Date.today() + daysToStartDate + daysPostponed;
                oppLineItem.Leistungsenddatum__c = Date.today() + daysToEndDate + daysPostponed;
                update oppLineItem;
            }
        }
    }
}