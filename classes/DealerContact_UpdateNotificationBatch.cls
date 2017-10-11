/********************************************************************************************
* Class Name: DealerContact_UpdateNotificationBatch
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/2/2017]
* Requirement Description:  W-004398
* Story includes : As a ASM aI want to receive a notification when dealer contacts are updated, added, or deactivated in DRM so that I can be informed of any changes in dealer contacts
* Date Modified                Modified By                  Description of the update
* [08/16/2017]               Rajeev Arya (Deloitte)        W-006712:SRM Batches: Filter for Active Dealers
* [09/04/2017]               Rajeev Arya (Deloitte)        W-006695:SRM_BR_BS_009 – Automated Notifications: New Dealer Record
* [09/14/2017]               Rajeev Arya (Deloitte)        W-007049:Dealer Contact Update Email Sent to ASMs which are not assigned to those dealers
***********************************************************************************************/

global class DealerContact_UpdateNotificationBatch implements Database.Batchable<SObject>, Database.Stateful{
    
    //Map to check the email of the account and related contacts
    Map<ID, Set<String>> mapOwnerIdToAccName = new Map<ID, Set<String>>();   
    Map<String,Id> mapDealerNameToId = new Map<String,Id>();
    Map<ID,String> mapAccIdToAccNum = new Map<ID,String>(); //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
    List<String> accLinkVal = new  List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Query to check the contacts been updated related to the account
        //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
        //[08/16/2017]-Rajeev Arya (Deloitte)-W-006712
        String query = 'SELECT Id, Name,Account.Ownerid,Account.AccountNumber,Account.name, ';
        query += 'CreatedBy.Name FROM Contact where lastmodifieddate=today ';
        query += 'and Account.status__c = \'Active\' and lastmodifiedby.Profile.UserLicense.Name = \'Partner Community Login\'';
        return Database.getQueryLocator(query);
    }
    
    //Mapping the account owner i.e ASM email with list of contact that have been modified
    global void execute(Database.BatchableContext BC, List<Contact> lstContact)
    {
        try{
        // Collect data in map which includes account owner ID with the list of accounts whose contacts were recently modified
            Set<String> setDealerNames = new set<String>();
            for (Contact cont : lstContact) {
                mapDealerNameToId.put(cont.Account.name,cont.Account.Id);
                mapAccIdToAccNum.put(cont.Account.Id, cont.Account.AccountNumber); //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
                
                if(!mapOwnerIdToAccName.containsKey(cont.Account.OwnerId)){
                	mapOwnerIdToAccName.put(cont.Account.OwnerId, new set<String>());
                }
                setDealerNames = mapOwnerIdToAccName.get(cont.Account.OwnerId);
                setDealerNames.add(cont.Account.name);
                mapOwnerIdToAccName.put(cont.Account.OwnerId, setDealerNames);
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'DealerContact_UpdateNotificationBatch', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Batch Apex' , Log_Severity__c = 'HIGH') ; 
            if(errLog!=null)
                insert errLog;
        }
    }  
    
    //Sending email when the job finish includes all the account name whose contact been recently modified
    global void finish(Database.BatchableContext BC)
    {    
        List<Document> docList =[SELECT Id,DeveloperName from Document where DeveloperName='Double_Logo']; 
        String docId;
        String fullFileURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/';
        if(docList.size()>0){
            docId=docList[0].Id;
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: label.OrgWideAddressSRM];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id OwnerId : mapOwnerIdToAccName.keyset())
        {                  
            accLinkVal = new List<String>(); //[09/14/2017]-Rajeev Arya (Deloitte)-W-007049
            Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
            
            email.setSubject('Dealer Contact Updates');
            set<String> setDealers = new set<String>(mapOwnerIdToAccName.get(OwnerId));            
            for(String accName : setDealers){
                if(mapDealerNameToId.containsKey(accName) && mapDealerNameToId.get(accName)!=null){
                    //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
                    accLinkVal.add(mapAccIdToAccNum.get(mapDealerNameToId.get(accName)) + ' <a href="'+fullFileURL+mapDealerNameToId.get(accName)+'">'+accName+'</a><br>');
                } 
            }
            string body= string.join(accLinkVal ,'');
            String messageBody = '<html><body style="font-family: arial; font-size: 12pt;"><img id="Logo" src="' +System.URL.getSalesforceBaseURL().toExternalForm()+'/servlet/servlet.ImageServer?id='+docId+'&oid='+UserInfo.getOrganizationId()+ '" height="80" width="450">';
            messageBody += '<br><br><font size="3" color="blue">'+ body+'</font><br/>The above referenced dealer(s) have updated their dealership contacts. Please log into SRM Salesforce to view the updated information.<br><br>Thank you,<br><br>TFS/LFS SRM Salesforce Team <br><br>Do not reply to this message. This email was sent from a notification-only address that cannot accept incoming email. </body></html>';
            email.setHtmlBody(messageBody);
            email.setTargetObjectId(OwnerId);
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setSaveAsActivity(false);
            mails.add(email);
        }
        
        if(mails != null && !mails.isEmpty()){
        	Messaging.sendEmail(mails);
        }
        
    }
}