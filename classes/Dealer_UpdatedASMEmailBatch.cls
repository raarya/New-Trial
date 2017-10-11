/********************************************************************************************************
* @author         Deloitte
* @description    UpdateASMDealerEmailBatch Apex class used to send email to the ASM of the TFS Area's when a new Dealer is added to his Area (through out the day).
* @date           2017-02-10
*********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Date                         Developer                         Description 
 * ------------------------------------------------------------------------------------------------------
                                                                        Initial version
 * [08/16/2017]               Rajeev Arya (Deloitte)        W-006712:SRM Batches: Filter for Active Dealers
 * [09/04/2017]               Rajeev Arya (Deloitte)        W-006695:SRM_BR_BS_009 – Automated Notifications: New Dealer Record                                                                       
*/

global class Dealer_UpdatedASMEmailBatch implements Database.Batchable<sObject>{
    
    global database.querylocator start(Database.BatchableContext BC)
    {   
		//[08/16/2017]-Rajeev Arya (Deloitte)-W-006712
        //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
        string query = 'SELECT Name,AccountNumber, Ownerid FROM Account where ';
        query += '(Area_Changed_Date__c = TODAY OR (Area_Changed_Date__c = NULL AND CreatedDate = TODAY)) AND ASM__c != \'ASM Unassigned\' ';
        query += 'AND recordtype.developerName !=\'Location\' and Status__c = \'Active\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, Sobject[] listDealer)
    {       
        String DealerNames = TFS_Utility.BLANK;
        map<ID, String> mapOwnerIdToDealers = new map<ID, String>();
        String docId=TFS_Utility.BLANK;
        if(listDealer!=null){
            List<Document> docList =[SELECT Id,DeveloperName from Document where DeveloperName= :TFS_Utility.DOUBLE_LOGO]; 
            if(docList.size()>0){
                docId=docList[0].Id;
            }
            for (Account acc : (List<Account>)listDealer) {
                
                if(mapOwnerIdToDealers.containsKey(acc.Ownerid)){
                    DealerNames = mapOwnerIdToDealers.get(acc.Ownerid);
                    DealerNames = DealerNames + TFS_Utility.COMMA + acc.AccountNumber+TFS_Utility.BLANK_SPACE+acc.Name;
                    mapOwnerIdToDealers.put(acc.Ownerid, DealerNames);
                }
                else{
                    DealerNames =  acc.AccountNumber+TFS_Utility.BLANK_SPACE+acc.name;
                    mapOwnerIdToDealers.put(acc.Ownerid, DealerNames);
                }
            } 
            String messageBody;
            Messaging.SingleEmailMessage email;
            List<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: label.OrgWideAddressSRM];
            for(String OwnerId : mapOwnerIdToDealers.keySet()){
                email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(OwnerId);
                DealerNames = mapOwnerIdToDealers.get(OwnerId);
                email.setSubject('New Dealers in SRM');
                messageBody =  '<html><body style="font-family: arial; font-size: 12pt;"><img id="Logo" src="'+System.URL.getSalesforceBaseURL().toExternalForm()+'/servlet/servlet.ImageServer?id='+docId+'&oid='+UserInfo.getOrganizationId()+'" height="80" width="450">' +'<br/><br/>';
                messageBody += '<font size="3" color="blue">'+DealerNames.replaceall(';', '<br>')+'</font><br/><br/>The above referenced dealers have been added to your Area.  Please log into SRM Salesforce to view the new dealer information.<br/><br/>Thank you,<br><br/>TFS/LFS SRM Salesforce Team<br><br> Do not reply to this message. This email was sent from a notification-only address that cannot accept incoming email.</body></html>';
                email.setHtmlBody(messageBody);
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
    
    global void finish(Database.BatchableContext BC) 
    {
    
    } 
}