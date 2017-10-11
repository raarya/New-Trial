/********************************************************************************************
* Class Name: Event_TriggerHelper 
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/20/2017]
* Requirement Description:
* Date Modified                Modified By                  Description of the update
8/28/2017                    Mounika Darisi             setSubjectOnUpdate
8/28/2017                    Mounika Darisi             setSubjectOnInsert
***********************************************************************************************/

public with sharing class Event_TriggerHelper {

//getting the User ID of the loggedin User
String LoggedinUserId = Userinfo.getUserId();
BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(LoggedinUserId);

//Method in handler class to handle the restriction of deletion
public void onEventDeleteController(Event[] EventObjDel){
    try{
        //checking the custom setting for the trigger
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('onEventDeleteController')){
            {
                for (Event evt : EventObjDel)      
                {
                    //Checking the logged in user as well as the created user   
                    if(evt.ownerid!=LoggedinUserId){                        
                        //Adding the error from the label  
                        evt.ownerid.addError(System.Label.Event_Delete_Validation_Error_Message);
                    } 
                    //Checking the contact type of task   
                    if(evt.Contact_Type__c.contains('CFPB-Related')){
                        //Adding the error from the label   
                        evt.ownerid.addError(System.Label.Event_Delete_ContactType_Error_Message);
                    }
                }
            }
        }  
    }
    catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.OnEventDeleteController', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Trigger Helper' , Log_Severity__c = 'HIGH'); 
        if(errLog!=null)
            insert errLog;
    } 
}

//updating the event based on insert of attachment on event insert
//Modified by Bhargavaramu as part of bug fix
public void onEventAttachmentInsert(List<Event> newList){
    try{
        //checking the custom setting for the trigger
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('onEventAttachmentInsert'))
        { 
            for(Event evtUpd : [SELECT Id,(SELECT Id FROM Attachments LIMIT 1)FROM Event WHERE Id IN : newList limit 49999]) {
                if(evtUpd.attachments != null && evtUpd.attachments.size()>0){
                    evtUpd.Attachment__c=true;
                }
            }
        }
    }catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.onEventAttachmentInsert', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
            insert errLog;
    }
}

//updating the event based on insert of attachment on event update
//Modified by Bhargavaramu as part of bug fix
public void onEventAttachmentUpdate(List<Event> newList,List<Event> oldList){
    try{
        //checking the custom setting for the trigger
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('onEventAttachmentUpdate')) {  
            // Query for the attachment children of the tasks
            for(Event evtUpd : [SELECT Id,(SELECT Id FROM Attachments LIMIT 1)FROM Event WHERE Id IN :newList limit 49999]){    
                if(evtUpd.attachments != null && evtUpd.attachments.size()>0){
                    evtUpd.Attachment__c=true;
                }else{ 
                    evtUpd.Attachment__c=false; 
                }  
            }
        }
    }
    
    catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.onEventAttachmentUpdate', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
            insert errLog;
    }
}

