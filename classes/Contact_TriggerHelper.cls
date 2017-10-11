/********************************************************************************************
* Trigger Name: Contact_TriggerHelper 
* Author: Deloitte (Deeksha Singhal)
* Date: [03/15/2017]
* Requirement Description: User story W-004496 - Allow delete of Contacts which do not have activities
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class Contact_TriggerHelper {
    
     BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(UserInfo.getUserId());
    
    /*********************************************************************************************************
    * Author:Deloitte
    * Date: [02/16/2017]
    * Requirement Description: User story W-004496 - Allow delete of Contacts which do not have activities
    * Date Modified                Modified By                  Description of the update    
    *********************************************************************************************************/
    public Map<Id,List<String>> checkforActivities (List<Contact> lstTFSContact){
    
    Set<Id> setId = new Set<Id>();
    Map<Id,List<String>> tobedeletedMap = new Map<Id,List<String>>();
    Map<Id,User> portalUserMap = new Map<Id,User>([SELECT Id,ContactId from User where IsPortalEnabled = TRUE]);
            for(Contact oContact : [SELECT Id, (SELECT Id,IsRecurrence, StartDateTime, EndDateTime from Events), (SELECT Id,Status from Tasks) FROM Contact WHERE Id IN:lstTFSContact]){
                    if(oContact.Events!= NULL && !oContact.Events.isEmpty()){
                       List<String> errorLst = new List<String>{Label.UI_Error_Message_Contact_Deletion_Error};
                       tobedeletedMap.put(oContact.Id,errorLst);     
                    }
                    if(oContact.Tasks!= NULL && !oContact.Tasks.isEmpty()){
                       List<String> errorLst = new List<String>{Label.UI_Error_Message_Contact_Deletion_Error};
                       tobedeletedMap.put(oContact.Id,errorLst);
                    }
                    for(User oUser: portalUserMap.values()){
                        if(oUser.ContactId == oContact.Id){
                         List<String> errorLst = new List<String>{Label.UI_Error_Message_Contact_Has_Portal_User};
                         tobedeletedMap.put(oContact.Id,errorLst);
                        }
                    }  
              }
         return tobedeletedMap;     
    }
    /*********************************************************************************************************
    * Author:Deloitte
    * Date: [02/16/2017]
    * Requirement Description: User story W-004496 - Allow delete of Contacts which do not have activities
    * Date Modified                Modified By                  Description of the update    
    *********************************************************************************************************/
    @future
    public static void deActivateUsers(Set<Id> setId){ 
        List<User> lstUser = new List<User>();  
        
        for(Id ide:setId){
            User usr = new User(Id=ide);
            usr.isActive = false;
            usr.IsPortalEnabled = false;
                   
            lstUser.add(usr);               
        } 
        try{        
            if(!lstUser.isEmpty()){
               update lstUser;
               
            } 
        }catch (Exception err){
            createErrorLog(err.getStackTraceString(),err.getLineNumber(),'Contact_TriggerHelper.deActivateUsers');
        }   
      
    }
    /*********************************************************************************************************
    * Author:Deloitte
    * Date: [02/16/2017]
    * Requirement Description: User story W-004748 - Allow deactivation of Contacts which do not have activities
    * Date Modified                Modified By                  Description of the update    
    *********************************************************************************************************/
    public  void checkforPortalUsers(List<Contact> lstContact){
        Map<Id,Id> portalUserMap = new Map<Id,Id>();
        Set<Id> setId = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        for(User usr: [SELECT Id,ContactId from User where IsPortalEnabled = TRUE]){
            portalUserMap.put(usr.ContactId,usr.Id);
        }
        for(Contact oc : lstContact){
            if(oc.Status__c!= NULL && oc.Status__c.equals(TFS_Utility.INACTIVE)){
              setId.add(portalUserMap.get(oc.Id));
                setContactIds.add(oc.Id);     
            }       
        }
        if(!setId.isEmpty()){
            TFS_Utility.clearCPValuesUtility(setContactIds);
            Contact_TriggerHelper.deActivateUsers(setId);
        }  
    }
    
    /*********************************************************************************************************
    * Author:Deloitte
    * Date: [04/17/2017]
    * Requirement Description: User story W-005150 : Update/Delete : Include Dealer Principal and General Manager on Dealer Demographic
    * Date Modified                Modified By                  Description of the update    
    *********************************************************************************************************/
     public void StampPrincipalGenManager(set<Id> TargetAccountIds){
         map<id, account> mapChangeAccountContacts = new map<id, account>();
         account tempAccount;
         //Fetching contacts to get latest Gm and DP for each account to populate on account object
         for(account accWithCon: [select id, Related_Account__c, (select id, name, Title__c, Status__c from contacts where (Title__c =:TFS_Utility.GENERAL_MANAGER OR Title__c =:TFS_Utility.DEALER_PRINCIPAL) AND Status__c='Active' ORDER BY LastModifiedDate DESC) from account where id in : TargetAccountIds]){
             if(accWithCon.Related_Account__c == null){
                 if(!accWithCon.contacts.isEmpty()){   
                     tempAccount = new account(); 
                     tempAccount.id = accWithCon.id;
                     for(contact con :accWithCon.contacts){ 
                         if(!mapChangeAccountContacts.containsKey(tempAccount.id)){ 
                             if(con.Title__c == TFS_Utility.GENERAL_MANAGER)
                                 tempAccount.General_Manager__c = con.id;
                             if(con.Title__c == TFS_Utility.DEALER_PRINCIPAL){ 
                                 tempAccount.Dealer_Principal__c= con.id;}
                             mapChangeAccountContacts.put(tempAccount.id, tempAccount);
                         }
                         else{
                             account accVal = mapChangeAccountContacts.get(tempAccount.id);
                             if(con.Title__c == TFS_Utility.GENERAL_MANAGER && accVal.General_Manager__c == null)
                                 tempAccount.General_Manager__c = con.id;
                             if(con.Title__c == TFS_Utility.DEALER_PRINCIPAL && accVal.Dealer_Principal__c== null)
                                 tempAccount.Dealer_Principal__c= con.id;
                                 mapChangeAccountContacts.put(tempAccount.id, tempAccount);
                         }
                     }
                     account existingAccountInMap = mapChangeAccountContacts.get(tempAccount.id);
                     if(existingAccountInMap!=null){
                         if(existingAccountInMap.General_Manager__c==null)
                             mapChangeAccountContacts.get(tempAccount.id).General_Manager__c =null;
                         if(existingAccountInMap.Dealer_Principal__c==null)
                             mapChangeAccountContacts.get(tempAccount.id).Dealer_Principal__c=null;
                        }
                 }
                 else{
                     tempAccount = new account(); 
                     tempAccount.id = accWithCon.id;
                     tempAccount.Dealer_Principal__c= null;
                     tempAccount.General_Manager__c = null;
                     mapChangeAccountContacts.put(tempAccount.id, tempAccount);
                 }
             }
         }

        try{  
            //Updating account with DP and GM values 
            if(mapChangeAccountContacts.values() != null && !mapChangeAccountContacts.values().isEmpty()){
                update mapChangeAccountContacts.values();  
            }
         }
         catch (Exception err){
             createErrorLog(err.getStackTraceString(),err.getLineNumber(),'Contact_TriggerHelper.StampPrincipalGenManager');   
         }      
    }
    
    public static void createErrorLog(string errMsg, integer lineNumber,String logName){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = logName, Log_Message__c = 'SFDC__LOG: '+errMsg+' Line: '+lineNumber, Log_Type__c = 'Trigger Helper' , Log_Severity__c = 'HIGH'); 
        if(errLog!=null){
            insert errLog;
        }
    }
}