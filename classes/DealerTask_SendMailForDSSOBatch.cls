/********************************************************************************************
* Class Name: DealerTask_SendMailForDSSOBatch
* Author: Rajeev Arya (Deloitte)
* Date: [02/21/2017]
* Requirement Description:  W-004003
* Story includes : Receive notifications when Dealers are created without DSSO Name and/or Area ID
* Date Modified                Modified By                  Description of the update
* [04/05/2017]               Rajeev Arya (Deloitte)        Adding the double logo to the email notification
* [08/16/2017]               Rajeev Arya (Deloitte)        W-006712:SRM Batches: Filter for Active Dealers
***********************************************************************************************/

global class DealerTask_SendMailForDSSOBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    //Map to check the email of the account and related contacts
    public map<ID, User> mapDSSOAAIdToEmail = new map<ID, User>();
    public map<ID, String> mapOwnerIdToDealers = new map<ID, String>();
    public set<ID> setOwnerId = new set<ID>();
    public map<ID, set<String>> mapOwnerIdToDSSOAAEmails = new map<ID, set<String>>();
    public String[] strHQAdminMails = new String[]{};
    public String strHQAdminDealers = TFS_Utility.BLANK;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        
        //Query to check the tasks created on Dealers for today with the specific subjects
        set<String> setSubjects = new set<String>();
        setSubjects.add(Label.Task_Subject_for_no_DSSO);
        setSubjects.add(Label.Task_Subject_for_no_AreaID);
        String query = 'SELECT Id, Email__c, Subject, OwnerId, Account.Name from Task where CreatedDate = TODAY and ';
        query += 'Subject in :setSubjects and Account.Status__c = \'Active\''; //[08/16/2017]-Rajeev Arya (Deloitte)-W-006712
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> lstTask)
    {
        try{
            set<ID> setDSSOAAIds = new set<ID>();
            String dealerName = TFS_Utility.BLANK;
            set<String> setAAEmails = new set<String>();
            
            for (Task tsk : lstTask) {
                setDSSOAAIds.add(tsk.Email__c);
            }
            //retrieving the email IDs for the DSSO AA team members
            if(setDSSOAAIds!=null)
            mapDSSOAAIdToEmail = new map<Id, User>([select id, email from user where id in :setDSSOAAIds]);
            //fetching the content to be sent in the mails, and the to addresses
            for (Task tsk : lstTask) {
                setAAEmails = new set<String>();
                
                if(tsk.Subject == Label.Task_Subject_for_no_DSSO){
                    strHQAdminDealers = strHQAdminDealers + tsk.Account.Name + ', ';
                }
                
                else if (tsk.Subject == Label.Task_Subject_for_no_AreaID){
                    setOwnerId.add(tsk.OwnerId);
                    if(!mapOwnerIdToDealers.containsKey(tsk.OwnerId)){
                        mapOwnerIdToDealers.put(tsk.OwnerId, tsk.Account.Name);
                    }
                    else{
                         dealerName = mapOwnerIdToDealers.get(tsk.OwnerId); 
                         dealerName = dealerName + ', ' + tsk.Account.Name;
                         mapOwnerIdToDealers.put(tsk.OwnerId, dealerName);
                    }
                }
                
                if(!mapOwnerIdToDSSOAAEmails.containsKey(tsk.OwnerId)){
                    if(mapDSSOAAIdToEmail.containsKey(tsk.Email__c)){
                        setAAEmails.add(mapDSSOAAIdToEmail.get(tsk.Email__c).email);
                        mapOwnerIdToDSSOAAEmails.put(tsk.OwnerId, setAAEmails);
                    }
                }
                else if(mapOwnerIdToDSSOAAEmails.containsKey(tsk.OwnerId)){
                    setAAEmails = mapOwnerIdToDSSOAAEmails.get(tsk.OwnerId);
                    setAAEmails.add(mapDSSOAAIdToEmail.get(tsk.Email__c).email);
                    mapOwnerIdToDSSOAAEmails.put(tsk.OwnerId, setAAEmails);
                }
            } 
            
            for(User usr : [select id, Email from user where TFS_SRM_Title__c = 'Sales HQ Admin']){
                strHQAdminMails.add(usr.Email);
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'DealerTask_SendMailForDSSOBatch', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Batch Apex' , Log_Severity__c = 'HIGH') ; 
            if(errLog!=null)
                insert errLog;
        } 
    }  
    
    //Sending email when the job finish includes all the dealer names with tasks created on them
    global void finish(Database.BatchableContext BC)
    {
        //sending consolidated email notifications based on the owner
        String strTaskDealers = TFS_Utility.BLANK;
        String[] strCCMails = new String[]{};
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: label.OrgWideAddressSRM];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
        List<Document> docList =[SELECT Id,DeveloperName from Document where DeveloperName='Double_Logo']; 
        String docId;
        if(docList.size()>0){
            docId=docList[0].Id;
        }
        strHQAdminDealers = strHQAdminDealers.RemoveEnd(', ');
        email.setSubject('New Dealers in SRM');
        String messageBody =  '<html><body style="font-family: arial; font-size: 12pt;"><img id="Logo" src="' +System.URL.getSalesforceBaseURL().toExternalForm()+ '/servlet/servlet.ImageServer?id='+docId+'&oid=' + UserInfo.getOrganizationId() + '" height="80" width="450">';
        messageBody += '<br></br><br></br><html><body><font size="3" color="blue">'+ strHQAdminDealers.replaceall(',', '<br>') +'</font><br><br>The above referenced dealers have been added to SRM.  Please log into SRM Salesforce to view the new dealer information.<br><br>Thank you,<br><br>TFS/LFS SRM Salesforce Team<br></br> Do not reply to this message. This email was sent from a notification-only address that cannot accept incoming email.</body>  </html>';
        email.setHtmlBody(messageBody);
        if(!strHQAdminMails.isEmpty()){
            email.setToAddresses(strHQAdminMails);
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setSaveAsActivity(false);
            mails.add(email);
        }
        for(ID OwnerId : setOwnerId){
            email= new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            strTaskDealers = mapOwnerIdToDealers.get(OwnerId);
            strTaskDealers = strTaskDealers.RemoveEnd(', ');
            email.setSubject('New Dealers missing ASM Assignment');
            messageBody =  '<html><body style="font-family: arial; font-size: 12pt;"><img id="Logo" src="' +System.URL.getSalesforceBaseURL().toExternalForm()+ '/servlet/servlet.ImageServer?id='+docId+'&oid=' + UserInfo.getOrganizationId() + '" height="80" width="450">';
            messageBody += '<br></br><br></br><html><body><font size="3" color="blue">'+ strTaskDealers.replaceall(',', '<br>') +'</font><br><br>The above referenced dealers are missing the TFS Area Number.  Please log into SRM Salesforce to update the missing information.<br><br>Thank you,<br><br>TFS/LFS SRM Salesforce Team <br></br> Do not reply to this message. This email was sent from a notification-only address that cannot accept incoming email.</body>  </html>';
            email.setHtmlBody(messageBody);
                        
            email.setTargetObjectId(OwnerId); 
            if(mapOwnerIdToDSSOAAEmails != null && mapOwnerIdToDSSOAAEmails.containsKey(OwnerId)){
                strCCMails = new String[]{};
                strCCMails.addAll(mapOwnerIdToDSSOAAEmails.get(OwnerId));
                strCCMails.addAll(strHQAdminMails);
                email.setCcAddresses(strCCMails);
            }
            else{
                strCCMails = new String[]{};
                strCCMails.addAll(strHQAdminMails);
                email.setCcAddresses(strCCMails);
            }
            email.setSaveAsActivity(false);
            mails.add(email);
        }
       if(mails != null && !mails.isEmpty()){
       	Messaging.sendEmail(mails);
       }
        
    }
    global void execute(SchedulableContext sc) {
        id batchId = Database.executeBatch(new DealerTask_SendMailForDSSOBatch()); 
    }
}