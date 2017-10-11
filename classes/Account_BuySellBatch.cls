/*********************************************************************************************************************************************
* Class Name: Account_BuySellBatch
* Author: (Deloitte)
* Date: [03/28/2017]
* Requirement Description: User story W-004010 - Migrate and overwrite Account team, Area ID, TMS Details, and Dealer Objectives information
* Date Modified                Modified By                  Description of the update

*********************************************************************************************************************************************/
global class Account_BuySellBatch implements Database.Batchable<sobject>,Database.Stateful,Schedulable, Database.AllowsCallouts {
 
 String query;
 public Map<Id,Id> accRelAccMap = new Map<Id,Id>();
 public List<Account> lstAcc = new List<Account>();
 public Map<Id,Account> misMatchMap = new Map<Id,Account>();
 global Database.QueryLocator start(Database.BatchableContext BC){
        //fetching the Accounts with start date as today
        query= 'SELECT Id,DSSO_ID__c,AccountNumber,Name,Start_Date__c,End_Date__c,Related_Account__c,Area_ID__c,Related_Account__r.DSSO_Name__c, Related_Account__r.DSSO_ID__c,Related_Account__r.TFS_Area__c,Related_Account__r.TFS_Area__r.DSSO__c,'+
               '(Select Id, Name, Region_Name__c, Market_Area__c, District_Sales_Manager__c,'+
               'District_Number__c, District_Service_Parts_Manager__c, Account__c From TMS_details_del__r),'+
               '(Select Id, AccountId, UserId, TeamMemberRole, PhotoUrl, Title, AccountAccessLevel,'+
               'OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel From AccountTeamMembers),'+
               '(Select Id, Name,Account__c, Type__c, Plan__c, Stretch__c, Date_Submitted__c, Fiscal_Year__c,'+
               'Month__c, Status__c, Product_Objective__c,Product__c From Product_Objectives__r) '+
               'FROM Account WHERE Start_Date__c = TODAY AND isProcessed__c = false AND Related_Account__c!= NULL';
        return Database.getQueryLocator(query);
 }

 //To process the Accounts updated by Integration and update Account Team, TMS Details, Dealer Objectives and Area ID
 global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            
            List<Account> lstAccount = (List<Account>) scope;
            Error_Log__c errLog;
            List<Error_Log__c> listErrLog = new List<Error_Log__c>();
            Map<Id,Account> newRelAccMap = new Map<Id,Account>();
            List<AccountTeamMember> delATMList = new List<AccountTeamMember>();
            List<TMS_Detail__c> delTMSDetList = new List<TMS_Detail__c>();
            List<Product_Objective__c> delProdObj = new List<Product_Objective__c>();
            
            List<AccountTeamMember> insATMList = new List<AccountTeamMember>();
            List<TMS_Detail__c> insTMSDetList = new List<TMS_Detail__c>();
            List<Product_Objective__c> insProdObj = new List<Product_Objective__c>();
            
            Set<Id> misMatchSet = new Set<Id>();
            if(lstAccount!=null && !lstAccount.isEmpty()){
                for(Account oAcc:lstAccount){
                    
                    //Scenario 1 - When the DSSO Ids are same
                    if(oAcc.DSSO_ID__c != NULL && !String.isBlank(oAcc.DSSO_ID__c) && 
                        oAcc.Related_Account__r.DSSO_ID__c != NULL && !String.isBlank(oAcc.Related_Account__r.DSSO_ID__c)
                        && oAcc.DSSO_ID__c.equals(oAcc.Related_Account__r.DSSO_ID__c)){
                        accRelAccMap.put(oAcc.Id,oAcc.Related_Account__c);                  
                    }
                    //Scenario 2 - When the new dealer does not have a DSSO Id 
                    else if(oAcc.Related_Account__r.DSSO_ID__c == NULL || String.isBlank(oAcc.Related_Account__r.DSSO_ID__c)){
                       accRelAccMap.put(oAcc.Id,oAcc.Related_Account__c);     
                    }
                    
                    //Scenario 3 - When the DSSO Ids are different
                    else if(oAcc.DSSO_ID__c != NULL && !String.isBlank(oAcc.DSSO_ID__c) && 
                        oAcc.Related_Account__r.DSSO_ID__c != NULL && !String.isBlank(oAcc.Related_Account__r.DSSO_ID__c)
                        && !oAcc.DSSO_ID__c.equals(oAcc.Related_Account__r.DSSO_ID__c)){
                            lstAcc.add(oAcc); 
                            misMatchSet.add(oAcc.Related_Account__c);                
                    }             
                }
            }
            //Fetch all the related list records for the Related To Account Ids
            if(accRelAccMap!= NULL && !accRelAccMap.isEmpty()){
                for(Account acc :[SELECT Id,DSSO_ID__c,Start_Date__c,End_Date__c,Related_Account__c,Area_ID__c,Related_Account__r.DSSO_ID__c,
                               (Select Id, Name, Region_Name__c, Market_Area__c, District_Sales_Manager__c,District_Number__c, District_Service_Parts_Manager__c,
                               Account__c From TMS_details_del__r),(Select Id, AccountId, UserId, TeamMemberRole, PhotoUrl, Title, 
                               AccountAccessLevel,OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel From AccountTeamMembers), 
                               (Select Id, Name,Account__c, Type__c, Plan__c, Stretch__c, Date_Submitted__c, Fiscal_Year__c, Month__c, Status__c, Product_Objective__c,
                               Product__c From Product_Objectives__r) FROM Account WHERE Id IN:accRelAccMap.values()]){
                    newRelAccMap.put(acc.Id,acc);                
                }                      
            }
            //Fetch the Dealer information to populate in the Email notification
            if(misMatchSet!= NULL && !misMatchSet.isEmpty()){
                for(Account acc :[SELECT Id,DSSO_ID__c,DSSO_Name__c,AccountNumber,Name FROM Account WHERE Id IN:misMatchSet]){
                    misMatchMap.put(acc.Id,acc);             
                }                     
            }
           
           delATMList = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :accRelAccMap.keySet()];
           delTMSDetList = [SELECT Id FROM TMS_Detail__c WHERE Account__c IN:accRelAccMap.keySet()];
           delProdObj = [SELECT Id FROM Product_Objective__c WHERE Account__c IN: accRelAccMap.keySet()];
           
           // Delete all the related records on the New Dealer Account
           if(delATMList!= NULL && !delATMList.isEmpty())
           delete delATMList;
           if(delTMSDetList!= NULL && !delTMSDetList.isEmpty())
           delete delTMSDetList;
           if(delProdObj!= NULL && !delProdObj.isEmpty())
           delete delProdObj;
           
           // Clone the existing related records from the Old Dealer Account onto the new Dealer Account
           if(accRelAccMap!= NULL && !accRelAccMap.isEmpty()){
                  for(Id ide: accRelAccMap.keyset()){
                       if(newRelAccMap.get(accRelAccMap.get(ide))!= NULL){
                             Account relatedAcc = newRelAccMap.get(accRelAccMap.get(ide));
                             //Related Account Team Members
                             if(relatedAcc.AccountTeamMembers != NULL){
                                for(AccountTeamMember atm: relatedAcc.AccountTeamMembers){
                                    AccountTeamMember ateam  = atm.clone(false, false, false, false);
                                    ateam.AccountId = ide;                              
                                    insATMList.add(ateam);
                                }                 
                             } 
                             // Related TMS Details
                             if(relatedAcc.TMS_details_del__r != NULL){
                                for(TMS_Detail__c tms :relatedAcc.TMS_details_del__r){
                                    TMS_Detail__c otms  = tms.clone(false, false, false, false);
                                    otms.Account__c = ide;
                                    insTMSDetList.add(otms);
                                }                                 
                             } 
                             // Related Product Objectives
                             if(relatedAcc.Product_Objectives__r != NULL){
                                 for(Product_Objective__c pobj :relatedAcc.Product_Objectives__r){  
                                    Product_Objective__c pob = pobj.clone(false, false, false, false);
                                    pob.Account__c = ide;
                                    insProdObj.add(pob);
                                 }
                             }
                       }
                 }
            }
            if(!insATMList.isEmpty()) 
                insert insATMList;
            if(!insTMSDetList.isEmpty())
                insert insTMSDetList;
            if(!insProdObj.isEmpty())
                insert insProdObj;
            
            List<Account> updAcc = new List<Account>();  
            //Update all the new Dealer Accounts with the flag isProcessed         
            if(accRelAccMap!= NULL && !accRelAccMap.isEmpty()){
                for(Id ide: accRelAccMap.keyset()){
                    Account acc = new Account(Id=ide,isProcessed__c = true,Area_ID__c=newRelAccMap.get(accRelAccMap.get(ide)).Area_ID__c);
                    updAcc.add(acc);           
                }
            }
            if(!updAcc.isEmpty()){ 
                update updAcc;
            } 
           
        }catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.ACCOUNT_BUYSELLBATCH, Log_Message__c = TFS_Utility.SFDC_LOG+err.getStackTraceString()+TFS_Utility.LINE+err.getLineNumber(), Log_Type__c = 'Batch Apex' , Log_Severity__c = TFS_Utility.HIGH) ; 
            if(errLog!=null)
            insert errLog;
        }
    }
    // Finish method to execute all the email notifications
    global void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        if(lstAcc!= NULL && !lstAcc.isEmpty()){
            List<Document> docList =[SELECT Id,DeveloperName from Document where DeveloperName=:TFS_Utility.DOUBLE_LOGO]; 
            String docId;
            if(docList.size()>0){
                docId=docList[0].Id;
            }
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: label.OrgWideAddressSRM];
            for(User usr: [SELECT Id from User WHERE TFS_SRM_Title__c =: TFS_Utility.SALESHQADMIN AND IsActive= TRUE]){
                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
                 email.setTargetObjectId(usr.Id);
                 String messageBody;
                 email.setSubject(TFS_Utility.SUBACCOUNTBUYSELL);
                 email.setSaveAsActivity(false);
                 messageBody = '<html><body style="font-family: arial; font-size: 12pt;"><img id="Logo" src="' +System.URL.getSalesforceBaseURL().toExternalForm()+ '/servlet/servlet.ImageServer?id='+docId+'&oid='+UserInfo.getOrganizationId()+'" height="80" width="450">';
                 messageBody +='<p>The New Dealer and Previous Dealer do not have the same DSSO. <br/> As a result, the buy/sell was not processed in SRM Salesforce. </p><br/>';
                 messageBody = messageBody+'<ul><li>';
                 for(Account oAcc : lstAcc){
                    if(misMatchMap != NULL && !misMatchMap.isEmpty() && misMatchMap.get(oAcc.Related_Account__c)!= NULL){
                        Account acc = misMatchMap.get(oAcc.Related_Account__c);
                        if(oAcc.DSSO_ID__c!= NULL && oAcc.DSSO_ID__c!= ''){
                          messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+oAcc.DSSO_ID__c+' ';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+'  ';
                        }
                        if(oAcc.AccountNumber!= NULL && oAcc.AccountNumber!= ''){
                          messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+oAcc.AccountNumber+' ';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+'  ';
                        }if(oAcc.Name!= NULL && oAcc.Name!= ''){
                          messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+oAcc.Name+' ';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.NEWDEALERDSSO+'  ';
                        }
                        if(acc.DSSO_ID__c!= NULL && acc.DSSO_ID__c!= ''){
                          messageBody  = messageBody+'</li><li>'+TFS_Utility.PREVIOUS_DEALERDSSO+acc.DSSO_ID__c+' ';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.PREVIOUS_DEALERDSSO+'  ';
                        }
                        if(acc.AccountNumber!= NULL && acc.AccountNumber!= ''){
                          messageBody  = messageBody+TFS_Utility.DEALER_NUMBER+acc.AccountNumber+' ';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.DEALER_NUMBER+'  ';
                        }if(acc.Name!= NULL && acc.Name!= ''){
                          messageBody  = messageBody+TFS_Utility.DEALER_NUMBER+acc.Name+'  </li>';
                        }
                        else{
                         messageBody  = messageBody+TFS_Utility.DEALER_NUMBER+'  </li>';
                        }           
                    }
                 }
                 
                 if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                 messageBody += '</ul> </br> For any questions, please contact <a href="mailto:Infy_Integration_Infa_support@toyota.com">Infy_Integration_Infa_support@toyota.com</a><br/><br/>';
                 messageBody = messageBody+'Thank you,<br/><br/> Informatica Support Team </br><br> Do not reply to this message. This email was sent from a notification-only address that cannot accept incoming email.</br></body></html>';
                 email.setHtmlBody(messageBody); 
                 emails.add(email); 
            }
            try{
                if(!emails.isEmpty())
                {
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
                } 
            }catch(Exception err)
            { 
               Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.ACCOUNT_BUYSELLBATCH, Log_Message__c = TFS_Utility.SFDC_LOG+err.getStackTraceString()+TFS_Utility.LINE+err.getLineNumber(), Log_Type__c = 'Batch Apex' , Log_Severity__c = TFS_Utility.HIGH) ; 
                if(errLog!=null)
                insert errLog;
            }
        }   
    } 
    //Method to schedule the batch  class  
    global void execute(SchedulableContext sc) {
        id batchId = Database.executeBatch(new Account_BuySellBatch (), 50); //rajeev
    }
    
    //Rajeev
    //Method: method to automove BOX folder
    public static void moveFolderFuture(map<ID, ID> mapOldRecIDToNewRecID) {
         
        if(!test.IsRunningTest()){
            list<Error_Log__c> lstErrLog = new list<Error_Log__c>();
            box.Toolkit boxToolkit = new box.Toolkit();
            Boolean bolMoveSuccess = false;
            String oldFolderID;
            String newFolderID;
            for(ID recID : mapOldRecIDToNewRecID.KeySet()){
                oldFolderID = boxToolkit.getFolderIdByRecordId(recID);
                newFolderID = boxToolkit.getFolderIdByRecordId(mapOldRecIDToNewRecID.get(recID));
                if(newFolderID!=null){
                    bolMoveSuccess = boxToolkit.moveFolder(oldFolderID, newFolderID, null);
                }
                if(!bolMoveSuccess)
                {
                    system.debug('Box most recent error during Move: ' + boxToolkit.mostRecentError + '; Old rec :' + recID + '; New Rec : ' + mapOldRecIDToNewRecID.get(recID));
                    Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', 
                    Log_Message__c = 'Box most recent error during Move: ' + boxToolkit.mostRecentError + '; Old rec :' + recID + '; New Rec : ' + mapOldRecIDToNewRecID.get(recID), 
                    Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                    lstErrLog.add(errLog);
                }    
                boxToolkit.commitChanges();
            }
            if(lstErrLog != null && !lstErrLog.isEmpty())
                insert lstErrLog;
        }
    }
    //Rajeev
 
}