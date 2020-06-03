@IsTest
private class TestEventRelationHandler {
    @IsTest
    static void test() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Contact contact = new Contact(
            LastName = 'Test Contact',
            Account = acc
        );
        insert contact;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Pitch',
            CloseDate = Date.today(),
            Account = acc
        );
        insert opp;

        Task task = new Task(
            Subject = 'Test Task',
            ActivityDate = Date.today(),
            Type = 'Inactivity Reminder',
            WhatId = opp.Id
        );
        insert task;

        OpportunityContactRole cr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = contact.Id
        );
        insert cr;

        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp 2',
            StageName = 'Pitch',
            CloseDate = Date.today(),
            Account = acc
        );
        insert opp2;
        Test.setCreatedDate(opp2.Id, Datetime.now().addDays(-1));

        OpportunityContactRole cr2 = new OpportunityContactRole(
            OpportunityId = opp2.Id,
            ContactId = contact.Id
        );
        insert cr2;

        Event event = new Event(
            Subject = 'Test Event',
            ActivityDateTime = DateTime.now(),
            DurationInMinutes = 60
        );

        Test.startTest();
        insert event;
        Test.stopTest();

        Event eventAfterTest = [SELECT Id, WhatId FROM Event WHERE Id = :event.Id][0];
        System.debug(eventAfterTest);
        System.assert(eventAfterTest.WhatId == opp.Id);

        Task reminderTaskAfterTest = [SELECT Id, isClosed FROM Task WHERE Id = :task.Id][0];
        System.debug(reminderTaskAfterTest);
        System.assert(reminderTaskAfterTest.isClosed == true);
    }
}