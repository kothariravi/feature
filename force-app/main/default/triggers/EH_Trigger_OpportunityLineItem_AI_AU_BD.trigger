trigger EH_Trigger_OpportunityLineItem_AI_AU_BD on OpportunityLineItem (after insert, after update, before delete) {
/*
 * Eigenherd GmbH, Robert Kutzner, 05.09.2018
 * A trigger to delete old and create new Opportunity_LI_Monthly_Booking__c objects to enable Opportunity forecasting
 * on a monthly base
 */
  
    if(Trigger.isDelete) {
        //delete the old monthly bookings for each line item that is going to be deleted
        for(OpportunityLineItem oppLineItem : Trigger.Old) {
            
            List<Opportunity_LI_Monthly_Booking__c> oldMonthlyBookingIdList = new List<Opportunity_LI_Monthly_Booking__c>(
           		[SELECT Id FROM Opportunity_LI_Monthly_Booking__c WHERE OpportunityLineItem_ID__c = : oppLineItem.Id]);
        
            if (oldMonthlyBookingIdList.size() > 0) {
                delete oldMonthlyBookingIdList;
    		}            
        }
    }
    else {
        for(OpportunityLineItem oppLineItem : Trigger.New) {
            
            //delete the old monthly bookings for each line item that has changed or was inserted
            List<Opportunity_LI_Monthly_Booking__c> oldMonthlyBookingIdList = new List<Opportunity_LI_Monthly_Booking__c>(
           		[SELECT Id FROM Opportunity_LI_Monthly_Booking__c WHERE OpportunityLineItem_ID__c = : oppLineItem.Id]);
        
            if(oldMonthlyBookingIdList.size() > 0) {
                delete oldMonthlyBookingIdList;
            }
            
            //afterwards create new monthly bookings based on the new line item data
            //but only if theres a start and end date on the Opp Line Item
            if(oppLineItem.ServiceDate != NULL && oppLineItem.Leistungsenddatum__c != NULL && oppLineItem.ServiceDate <= oppLineItem.Leistungsenddatum__c){
                
                List<Opportunity_LI_Monthly_Booking__c> newMonthlyBookingList = new List<Opportunity_LI_Monthly_Booking__c>();
            
                //for each month create a new monthly booking object with the data from the Opportunity line item
                //and calculate the partial value
               	
                //calculate the number of days and month between both dates and also calculate the amount per day
                Integer monthsBetween = oppLineItem.ServiceDate.monthsBetween(oppLineItem.Leistungsenddatum__c);
                Integer daysBetween = oppLineItem.ServiceDate.daysBetween(oppLineItem.Leistungsenddatum__c) + 1;
                Decimal amountPerDay = oppLineItem.TotalPrice / daysBetween; //oppLineItem.TotalPrice.divide(daysBetween, 5);
                Integer i = 0;
                
                //loop for each month
                while(i <= monthsBetween){
                    
                    Decimal amount = 0;
                    
                    if(monthsBetween == 0){
                        amount = oppLineItem.TotalPrice;
                    } else {
                    	Integer daysInMonth;
                        
                        //get the amount of days for this month
                        if(i == 0){	//if first month
                            Date lastDayOfMonth = Date.newInstance(oppLineItem.ServiceDate.year(), oppLineItem.ServiceDate.month(), 
                                                                   Date.daysInMonth(oppLineItem.ServiceDate.year(), oppLineItem.ServiceDate.month()));
                            daysInMonth = oppLineItem.ServiceDate.daysBetween(lastDayOfMonth) + 1;
                        } else if (i == monthsBetween){ //if last month
                            Date firstDayOfMonth = oppLineItem.Leistungsenddatum__c.toStartOfMonth();
                            daysInMonth = firstDayOfMonth.daysBetween(oppLineItem.Leistungsenddatum__c) + 1;
                        } else { //all other months between
                            daysInMonth = date.daysInMonth(oppLineItem.ServiceDate.toStartOfMonth().addMonths(i).year(),
                                                           oppLineItem.ServiceDate.toStartOfMonth().addMonths(i).month());
                        }
                        
                        //calculate the amount for this month
                        amount = daysInMonth * amountPerDay;   
                    }
                    
                     
                    //create Monthly Booking object and add the list of objects
                    newMonthlyBookingList.add(new Opportunity_LI_Monthly_Booking__c(
                        						Amount__c = amount.setScale(2),
                                                ServiceDate__c = oppLineItem.ServiceDate,
                                                Leistungsenddatum__c = oppLineItem.Leistungsenddatum__c,
                                                Discount__c = oppLineItem.Discount,
                                                //Forecast__c = 200, //formula
                                                Description__c = oppLineItem.Description,
                                                ListPrice__c = oppLineItem.ListPrice,
                                                Month__c = oppLineItem.ServiceDate.toStartOfMonth().addMonths(i),
                                                Opportunity__c = oppLineItem.OpportunityId,
                                                OpportunityLineItem_ID__c = oppLineItem.Id,
                                                Product2Id__c = oppLineItem.Product2Id,
                                                ProductCode__c = oppLineItem.ProductCode,
                                                Quantity__c = oppLineItem.Quantity,
                                                UnitPrice__c = oppLineItem.UnitPrice,
                                                Subtotal__c = oppLineItem.Subtotal,
                                                TotalPrice__c = oppLineItem.TotalPrice
                                            ));
                    
                    i++;
                }
                
                //insert list of objects
                if(newMonthlyBookingList.size() > 0) {
                    insert newMonthlyBookingList;
                }            
            }                   
        }
    } 
}