//validating to assign events only to account team members if DSSO Name and Area ID on Account is not null
public void onEventMemberAssign(List<Event> EventAttInsrt){
    
    Set<id> accountIds= new Set<id>();
    Set<id> setUsrIds= new Set<id>();
    Boolean check= true;
    try{
        //checking the custom setting for the trigger
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('onEventMemberAssign'))
        { 
            for (Event evt : EventAttInsrt) {
                if(evt.whatId !=null){
                    accountIds.add(evt.whatId); 
                }
            }
            
            
            for(Account evtAsm : [select Area_Id__c, DSSO_Name__c,OwnerId from account where id in:accountIds limit 49999] )
            { 
                if((evtAsm.Area_Id__c !=null)&&(evtAsm.DSSO_Name__c!=null)) {
                    setUsrIds.add(evtAsm.OwnerId);
                    check=false;
                }else{
                    check=true;
                }
            }
            
            //retrieving the team members for the parent account
            for(AccountTeamMember accTeamM : [SELECT UserId FROM AccountTeamMember where AccountId in :accountIds limit 49999])
            {
                setUsrIds.add(accTeamM.UserId); 
            }
            
            setUsrIds.add(UserInfo.getUserId());
            //adding error if the event is assigned to non team member
            for(Event ownrId :EventAttInsrt)
            {
                if(!setUsrIds.contains(ownrId.OwnerId)  )
                {
                    if(!check){
                        ownrId.OwnerId.addError(Label.Dealer_TeamMember_Validation_Error_Message);
                    }
                }
            }
        }
    }
    
    catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.onEventAttachmentUpdate', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
            insert errLog;
    }
}
/*********************************************************************************************************
* Author:Deloitte
* Date: [03/23/2017]
* Requirement Description: User story W-004873 - Populated Location from the RelatedTo on Event
* Date Modified                Modified By                  Description of the update    
*********************************************************************************************************/
public void populateLocation(List<Event> EventAttInsrt){/*
  try{
    Map<Id,Id> tskAccountMap = new Map<Id,Id>();
    Map<Id,Account> accountMap;
    for(Event oEvent : EventAttInsrt){
        // Check if the Related to on Event is an Account
        if(oEvent.WhatId != NULL && String.valueOf(oEvent.WhatId).startsWith(Account.sObjectType.getDescribe().getKeyPrefix())){
            tskAccountMap.put(oEvent.Id,oEvent.WhatId);         
        }
    }
    //Prepare an Account map for the RelatedTo Accounts
    if(tskAccountMap.values()!= NULL && !tskAccountMap.values().isEmpty()){
        accountMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE ID IN :tskAccountMap.values()]);    
    }
    //Update the location only if the value is blank
    for(Event oEvent: EventAttInsrt){
        if(oEvent.WhatId != NULL && accountMap!= NULL && NULL != accountMap.get(oEvent.WhatId)){
          if(oEvent.Location == NULL && String.isBlank(oEvent.Location)){
            oEvent.Location = accountMap.get(oEvent.WhatId).Name; 
          }             
        }           
    }
  } catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.populateLocation', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
        insert errLog;
    } */ //ommented to reimplement Location update from Account Address.      
 }

