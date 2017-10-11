/********************************************************************************************
* Class Name: EmailHandlerUtility
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/24/2017]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class EmailHandlerUtility {

    public void emailStatus(Database.BatchableContext BC){
        
        // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :BC.getJobId()];
        // Email the Batch Job's submitter that the Job is finished.
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: label.OrgWideAddressSRM];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Daily Team Member Assignation Job Status: ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}