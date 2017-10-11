/**************************************************************************************************************************************************
* Class Name: BoxHandler
* Author: Deloitte
* Date: [04/06/2017]
* Requirement Description:  User story W-004630 - Setting up folder structure
* Date Modified                Modified By                  Description of the update
* [06/05/2017]              Rajeev Arya(Deloitte)       W-004682 : SRM_BR_Box_026: Box Territory Structure
***************************************************************************************************************************************************/
public with sharing class BoxHandler {
     
     //Method: Future method to autocreate folder on Account
     @future (callout=true)
     public static void createFolderFuture(Id record) {
         
        if(!test.IsRunningTest()){
            box.Toolkit boxToolkit = new box.Toolkit();
            //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
            String newFolderID;    
            String oldFolderID;  
            Boolean bolMoveSuccess = false; 
            //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
            Account account = [SELECT Id, AccountNumber, Name,Type, TFS_Area__c, DSSO_Name__c, ParentID, RecordType.Name FROM Account WHERE Id=:record];        
            if(account!= NULL)
            {
                //account.AccountNumber added by Jayant on 05/08/2017
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                if(account.RecordType.Name != 'Location'){
                    account.BoxFolder__c = boxToolkit.createFolderForRecordId(account.Id, account.AccountNumber, true);
                    oldFolderID = account.BoxFolder__c;
                    if(account.TFS_Area__c != null){
                         newFolderID = boxToolkit.getFolderIdByRecordId(account.TFS_Area__c);
                    }
                    else if(account.DSSO_Name__c != null){
                        Account acc = [select id, Name from Account where Name = :account.DSSO_Name__c and RecordType.Name = 'Location' and Type = 'DSSO' limit 1];
                        if(acc != null)
                            newFolderID = boxToolkit.getFolderIdByRecordId(acc.Id);       
                    }
                }
                else if(account.RecordType.Name == 'Location'){
                    account.BoxFolder__c = boxToolkit.createFolderForRecordId(account.Id, account.name, true); 
                    system.debug('Box most recent error: ' + boxToolkit.mostRecentError);
                    oldFolderID = account.BoxFolder__c;
                    if(account.ParentID != null && (account.Type == 'DSSO' || account.Type == 'Region')){

                        newFolderID = boxToolkit.getFolderIdByRecordId(account.ParentID);
                     }
                } 
                if(newFolderID!=null && oldFolderID != null)               
                bolMoveSuccess = boxToolkit.moveFolder(oldFolderID, newFolderID, null);
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                
                if(account.BoxFolder__c == null || !bolMoveSuccess)
                {
                    system.debug('Box most recent error: ' + boxToolkit.mostRecentError);
                    
                    Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', Log_Message__c = 'SFDC__LOG: '+boxToolkit.mostRecentError+' Line:21 ', Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                    if(errLog != null){insert errLog;}
                }
                //Added by Jayant on 05/08/2017 End.
            }
            
            
            try{        
                if(account!=null)
                update account;
            }catch (Exception err){
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                if(errLog!=null)
                insert errLog;
            }        
            boxToolkit.commitChanges();
        }
    }
    //Method: Future method to autocreate folder on TFS Area
     @future (callout=true)
     public static void createFolderFutureTFS(Id record) {
         
        if(!test.IsRunningTest()){
            box.Toolkit boxToolkit = new box.Toolkit();     
            //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
            String newFolderID;    
            Boolean bolMoveSuccess = false;
            //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
            TFS_Area__c tfsA= [SELECT Id, DSSO__c FROM TFS_Area__c WHERE Id=:record]; 
            if(tfsA != NULL){
                tfsA.FolderID__c = boxToolkit.createFolderForRecordId(tfsA.Id, null, true); //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
                newFolderID = boxToolkit.getFolderIdByRecordId(tfsA.DSSO__c);
                if(newFolderID!=null && tfsA.FolderID__c != null)
                bolMoveSuccess = boxToolkit.moveFolder( tfsA.FolderID__c, newFolderID, null);
                //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
            }
            try{if(tfsA!=null)    
                update tfsA;
                TFS_Area__c tfsA1= [SELECT Id, DSSO__c FROM TFS_Area__c WHERE Id=:tfsA.id];
            }catch (Exception err){
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                if(errLog!=null)
                insert errLog;
            }       
            boxToolkit.commitChanges();
        }
    }
     //Method: Future method to autocreate folder on Training Events
     @future (callout=true)
     public static void createFolderFutureTrainingEvent(Id record) {
         
        if(!test.IsRunningTest()){
            box.Toolkit boxToolkit = new box.Toolkit();        
            Training_Event__c tEvent = [SELECT Id FROM Training_Event__c WHERE Id=:record];
            if(tEvent != NULL){
                tEvent.FolderID__c = boxToolkit.createFolderForRecordId(tEvent.Id, null, true);
            }
            try{if(tEvent!=null)    
                update tEvent;
            }catch (Exception err){
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                if(errLog!=null)
                insert errLog;
            }        
            boxToolkit.commitChanges();
        }
    }
     //Method: Future method to autocreate folder on Training Class
     @future (callout=true)
     public static void createFolderFutureTrainingClass(Id record) {
         
        if(!test.IsRunningTest()){
            box.Toolkit boxToolkit = new box.Toolkit();        
            Training_Class__c tClass= [SELECT Id FROM Training_Class__c WHERE Id=:record];
            if(tClass != NULL){
                tClass.FolderID__c = boxToolkit.createFolderForRecordId(tClass.Id, null, true);
            }
            try{if(tClass!=null)    
                update tClass;
            }catch (Exception err){
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'BoxHandler', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Box Folder' , Log_Severity__c = 'HIGH') ; 
                if(errLog!=null)
                insert errLog;
            }        
            boxToolkit.commitChanges();
        }
    }    
    public static void createWorkspaces(List<Id> objects) {
        
        if(!test.IsRunningTest()){
            box.Toolkit boxToolkit = new box.Toolkit();        
            List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :objects];
            for (Account account : accounts) {
                account.BoxFolder__c = boxToolkit.createFolderForRecordId(account.Id, null, true);
            }                        
            boxToolkit.commitChanges();        
            if(accounts!=null)
            update accounts;
        }
    }
    
    //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
    //Method: Future method to automove BOX folder
    @future (callout=true)
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
    //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
    
    public static void moveFolderBatch(map<ID, ID> mapOldRecIDToNewRecID) {
         
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
}