/********************************************************************************************
* Class Name: Contact_TriggerHandler 
* Author: Deloitte
* Date: [03/15/2017]
* Requirement Description: User story W-004496/W-005150 - Allow delete of Contacts which do not have activities
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class Contact_TriggerHandler {
    
    static Boolean isRentry = false;
    Contact_TriggerHelper helper = new Contact_TriggerHelper();
    
    public Map<Id,List<String>> onBeforeDelete(List<Contact> lstContactNew)
    {
      return helper.checkforActivities(lstContactNew);
    }
    
    public void onAfterUpdate(List<Contact> newConList, Map<id,Contact> oldConMap){
        helper.checkforPortalUsers(newConList); 
        
        set<Id> TargetAccountIds= new set<Id>();  
        for(contact con : newConList){
            if((con.Title__c == TFS_Utility.GENERAL_MANAGER || con.Title__c == TFS_Utility.DEALER_PRINCIPAL 
                                          || oldConMap.get(con.id).Title__c == TFS_Utility.GENERAL_MANAGER 
                                          || oldConMap.get(con.id).Title__c == TFS_Utility.DEALER_PRINCIPAL) 
                                          && con.Title__c != oldConMap.get(con.id).Title__c 
                                          && con.AccountId != null){
                TargetAccountIds.add(con.AccountId);
            }
        }
         
        helper.StampPrincipalGenManager(TargetAccountIds);    
    }
    
    public void onAfterInsert(List<Contact> newConList){
        set<Id> TargetAccountIds= new set<Id>();  
        for(contact con : newConList){
            if((con.Title__c == TFS_Utility.GENERAL_MANAGER || con.Title__c == TFS_Utility.DEALER_PRINCIPAL)  
                                                            && con.AccountId != null){
                TargetAccountIds.add(con.AccountId);
            }
        }
         
        helper.StampPrincipalGenManager(TargetAccountIds);    
    }
    public void onAfterDelete(List<Contact> oldConList){
        set<Id> TargetAccountIds= new set<Id>();  
        for(contact con : oldConList){
            if((con.Title__c == TFS_Utility.GENERAL_MANAGER || con.Title__c == TFS_Utility.DEALER_PRINCIPAL) 
                                                            && con.AccountId != null){
                TargetAccountIds.add(con.AccountId);
            }
        }
         
        helper.StampPrincipalGenManager(TargetAccountIds);     
    }
}