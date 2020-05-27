trigger RelateEventOnLeadConversion on Lead (before update) {
    for (Lead newLead : Trigger.new) {
        Lead oldLead = Trigger.oldMap.get(newLead.Id);

        if (newLead.Status != oldLead.Status && newLead.Status == 'Konvertiert') {
        // if (newLead.Status != oldLead.Status) {
            System.debug(newLead.ConvertedContactId);

            // this list is always empty -> no possibility to get events
            // EventRelation does not allow triggers
            List<EventRelation> evrList = [SELECT Id, EventId FROM EventRelation WHERE RelationId = :newLead.Id];
            for (EventRelation evr : evrList) {
                System.debug(evr);
                // Event event = new Event(Id = evr.EventId);
                // event.ConvertedContactId__c = newLead.ConvertedContactId;
                evr.RelationId = newLead.ConvertedContactId;
            }
            update evrList;
        }
    }
}