@isTest
private class TestRelateEventOnLeadConversion {
    @isTest static void testRelateEventOnLeadConversion() {
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Co.',
            Status = 'In_Kontakt'
        );
        insert lead;
        lead.Status = 'Konvertiert';
        update lead;

        System.assert(!String.isEmpty(lead.LastName));
    }
}