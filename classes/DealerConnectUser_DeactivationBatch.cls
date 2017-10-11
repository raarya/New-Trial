/********************************************************************************************************************
* Class Name: DealerConnectUser_DeactivationBatch 
* Author: Rajeev Arya (Deloitte)
* Date: [06/29/2017]
* Requirement Description:W-006033 : SRM_BR_PL_004 - Access and Security: Legal Requirements
* Date Modified                Modified By                  Description of the update

*******************************************************************************************************************/
global class DealerConnectUser_DeactivationBatch implements Database.Batchable<sObject> , Database.Stateful, Schedulable{
    //fetching the Last Login Days for Community Users
    public Integer lastLoginDays = Integer.valueOf(Configurable_Values__c.getInstance().Days_without_Login__c);
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        //Query to retrieve the active community portal users
        String query = 'SELECT id, IsActive, createddate, LastLoginDate FROM User where IsPortalEnabled = true and IsActive = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstPortalUsers)
    {
        try{
            list<User> lstDeactivatedUsers = new list<User>();
            for(User usr : lstPortalUsers){

                //checking if the last login of the community user is greater than or equal to an X number of days from current date, and then deactivating the users;
                if((usr.LastLoginDate != null && (usr.LastLoginDate.date()).daysBetween(Date.today()) >= lastLoginDays)
                    || (usr.LastLoginDate == null && (usr.createddate.date()).daysBetween(Date.today()) >= lastLoginDays)){
                    usr.IsActive = false;   
                    lstDeactivatedUsers.add(usr);
                }
            }

            //saving the user records
            if(!lstDeactivatedUsers.isEmpty()){
                Database.SaveResult[] resultsUpdatedDealers = Database.update(lstDeactivatedUsers, false);
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'DealerConnectUser_DeactivationBatch', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Batch Apex' , Log_Severity__c = 'HIGH') ; 
            if(errLog!=null)
                insert errLog;
        }
    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        id batchId = Database.executeBatch(new DealerConnectUser_DeactivationBatch()); 
    }
}