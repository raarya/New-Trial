/********************************************************************************************
* Class Name: Account_TriggerHelper 
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/24/2017]
* Requirement Description: User story W-004007 - able to assign or update the TFS area number for a dealer within a DSSO, but not across DSSOs.
* Date Modified                Modified By                  Description of the update
* [05/30/2017]              Rajeev Arya(Deloitte)       W-005805 : SRM_BR_TM_046 –Territory Management: ASM Assignment
* [06/05/2017]              Rajeev Arya(Deloitte)       W-004682 : SRM_BR_Box_026: Box Territory Structure
* [06/21/2017]              Rajeev Arya (Deloitte)      W-005910 : SRM_BR_TM_063 – Assigning Account Team Members to DSSOs and Dealers
* [08/02/2017]              Rajeev Arya (Deloitte)      W-006359 : SRM_BR_TM_015 – User Permissions: ASM permissions
* [08/28/2017]              Mounika Darisi (Deloitte)   W-005884
* [10/03/2017]              Bhargavaramu(Deloitte)      W-007195 : Creating account products for active dealers
***********************************************************************************************/

public with sharing class Account_TriggerHelper {

    //retrieving the bypasss trigger custom setting value from the org
    BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(UserInfo.getUserId());
    
    //Added by Bhargavaramu: W-006601
    //Populating startdate with current date, if date is not presen
    public void onBeforeInsert(List<Account> newAccList){
        for(Account acc: newAccList){
            if(acc.start_date__c == null){
                acc.start_date__c = date.today();
            }
        }
    }
    
    //Added by Bhargavaramu: W-006601
    //Populating startdate with current date, if date is not present
    public void onBeforeUpdate(List<Account> newAccList,Map<id,Account> oldAccMap){
        for(Account acc: newAccList){
            if(acc.start_date__c == null){
                acc.start_date__c = date.today();
            }
        }
    }
    
    //Added by Bhargavaramu: W-007195
    //Create account products when active dealers inserted
    public void createAccountProducts(List<Account> newAccList){
        //Fetching active products
        List<Product__c> prodList = [select id,name,start_date__c, end_date__c from Product__c
                                                                   Where status__c = :TFS_Utility.ACTIVE];
        
        ID dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(TFS_Utility.DEALER).getRecordTypeId();
        List<Account_Product__c> apList = new List<Account_Product__c>();
        for(Account acc : newAccList){
            if(acc.RecordTypeId == dealerRecordTypeId && acc.status__c == TFS_Utility.ACTIVE){
                for(product__c prod:prodList){
                    Account_Product__c ap = new Account_Product__c();
                    ap.Account__c = acc.id;
                    ap.Product__c = prod.id;
                    ap.Name = prod.Name;
                    ap.start_date__c = date.today();
                    
                    apList.add(ap);
                }
            }
        }
        
        //Inserting Account Products for active dealers
        if(apList != null && !apList.isEmpty()){
            insert apList;
        }
    }
    
    
    /********************************************************************************************
    * Author: Mounika Darisi (Deloitte)
    * Date: [08/23/2017]
    * Requirement Description: User story W-5884 - Method to update Subject on task and location on event. 
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void updateTaskSubjectEventLocation(map<id,account>mapOldAccounts , map<id,account>mapNewAccounts){
        try{
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('updateTaskSubjectEventLocation')){
                Map<Id,String> mapAccountIdName = new Map<Id,String>();
                Map<Id,String> mapAccountIdAddress = new Map<Id,String>();
                Map<Id,String> mapAccountIdNumber = new Map<Id,String>();
                set<Id> setAccountsUpdated = new set<Id>();
                set<Id> setAccountAddressUpdated = new set<Id>();
    
                List<Task> lstTaskToUpdate = new List<Task>();
                List<Event> lstEventToUpdate = new List<Event>();
    
                
                if(mapNewAccounts!=null && mapOldAccounts!=null) {
                    String strAccountAddress  = TFS_Utility.BLANK;
                    for(Id accID : mapNewAccounts.keySet()){
                        if(mapNewAccounts.get(accID).Name != mapOldAccounts.get(accID).Name || mapNewAccounts.get(accID).AccountNumber != mapOldAccounts.get(accID).AccountNumber){
                            setAccountsUpdated.add(accId);
                            mapAccountIdName.put(accId,mapNewAccounts.get(accID).Name);
                            mapAccountIdNumber.put(accId,mapNewAccounts.get(accID).AccountNumber);
                        }   
                        
                        if(mapNewAccounts.get(accID).Name != mapOldAccounts.get(accID).Name || mapNewAccounts.get(accID).AccountNumber != mapOldAccounts.get(accID).AccountNumber || TFS_Utility.getCompleteAddress(mapNewAccounts.get(accID).ShippingStreet,mapNewAccounts.get(accID).shippingcity,mapNewAccounts.get(accID).shippingstate,mapNewAccounts.get(accID).shippingcountry,mapNewAccounts.get(accID).shippingpostalcode) != TFS_Utility.getCompleteAddress(mapOldAccounts.get(accID).ShippingStreet,mapOldAccounts.get(accID).shippingcity,mapOldAccounts.get(accID).shippingstate,mapOldAccounts.get(accID).shippingcountry,mapOldAccounts.get(accID).shippingpostalcode)){                     
                        strAccountAddress = TFS_Utility.getCompleteAddress(mapNewAccounts.get(accID).ShippingStreet,mapNewAccounts.get(accID).shippingcity,mapNewAccounts.get(accID).shippingstate,mapNewAccounts.get(accID).shippingcountry,mapNewAccounts.get(accID).shippingpostalcode);
                        
                            setAccountAddressUpdated.add(accId);
                            mapAccountIdAddress.put(accId,(strAccountAddress != null && strAccountAddress.length() > 255 )? strAccountAddress.substring(0, 255) : strAccountAddress);
                        }
                    }
                    
                    if(setAccountsUpdated != null && !setAccountsUpdated.isEmpty()){
                        for(Task objTask: [select id,subject,WhatId,WhoId 
                                            from task 
                                            where status !=: TFS_Utility.COMPLETED  
                                            AND WhatId IN : setAccountsUpdated]){
                            if(objTask.WhatId != null && ((!string.isBlank(objTask.subject) && objTask.subject ==  mapOldAccounts.get(objTask.WhatId).Name+' '+ mapOldAccounts.get(objTask.WhatId).AccountNumber) || string.isBlank(objTask.subject))){
                                if(mapAccountIdName.get(objTask.WhatId) != null && mapAccountIdNumber.get(objTask.WhatId) != null){
                                objTask.Subject = mapAccountIdName.get(objTask.WhatId) +' '+mapAccountIdNumber.get(objTask.WhatId); 
                                }
                            }
                            lstTaskToUpdate.add(objTask);
                        }
                    }
                   
                   if(setAccountAddressUpdated != null && !setAccountAddressUpdated.isEmpty()){
                    DateTime currentTime = System.now();
                    String strEventAddress = TFS_Utility.BLANK;
                        for(Event objEvent: [select id,Location,WhatId,Subject,WhoId 
                                                from Event 
                                                where (StartDateTime >:currentTime OR EndDateTime  >:currentTime) 
                                                AND WhatId IN : setAccountAddressUpdated]){
                        
                            if(objEvent.WhatId != null){
                                strEventAddress = TFS_Utility.getCompleteAddress(mapOldAccounts.get(objEvent.WhatId).ShippingStreet,mapOldAccounts.get(objEvent.WhatId).shippingcity,mapOldAccounts.get(objEvent.WhatId).shippingstate,mapOldAccounts.get(objEvent.WhatId).shippingcountry,mapOldAccounts.get(objEvent.WhatId).shippingpostalcode);
                            }
                            if(objEvent.WhatId != null && ((!string.isBlank(objEvent.Location) && objEvent.Location ==  ((strEventAddress != null && strEventAddress != '' && strEventAddress.length() > 255) ? strEventAddress.substring(0,255): strEventAddress ))|| string.isBlank(objEvent.Location))){
                                if(!string.isBlank(mapAccountIdAddress.get(objEvent.WhatId))){
                                    objEvent.Location = mapAccountIdAddress.get(objEvent.WhatId);
                                }                               
                            }
                            if(objEvent.WhatId != null &&((!string.isBlank(objEvent.subject) && objEvent.subject ==  mapOldAccounts.get(objEvent.WhatId).Name+' '+ mapOldAccounts.get(objEvent.WhatId).AccountNumber) || string.isBlank(objEvent.subject))){
                                if(!string.isBlank(mapAccountIdName.get(objEvent.WhatId))){
                                    objEvent.Subject = mapAccountIdName.get(objEvent.WhatId) +' '+mapAccountIdNumber.get(objEvent.WhatId);
                                }
                            }
                            lstEventToUpdate.add(objEvent);
                        }
                    }
                    
                    if(lstTaskToUpdate != null && !lstTaskToUpdate.isEmpty()){
                        update lstTaskToUpdate; 
                    }       
                    if(lstEventToUpdate != null && !lstEventToUpdate.isEmpty()){
                        update lstEventToUpdate;
                    }
                }
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateASMAssignedDate', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ;
            insert errLog;
        }
    }
    
    /********************************************************************************************
    * Author: Deeksha Singhal (Deloitte)
    * Date: [02/14/2017]
    * Requirement Description: User story W-4128 - Method to update ASM Assigned Date on Update 
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void updateASMAssignedDate(map<id,account> mapNewAccounts, map<id,account> mapOldAccount){
        try{
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('updateASMAssignedDate')){
                String oldMapValue = TFS_Utility.BLANK;
                String newMapValue = TFS_Utility.BLANK;
                if(mapNewAccounts!=null && mapOldAccount!=null) {
                    for(String accID : mapNewAccounts.keySet()){
                        oldMapValue = mapOldAccount.get(accID).owner.name;
                        newMapValue = mapNewAccounts.get(accID).owner.name;
                        if((mapNewAccounts.get(accID).ownerID != Label.ASM_Unassigned_User_ID) && (oldMapValue == newMapValue )){
                            mapNewAccounts.get(accID).ASM_Assigned_Date__c = system.TODAY();
                        }
                    } 
                }
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateASMAssignedDate', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; insert errLog;
        }
    }
    
    /********************************************************************************************
    * Author: Deeksha Singhal (Deloitte)
    * Date: [02/14/2017]
    * Requirement Description: User story W-4128 - Method to update ASM Assigned Date on Update 
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void updateAMSAssignedDateOnInsert(list<account> listNewAccounts){
        try{
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('updateAMSAssignedDateOnInsert')){        
                if(listNewAccounts!=null){
                    for(account acc : listNewAccounts){
                        if(acc.ownerId !=null){
                            acc.ASM_Assigned_Date__c = system.TODAY();
                        }
                    } 
                }
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateAMSAssignedDateOnInsert', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; insert errLog;
        }
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/14/2017]
    * Requirement Description: User story W-004425 - TFS Area and ASM Assignment on Dealer
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void updateDealerTFSAndASM (list<Account> lstAcc, map<ID, Account> oldMapAcc){
        try{
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('updateDealerTFSAndASM')){
                
                set<String> setDSSONames = new set<String>();
                set<String> setAreaIds = new set<String>();
                map<String, map<ID, ID>> mapAreaDSSOToTFSA = new map<String, map<ID, ID>>();
                map<ID, ID> mapTFSIdToUsrId = new map<ID, ID>();
                map<ID, ID> mapAccountIdToASMId = new map<ID, ID>();
                set<ID> TFSAId;
                ID TFSAreaId;
                ID usrIdASMUnassigned = Label.ASM_Unassigned_User_ID;
                ID recTypeIDLocation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                map<ID, ID> mapOldRecIDToNewRecID = new map<ID, ID>(); 
                map<String, ID> mapDSSONameToLocationID = new map<String, ID>();
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
    
                for(Account acc : lstAcc){
                    if(Trigger.IsInsert || (Trigger.isUpdate && (acc.DSSO_Name__c != oldMapAcc.get(acc.Id).DSSO_Name__c ||
                                acc.Area_Id__c != oldMapAcc.get(acc.Id).Area_Id__c))) {
                        if(acc.DSSO_Name__c != null)
                            setDSSONames.add(acc.DSSO_Name__c);
                        if(acc.Area_Id__c != null)
                            setAreaIds.add(acc.Area_Id__c);
                    }
                }
    
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                if(!setDSSONames.isEmpty()){
                    for(Account acc: [select id, Name from Account where Name in :setDSSONames
                                            and RecordTypeId = :recTypeIDLocation and Type = 'DSSO']){
                            mapDSSONameToLocationID.put(acc.Name, acc.Id);
                    }
                }
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
    
                mapAreaDSSOToTFSA = retrieveTFSAreaUserMap(setDSSONames, setAreaIds);
                
                for(Account acc : lstAcc) {
                    
                    if(acc.RecordTypeId != recTypeIDLocation/* && acc.RecordTypeId != recTypeIDDealerGrp*/) {
                        
                        if(Trigger.isUpdate && acc.OwnerId != oldMapAcc.get(acc.Id).OwnerId){
                            mapAccountIdToASMId.put(acc.Id, acc.OwnerId);
                        }
                        else if(acc.DSSO_Name__c == null && acc.Area_Id__c == null){
                            acc.OwnerId = usrIdASMUnassigned;
                            if(Trigger.isUpdate) 
                                mapAccountIdToASMId.put(acc.Id, usrIdASMUnassigned);
                        }
                        else if (acc.DSSO_Name__c != null && acc.Area_Id__c == null) {
                            acc.OwnerId = usrIdASMUnassigned;
                            if(Trigger.isUpdate)
                                mapAccountIdToASMId.put(acc.Id, usrIdASMUnassigned);
                        }
                        else if(acc.DSSO_Name__c != null && acc.Area_Id__c != null){
                            if(!mapAreaDSSOToTFSA.isEmpty() && mapAreaDSSOToTFSA.containsKey(acc.Area_Id__c + acc.DSSO_Name__c)){
                                mapTFSIdToUsrId =  mapAreaDSSOToTFSA.get(acc.Area_Id__c + acc.DSSO_Name__c);
                                if(!mapTFSIdToUsrId.isEmpty()){
                                    TFSAId = mapTFSIdToUsrId.keySet();
                                    TFSAreaId = new list<ID>(TFSAId)[0];
                                    acc.TFS_Area__c = TFSAreaId;
                                    mapOldRecIDToNewRecID.put(acc.Id, TFSAreaId); //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                                    if(mapTFSIdToUsrId.get(TFSAreaId) != null){
                                        //[08/02/2017]-Rajeev Arya(Deloitte)- W-006359
                                        if(mapTFSIdToUsrId.get(TFSAreaId) == usrIdASMUnassigned)
                                            acc.Updated_to_unassigned__c = true;
                                        else
                                        //[08/02/2017]-Rajeev Arya(Deloitte)- W-006359
                                        acc.OwnerId = mapTFSIdToUsrId.get(TFSAreaId);
                                        mapAccountIdToASMId.put(acc.Id, acc.OwnerId);
                                    }
                                    else if(Trigger.isInsert && mapTFSIdToUsrId.get(TFSAreaId) == null){
                                        acc.OwnerId = usrIdASMUnassigned; 
                                    }
                                }
                                /*else{
                                     acc.TFS_Area__c = null;
                                     acc.OwnerId = usrIdASMUnassigned;
                                     mapOldRecIDToNewRecID.put(acc.Id, mapDSSONameToLocationID.get(acc.DSSO_Name__c));
                                }*/
                            }
                            else if(acc.DSSO_Name__c != oldMapAcc.get(acc.Id).DSSO_Name__c || acc.Area_Id__c != oldMapAcc.get(acc.Id).Area_Id__c){
                                acc.OwnerId = usrIdASMUnassigned;
                                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                                acc.TFS_Area__c = null;
                                mapOldRecIDToNewRecID.put(acc.Id, mapDSSONameToLocationID.get(acc.DSSO_Name__c));
                                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                            }
                        }
                    }
                
                }
                if(Trigger.IsUpdate){
                    updateASMOnFutureTasksAndEvents(mapAccountIdToASMId, oldMapAcc);
                    if(!System.IsBatch()){ //rajeev
                        if(mapOldRecIDToNewRecID!= NULL && !mapOldRecIDToNewRecID.isEmpty()){
                           BoxHandler.moveFolderFuture(mapOldRecIDToNewRecID); //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                        }  
                    }
                    else if(System.IsBatch()){ //rajeev
                        if(mapOldRecIDToNewRecID!= NULL && !mapOldRecIDToNewRecID.isEmpty()){
                           BoxHandler.moveFolderBatch(mapOldRecIDToNewRecID); 
                        }  
                    }//rajeev                     
                }
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateDealerTFSAndASM', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; insert errLog;
        }
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/21/2017]
    * Requirement Description: User story W-004003 - create tasks if Dealer DSSO and/or Area Id is null
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void createTasksOnDealers (list<Account> lstAcc){
        try{
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('createTasksOnDealers')){
                
                set<String> setDSSONames = new set<String>();
                map<String, list<Id>> mapDSSONameToMemberIds = new map<String, list<Id>>();
                map<list<ID>, String> mapTaskOwnerAndDSSOAAIdToSubject = new map<list<ID>, String>();
                map<ID, map<list<ID>, String>> mapAccIdToTaskOwnerAndDSSOIdToSub = new map<ID, map<list<ID>, String>>();
                ID usrIdSalesHQAdmin = Label.Sales_HQ_Admin_User_ID;
                ID recTypeIDLocation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    
                for(Account acc : lstAcc){
                    if(acc.RecordTypeId != recTypeIDLocation) {
                        setDSSONames.add(acc.DSSO_Name__c);
                    }
                }
                if(!setDSSONames.isEmpty()){
                    if(usrIdSalesHQAdmin == null)
                        usrIdSalesHQAdmin = UserInfo.getUserId();
        
                    mapDSSONameToMemberIds = retrieveDSMAndDSSMOnDSSO(setDSSONames);
                    for(Account acc : lstAcc) {
                        if(acc.DSSO_Name__c == null && acc.Area_Id__c == null){
                            mapTaskOwnerAndDSSOAAIdToSubject.put(new list<ID>{usrIdSalesHQAdmin}, 'DSSO Name');
                            mapAccIdToTaskOwnerAndDSSOIdToSub.put(acc.Id, mapTaskOwnerAndDSSOAAIdToSubject);
                        }
                        else if (acc.DSSO_Name__c != null && acc.Area_Id__c == null && mapDSSONameToMemberIds.containsKey(acc.DSSO_Name__c)) {
                            mapTaskOwnerAndDSSOAAIdToSubject.put(mapDSSONameToMemberIds.get(acc.DSSO_Name__c), 'Area Id');
                            mapAccIdToTaskOwnerAndDSSOIdToSub.put(acc.Id, mapTaskOwnerAndDSSOAAIdToSubject);
                        }
                    }
                    createTasksForMembers(mapAccIdToTaskOwnerAndDSSOIdToSub); 
                }
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.createTasksOnDealers', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; insert errLog;
        }
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/20/2017]
    * Requirement Description: User story W-004003 - Creating tasks to populate DSSO Name and/or Area ID
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
     public void createTasksForMembers (map<ID, map<list<ID>, String>> mapAccIdToOwnerIdAndDSSOAAToSubject){
        list<Task> lstNewTasks = new list<Task>();
        map<list<ID>, String> mapOwnerIdAndDSSOAAToSubject = new map<list<ID>, String>();
        list<Error_Log__c> listErrLog = new list<Error_Log__c>();   
        set<list<ID>> setOwnerIdAndDSSOAA;
        list<ID> lstIds;
        ID tskOwnerID;
        String errMsg = TFS_Utility.BLANK;
        for(Id AccId : mapAccIdToOwnerIdAndDSSOAAToSubject.keySet()){
            mapOwnerIdAndDSSOAAToSubject = mapAccIdToOwnerIdAndDSSOAAToSubject.get(AccId);
            setOwnerIdAndDSSOAA = mapOwnerIdAndDSSOAAToSubject.keySet();
            if(!setOwnerIdAndDSSOAA.isEmpty())
                lstIds = new list<list<ID>>(setOwnerIdAndDSSOAA)[0];
            if(lstIds != null && !lstIds.isEmpty()){
                Task tsk = new Task();
                tsk.WhatId = AccId;
                tsk.Priority = 'Normal';
                tsk.Status = 'Not Started';
                tsk.ActivityDate = System.today()+7;
                if(lstIds.size() == 2)
                    tsk.Email__c = lstIds[1];
                tskOwnerID = lstIds[0];
                tsk.OwnerId = tskOwnerID;
                if(mapOwnerIdAndDSSOAAToSubject.containsKey(lstIds) && mapOwnerIdAndDSSOAAToSubject.get(lstIds) == 'DSSO Name')
                    tsk.Subject = Label.Task_Subject_for_no_DSSO;
                else if(mapOwnerIdAndDSSOAAToSubject.containsKey(lstIds) && mapOwnerIdAndDSSOAAToSubject.get(lstIds) == 'Area Id')
                    tsk.Subject = Label.Task_Subject_for_no_AreaID;
                lstNewTasks.add(tsk);
            }
        }
        
        if (!lstNewTasks.isEmpty()){  
            Database.SaveResult[] results = Database.insert(lstNewTasks, false); 
            Error_Log__c errLog;
            for (integer i = 0; i < results.size(); i++) {
                Database.SaveResult result = results[i];
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        errMsg = 'ERROR: ' + lstNewTasks[i].Id + ' -> ' + err.getStatusCode() + ': ' + err.getMessage() + '; Fields: ' + err.getFields();
                        errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.createTasksForMembers', Log_Message__c = errMsg, Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
                        listErrLog.add(errLog);
                    }
                }
            }
            insert listErrLog;
        }
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/14/2017]
    * Requirement Description: User story W-004425 - Retrieving all TFS Areas and related users based on selected DSSOs and Area IDs
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
     public map<String, map<ID, ID>> retrieveTFSAreaUserMap (set<String> setDSSONames, set<String> setAreaIds){
        map<String, map<ID, ID>> mapAreaIdDSSONameToTFSArea = new map<String, map<ID, ID>>();
        map<ID, ID> mapTFSIdToUsrId = new map<ID, ID>();
    
        for(TFS_Area__c recTFSA : [select id, Area_Id__c, DSSO_Name__c,
                                    (select id, ASM__c,
                                     Start_Date__c,TFS_Area__c, End_Date__c,
                                    TFS_Area__r.Area_Id__c,TFS_Area__r.DSSO_Name__c 
                                    from TFS_Area_Users__r where Start_Date__c <= :Date.today() 
                                    order by Start_Date__c desc)
                                    from TFS_Area__c
                                    where Area_Id__c in :setAreaIds 
                                    and DSSO_Name__c in :setDSSONames]){
            if(!recTFSA.TFS_Area_Users__r.isEmpty()){
                for(TFS_Area_User__c tfsAU : recTFSA.TFS_Area_Users__r){
                    //[05/30/2017]-Rajeev Arya(Deloitte)- W-005805 : Setting to ASM Uniassigned based on End Date                    
                    if(tfsAU.End_Date__c > Date.today() || tfsAU.End_Date__c == null){
                        if(tfsAU.Start_Date__c == Date.today())
                            mapTFSIdToUsrId.put(recTFSA.Id, tfsAU.ASM__c); 
                        else if (!mapTFSIdToUsrId.containsKey(tfsAU.TFS_Area__c) && tfsAU.Start_Date__c < Date.today())
                            mapTFSIdToUsrId.put(recTFSA.Id, tfsAU.ASM__c);
                    }
                }
            }
            else {
                mapTFSIdToUsrId.put(recTFSA.Id, null);    
            }
    
            mapAreaIdDSSONameToTFSArea.put(recTFSA.Area_Id__c + recTFSA.DSSO_Name__c, mapTFSIdToUsrId);
            mapTFSIdToUsrId =  new map<ID, ID>();
        }
        return mapAreaIdDSSONameToTFSArea;
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/20/2017]
    * Requirement Description: User story W-004003 - Retrieving the DSM and DSSM members from the account team on the DSSO
    * Date Modified                Modified By                  Description of the update
    * [06/21/2017]              Rajeev Arya (Deloitte)      W-005910 : SRM_BR_TM_063 – Assigning Account Team Members to DSSOs and Dealers
    ***********************************************************************************************/
     public map<String, list<ID>> retrieveDSMAndDSSMOnDSSO (set<String> setDSSONames){
        map<String, list<ID>> mapDSSONameToMemberAndDSSO = new map<String, list<ID>>();
        list<ID> lstMemIDs = new list<ID>();
        set<ID> setDSSOIDs = new set<ID>();
        //[06/21/2017]-Rajeev Arya(Deloitte)- W-005910 
        for(Account dsso : [select id from Account where recordtype.name = 'Location' and type = 'DSSO' and name in :setDSSONames]){
            setDSSOIDs.add(dsso.Id);
        }
        //[06/21/2017]-Rajeev Arya(Deloitte)- W-005910
        
        //[06/21/2017]-Rajeev Arya(Deloitte)- W-005910
        for(AccountTeamMember accTeam : [select UserId, Account.Name, TeamMemberRole
                                    from AccountTeamMember
                                    where AccountId in :setDSSOIDs 
                                    and (TeamMemberRole = 'DSSM' OR TeamMemberRole = 'DSM')
                                    and account.recordtype.name = 'Location' and account.type = 'DSSO']){
                
            if(accTeam.TeamMemberRole == 'DSM'){
                mapDSSONameToMemberAndDSSO.put(accTeam.Account.Name, new list<ID>{accTeam.UserId});
            }
            else if(accTeam.TeamMemberRole == 'DSSM' && !mapDSSONameToMemberAndDSSO.containsKey(accTeam.Account.Name)){
                mapDSSONameToMemberAndDSSO.put(accTeam.Account.Name, new list<ID>{accTeam.UserId});    
            }
        }
    
        for(AccountTeamMember accTeam : [select UserId, Account.Name, TeamMemberRole
                                    from AccountTeamMember
                                    where AccountId in :setDSSOIDs 
                                    and TeamMemberRole = 'DSSO AA'
                                    and account.recordtype.name = 'Location' and account.type = 'DSSO']){
                
            if(mapDSSONameToMemberAndDSSO.containsKey(accTeam.Account.Name)){
                lstMemIDs = mapDSSONameToMemberAndDSSO.get(accTeam.Account.Name);
                lstMemIDs.add(accTeam.UserId);
                mapDSSONameToMemberAndDSSO.put(accTeam.Account.Name, lstMemIDs);
            }
        }
        return mapDSSONameToMemberAndDSSO;
    }
    
    /********************************************************************************************
    * Author: Rajeev Arya (Deloitte)
    * Date: [02/14/2017]
    * Requirement Description: User story W-004425 - reassigning open future dated tasks and events to new Dealer ASM
    * Date Modified                Modified By                  Description of the update
    
    ***********************************************************************************************/
    public void updateASMOnFutureTasksAndEvents (map<ID, ID> mapAccIdToASMId, map<ID, Account> oldMapAcc) {
        list<Task> lstTasksToUpdate = new list<Task>();
        list<Event> lstEventsToUpdate = new list<Event>();
        list<Error_Log__c> listErrLog = new list<Error_Log__c>();
        String errMsg =TFS_Utility.BLANK;
        for(Task tsk : [select OwnerId, WhatId from task where ActivityDate > :Date.today()
                        and Status NOT IN ('Completed', 'Deferred')
                        and WhatId in :mapAccIdToASMId.keySet()]){
            if(tsk.OwnerId == oldMapAcc.get(tsk.WhatId).OwnerId && mapAccIdToASMId.containsKey(tsk.WhatId))
                tsk.OwnerId = mapAccIdToASMId.get(tsk.WhatId);
            lstTasksToUpdate.add(tsk);
        }
        Database.SaveResult[] resultsTasks = Database.update(lstTasksToUpdate, false); 
        Error_Log__c errLog;
        for (integer i = 0; i < resultsTasks.size(); i++) {
            Database.SaveResult result = resultsTasks[i];
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    errMsg = 'ERROR: ' + lstTasksToUpdate[i].Id + ' -> ' + err.getStatusCode() + ': ' + err.getMessage() + '; Fields: ' + err.getFields();
                    errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateASMOnFutureTasksAndEvents for Tasks', Log_Message__c = errMsg, Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
                    listErrLog.add(errLog);
                }
            }
        }
        insert listErrLog;
    
        for(Event evt : [select OwnerId, WhatId from event where StartDateTime > :System.now()
                            and WhatId in :mapAccIdToASMId.keySet()]){
            if(evt.OwnerId == oldMapAcc.get(evt.WhatId).OwnerId && mapAccIdToASMId.containsKey(evt.WhatId))
                evt.OwnerId = mapAccIdToASMId.get(evt.WhatId);
            lstEventsToUpdate.add(evt);
        }
        listErrLog.clear();
        Database.SaveResult[] resultsEvents = Database.update(lstEventsToUpdate, false); 
        for (integer i = 0; i < resultsEvents.size(); i++) {
            Database.SaveResult result = resultsEvents[i];
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    errMsg = 'ERROR: ' + lstEventsToUpdate[i].Id + ' -> ' + err.getStatusCode() + ': ' + err.getMessage() + '; Fields: ' + err.getFields();
                    errLog = new Error_Log__c(Log_Name__c = 'Account_TriggerHelper.updateASMOnFutureTasksAndEvents for Events', Log_Message__c = errMsg, Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
                    listErrLog.add(errLog);
                }
            }
        }
        insert listErrLog;
    }
}