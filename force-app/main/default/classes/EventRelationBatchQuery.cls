global class EventRelationBatchQuery implements Database.Batchable<AggregateResult> {

    global Iterable<AggregateResult> start(Database.BatchableContext ctxBtch) {
        AggregateResultIterable agrIterable = new AggregateResultIterable();
        System.debug(agrIterable);
        return agrIterable;
    }

    global void execute(Database.BatchableContext ctxBtch, List<AggregateResult> scope) {
        for (AggregateResult agr : scope) {
            Id agrId = (Id) agr.get('EventId');
            List<EventRelation> evrList = [SELECT Id, Relation.Type FROM EventRelation WHERE EventId = :agrId];

            Boolean hasBoth = false;
            Boolean hasLead = false;
            Boolean hasContact = false;

            for (EventRelation evr : evrList) {
                if (evr.Relation.Type == 'Lead') {
                    hasLead = true;
                } else if (evr.Relation.Type == 'Contact') {
                    hasContact = true;
                }
            }

            hasBoth = hasLead && hasContact;
            if (hasBoth) {
                System.debug(agr);
            }
        }
    }

    global void finish(Database.BatchableContext ctxBtch) {}

    global class AggregateResultIterable implements Iterable<AggregateResult> {
        global Iterator<AggregateResult> Iterator() {
            AggregateResultIterator agrIterator = new AggregateResultIterator();
            System.debug(agrIterator);
            return agrIterator;
        }
    }

    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get;set;}

        global AggregateResultIterator() {
            String query = 'SELECT EventId, count(RelationId) FROM EventRelation GROUP BY EventId HAVING count(RelationId) > 2';
            results = Database.query(query);
            System.debug('results: ' + results);
        }

        global boolean hasNext() {
            return results != null && !results.isEmpty() && index < results.size();
        }

        global AggregateResult next() {
            return results[index++];
        }
    }

}