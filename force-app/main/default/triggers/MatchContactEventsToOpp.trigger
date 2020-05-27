trigger MatchContactEventsToOpp on Event (after insert) {
    Integer i = 0;
    for (Event event : Trigger.new) {
        System.debug(event);

        if (event.WhatId == null) {
            if (Test.isRunningTest()) {
                Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Test Contact'][0];
                System.debug(contact);

                EventRelation evr = new EventRelation(
                    RelationId = contact.Id,
                    EventId = event.Id,
                    IsWhat = false
                );
                insert evr;
            }


            DateTime dt = DateTime.now();
            System.debug(dt);
            dt = dt.addSeconds(20);
            System.debug(dt);

            String schedule = dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            System.debug(schedule);

            String jobName = 'Scheduled Match Job: ' + schedule + ' (' + i + dt.millisecond() + ')';

            ScheduledMatchContactEventsToOpp scheduledClass = new ScheduledMatchContactEventsToOpp(event.Id);
            String jobID = system.schedule(jobName, schedule, scheduledClass);

            i++;
        }
    }
}