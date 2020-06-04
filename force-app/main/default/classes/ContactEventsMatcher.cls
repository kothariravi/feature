global class ContactEventsMatcher {
    public ContactEventsMatcher(Id eventId) {
        Event event = new Event(Id = eventId);
        System.debug(event);

        List<EventRelation> evrList = [SELECT Id, RelationId FROM EventRelation WHERE EventId = :event.Id AND Relation.Type = 'Contact'];
        System.debug(evrList);

        Opportunity latestOpp = null;

        for (EventRelation evr : evrList) {
            System.debug(evr);

            List<OpportunityContactRole> crList = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE ContactId = :evr.RelationId];

            for (OpportunityContactRole cr : crList) {
                try {
                    Opportunity opp = [SELECT Id, Name, CreatedDate FROM Opportunity WHERE Id = :cr.OpportunityId And IsClosed = false][0];
                    if (latestOpp == null || opp.CreatedDate > latestOpp.CreatedDate) {
                        latestOpp = opp;
                    }
                } catch (System.ListException e) {
                    System.debug(e.getMessage());
                }
            }
        }
        if (latestOpp != null) {
            event.WhatId = latestOpp.Id;
            System.debug(event);
            update event;
        }
    }
}