/*********************************************************************************************************
* Author:Deloitte
* Date: [03/23/2017]
* Requirement Description: User story W-004873 - Populated Location from the RelatedTo on Event
* Date Modified                Modified By                  Description of the update    
*********************************************************************************************************/
public void populateAccountLocation(Map<Id,Event> eventNew, Map<Id,Event> eventOld){/*
 try{
    Set<Id> accountSet = new Set<Id>();
    Map<Id,Account> accountMap;
    if(eventNew != NULL && !eventNew.isEmpty()){
     for(Event oEvent: eventNew.values()){
       // Check if the Related to on Event is changed
       String oldRelatedTo = String.valueOf(eventOld.get(oEvent.Id).WhatId);
       if(oldRelatedTo != NULL && !String.isBlank(oldRelatedTo) && !String.valueOf(oEvent.WhatId).equals(oldRelatedTo)){
          accountSet.add(oEvent.WhatId);           
       }         
     }
   } 
   //Prepare an Account map for the RelatedTo Accounts
   if(!accountSet.isEmpty()){
    accountMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE ID IN :accountSet]);       
   }
   //Update the location only if the value is changed
   if(eventNew != NULL && !eventNew.isEmpty()){
     for(Event oEvent: eventNew.values()){
         if(oEvent.WhatId != NULL && accountMap!= NULL && accountMap.get(oEvent.WhatId)!= NULL
         && oEvent.Location == eventOld.get(oEvent.Id).Location){
            oEvent.Location = accountMap.get(oEvent.WhatId).Name; 
          }       
       }
    } 
  } catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'Event_TriggerHelper.populateAccountLocation', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
        insert errLog;
    }    
     */ // commented to reimplement Location update based on account address
}
 /********************************************************************************************
* Class Name: Event_TriggerHelper
* Author: Mounika Darisi (Deloitte)
* Date: [08/25/2017]
* Requirement Description: Requirement Description: W-5884 : As an SRM User, I want the Account name,number as subject and Address as Location to be automatically updated in the task or event so that I can easily identify my activities.
***********************************************************************************************/
public void setSubjectOnInsert(list<Event> lstNewEvent){
    if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('setSubjectOnInsert'))
    {
        if(lstNewEvent != null){
            set<Id> setEventAccounts = new set<Id>();
            set<Id> setAllEventContacts = new set<Id>();
            map<Id,Id>mapAllContactIdAccountId = new map<Id,Id>();
            map<Id,String>mapAccountIdNameNumber = new map<Id,String>();
            map<Id,String>mapAccountIdAddress = new map<Id,String>();
            
            for(Event objEvent : lstNewEvent){
                if((string.isBlank(objEvent.subject) || string.isBlank(objEvent.Location)) && objEvent.WhatId != null){
                    if(String.valueOf(objEvent.WhatId.getsobjecttype()) == TFS_Utility.Account){
                        setEventAccounts.add(objEvent.WhatId);
                    }
                }
                if(objEvent.WhoId != null){
                    if(String.valueOf(objEvent.WhoId.getsobjecttype()) == TFS_Utility.Contact ){
                        setAllEventContacts.add(objEvent.WhoId);
                    }
                }
            }   
            if(setAllEventContacts != null && !setAllEventContacts.isEmpty()){
                for(Contact objContact : [select id,AccountId from contact where id IN:setAllEventContacts]){
                    if(objContact.AccountId != null){
                        mapAllContactIdAccountId.put(objContact.Id,objContact.AccountId);
                    }
                }
            }
            if((setEventAccounts != null && !setEventAccounts.isEmpty()) || (mapAllContactIdAccountId.values() != null && !mapAllContactIdAccountId.values().isEmpty())){
                String strAccountAddress = TFS_Utility.BLANK;
                for(Account objAccount : [Select id,name,AccountNumber,ShippingStreet,shippingcity,shippingstate,
                                            shippingcountry,shippingpostalcode 
                                            from Account 
                                            Where id in :setEventAccounts 
                                            OR ID IN:mapAllContactIdAccountId.values()]){
                    mapAccountIdNameNumber.put(objAccount.Id,objAccount.Name+' '+objAccount.AccountNumber);
                     strAccountAddress = TFS_Utility.getCompleteAddress(objAccount.ShippingStreet,objAccount.shippingcity,objAccount.shippingstate,objAccount.shippingcountry,objAccount.shippingpostalcode);
                    mapAccountIdAddress.put(objAccount.Id,(strAccountAddress != null && strAccountAddress != '' && strAccountAddress.length() >255 )? strAccountAddress.substring(0, 255) : strAccountAddress);
                }
            }
            
            for(Event objEvent : lstNewEvent){
                if(objEvent.WhoId != null){
                    if(String.valueOf(objEvent.WhoId.getsobjecttype()) == TFS_Utility.Contact && mapAllContactIdAccountId.containskey(objEvent.WhoId)){
                        objEvent.WhatId = mapAllContactIdAccountId.get(objEvent.WhoId);
                    }
                }
                if(string.isBlank(objEvent.subject) && objEvent.WhatId != null){
                    if(String.valueOf(objEvent.WhatId.getsobjecttype()) == TFS_Utility.Account){
                        objEvent.subject = mapAccountIdNameNumber.get(objEvent.WhatId);
                    }
                }
                if(string.isBlank(objEvent.Location) && objEvent.WhatId != null){
                    if(String.valueOf(objEvent.WhatId.getsobjecttype()) == TFS_Utility.Account){
                        objEvent.Location = mapAccountIdAddress.get(objEvent.WhatId);
                    }
                }
            }
        }
    }
}
 /********************************************************************************************
* Class Name: Event_TriggerHelper
* Author: Mounika Darisi (Deloitte)
* Date: [08/25/2017]
* Requirement Description: Requirement Description: W-5884 : As an SRM User, I want the Account name,number as subject and Address as Location to be automatically updated in the task or event so that I can easily identify my activities.
***********************************************************************************************/
public void setSubjectOnUpdate(map<id,Event> mapNewEvent, map<id,Event> mapOldEvent){
    if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('setSubjectOnUpdate'))
    {
        set<Id> setEventAccounts = new set<Id>();
        set<Id> setAllEventContacts = new set<Id>();
        map<Id,Id> mapAllContactIdAccountId = new map<Id,Id>();
        map<Id,String>mapAccountIdNameNumber = new map<Id,String>();
        map<Id,String>mapAccountIdAddress = new map<Id,String>();

        for(Id evntID : mapNewEvent.keySet()){
            if((mapOldEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != mapOldEvent.get(evntID).WhatId) || (( string.isBlank(mapNewEvent.get(evntID).subject) || string.isBlank(mapNewEvent.get(evntID).Location)) && mapNewEvent.get(evntID).WhatId != null)){
                if(String.valueOf(mapOldEvent.get(evntID).WhatId.getsobjecttype()) == TFS_Utility.Account){
                    setEventAccounts.add(mapOldEvent.get(evntID).WhatId);
                }
                if(String.valueOf(mapNewEvent.get(evntID).WhatId.getsobjecttype()) == TFS_Utility.Account){
                    setEventAccounts.add(mapNewEvent.get(evntID).WhatId);
                }
            }
           if((mapNewEvent.get(evntID).WhoId  != null && mapOldEvent.get(evntID).WhoId != null && mapNewEvent.get(evntID).WhoId != mapOldEvent.get(evntID).WhoId)|| (mapNewEvent.get(evntID).WhoId  != null && mapOldEvent.get(evntID).WhoId == null)){
               		if(mapNewEvent.get(evntID).WhoId != null && String.valueOf(mapNewEvent.get(evntID).WhoId.getsobjecttype()) == TFS_Utility.Contact ){
                        setAllEventContacts.add(mapNewEvent.get(evntID).WhoId);
						setEventAccounts.add(mapOldEvent.get(evntID).WhatId);

                    }
                    if(mapOldEvent.get(evntID).WhoId != null && String.valueOf(mapOldEvent.get(evntID).WhoId.getsobjecttype()) == TFS_Utility.Contact ){
                        setAllEventContacts.add(mapOldEvent.get(evntID).WhoId);
						setEventAccounts.add(mapOldEvent.get(evntID).WhatId);
                    }
            }
        }
        if(setAllEventContacts != null && !setAllEventContacts.isEmpty()){
                for(Contact objContact : [select id,AccountId from contact where id IN:setAllEventContacts]){
                    if(objContact.AccountId != null){
                        mapAllContactIdAccountId.put(objContact.Id,objContact.AccountId);
                    }
                }
            }
        if((setEventAccounts != null && !setEventAccounts.isEmpty()) || (mapAllContactIdAccountId.values() != null && !mapAllContactIdAccountId.values().isEmpty())){
        String strAccountAddress = TFS_Utility.BLANK;
            for(Account objAccount : [Select id,name,AccountNumber,ShippingStreet,shippingcity,shippingstate,
                                        shippingcountry,shippingpostalcode 
                                        from Account 
                                        Where Id IN :setEventAccounts
                                        OR Id IN: mapAllContactIdAccountId.values()]){
                mapAccountIdNameNumber.put(objAccount.Id,objAccount.Name+' '+objAccount.AccountNumber);
                 strAccountAddress = TFS_Utility.getCompleteAddress(objAccount.ShippingStreet,objAccount.shippingcity,objAccount.shippingstate,objAccount.shippingcountry,objAccount.shippingpostalcode);
                mapAccountIdAddress.put(objAccount.Id,(strAccountAddress != null && strAccountAddress.length() >255 )? strAccountAddress.substring(0, 255) : strAccountAddress);

            }
        }        
        for(Id evntID : mapNewEvent.keyset()){
            if(mapNewEvent.get(evntID).WhoId != null){
                if(String.valueOf(mapNewEvent.get(evntID).WhoId.getsobjecttype()) == TFS_Utility.Contact && mapAllContactIdAccountId.containskey(mapNewEvent.get(evntID).WhoId)){
                    mapNewEvent.get(evntID).WhatId = mapAllContactIdAccountId.get(mapNewEvent.get(evntID).WhoId);
                }
            }
            if(mapNewEvent.get(evntID).WhatId != null && mapOldEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != mapOldEvent.get(evntID).WhatId){
                if(String.valueOf(mapOldEvent.get(evntID).WhatId.getsobjecttype()) == TFS_Utility.Account){                     
                    if((!string.isBlank(mapNewEvent.get(evntID).subject) && mapNewEvent.get(evntID).subject==mapAccountIdNameNumber.get(mapOldEvent.get(evntID).WhatId)) || string.isBlank(mapOldEvent.get(evntID).subject)|| mapOldEvent.get(evntID).subject == null){
                        mapNewEvent.get(evntID).subject = mapAccountIdNameNumber.get(mapNewEvent.get(evntID).WhatId);
                    }
                
                    if((!string.isBlank(mapNewEvent.get(evntID).Location) && mapNewEvent.get(evntID).Location==mapAccountIdAddress.get(mapOldEvent.get(evntID).WhatId)) || string.isBlank(mapOldEvent.get(evntID).Location)|| mapOldEvent.get(evntID).Location == null){
                        mapNewEvent.get(evntID).Location = mapAccountIdAddress.get(mapNewEvent.get(evntID).WhatId);
                    }
                }
            }else if((mapNewEvent.get(evntID).subject == null || string.isBlank(mapNewEvent.get(evntID).subject)) && mapNewEvent.get(evntID).WhatId != null){
                if(String.valueOf(mapNewEvent.get(evntID).WhatId.getsobjecttype()) == TFS_Utility.Account){
                    mapNewEvent.get(evntID).subject = mapAccountIdNameNumber.get(mapNewEvent.get(evntID).WhatId);
                }
            }
            if((mapNewEvent.get(evntID).Location == null || string.isBlank(mapNewEvent.get(evntID).Location)) && mapNewEvent.get(evntID).WhatId != null){
                if(String.valueOf(mapNewEvent.get(evntID).WhatId.getsobjecttype()) == TFS_Utility.Account){
                    mapNewEvent.get(evntID).Location = mapAccountIdAddress.get(mapNewEvent.get(evntID).WhatId);
                }
            }
        }
    }
}
/********************************************************************************************
* Class Name: Event_TriggerHelper
* Author: Mounika (Deloitte)
* Date: [09/21/2017]
* Requirement Description: Requirement Description: W-5884 :Remove Contact from Event if Account is changed.
***********************************************************************************************/
public void onEventAccountUpdate(Map<Id,Event> mapNewEvent,Map<Id,Event> mapOldEvent){   
    List<Event> lstEventToUpdate = new List<Event>();  
	Set<Event> setEventToUpdate = new Set<Event>();  
	Set<Id> setContactId = new Set<Id>(); 	
	map<Id,Id> mapContactIdAccountId = new map<Id,Id>(); 	
    try{
        if(mapNewEvent != null && mapOldEvent != null){
			for(Id evntID: mapOldEvent.keyset()){
				if(mapNewEvent.get(evntID).whoId != null && mapOldEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != mapOldEvent.get(evntID).WhatId){
					if(String.valueOf(mapNewEvent.get(evntID).whoId.getsobjecttype()) == TFS_Utility.Contact){
						setContactId.add(mapNewEvent.get(evntID).whoId);
					}
				}
			}
			if(!setContactId.isEmpty()){
				for(Contact objContact :[Select id,AccountId from Contact Where Id in:setContactId]){
					mapContactIdAccountId.put(objContact.Id,objContact.AccountId);
				}
			}
			for(Id evntID: mapOldEvent.keyset()){
				if(mapNewEvent.get(evntID).whoId != null && mapOldEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != null && mapNewEvent.get(evntID).WhatId != mapOldEvent.get(evntID).WhatId && mapContactIdAccountId.containskey(mapNewEvent.get(evntID).whoId) && mapContactIdAccountId.get(mapNewEvent.get(evntID).whoId) != mapNewEvent.get(evntID).WhatId){
					lstEventToUpdate.add(mapNewEvent.get(evntID));	
				}
			}
			if(lstEventToUpdate != null && !lstEventToUpdate.IsEmpty()){
			String strEventsToUpdate = json.serialize(lstEventToUpdate);
				updateEventContact(strEventsToUpdate);
			}
		}
    }
    catch (Exception err){
        Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'TFSC_DealerTriggerHelper.onEventAccountUpdate', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = 'HIGH') ; 
        if(errLog!=null)
        insert errLog;
    }
}

/********************************************************************************************
* Class Name: Event_TriggerHelper
* Author: Mounika (Deloitte)
* Date: [09/21/2017]
* Requirement Description: W-5884 :Future method to perform update on after update,Remove Contact from Event if Account is changed.
***********************************************************************************************/
@future 
public static void updateEventContact(String strEventsToUpdate){
	List<Event> lstEventToUpdate = (List<Event>)Json.deserialize(strEventsToUpdate,List<Event>.class);
	for(Event objEvent: lstEventToUpdate ){
		objEvent.WhoId = null;
	}
    if(lstEventToUpdate != null && !lstEventToUpdate.IsEmpty()){
		update lstEventToUpdate;
    }
}
}