/********************************************************************************************
* Class Name: Attachment_TriggerHelper
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/20/2017]
* Requirement Description: Updating the task and event field when the attachment is deleted from the related object
* Date Modified     27 Feb           Modified By   Ritesh Jaiswal               Description of the update
 
***********************************************************************************************/
public with sharing class Attachment_TriggerHelper{
    
    //getting the User ID of the loggedin User
    String loggedInUserId = Userinfo.getUserId();
    BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(loggedInUserId);
    
    //Method to check all the related attachment and task Ids related to current attachment in the context    
    public void checkTaskIDRelatedToAttachment(list<Attachment> AttList){       
        String sobjType=null;
        //Using set and list object for DML operation        
        List<Task> lstTsk = new List<Task>();
        List<Event> lstEvt = new List<Event>();
        Set<Id> setTskIds = new Set<Id>();
        
        try{
            //checking the custom setting for the trigger
            if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('checkTaskIDRelatedToAttachment')){
                {
                    // For each attachment checking whether they are the event type or task type        
                    for(Attachment attach : AttList){
                        if(attach.ParentId.getSobjectType() == Task.SobjectType){  
                            setTskIds.add(attach.ParentId);
                            sobjType=TFS_Utility.TASK;
                        }else if(attach.ParentId.getSobjectType() == Event.SobjectType){   
                            setTskIds.add(attach.ParentId);
                            sobjType=TFS_Utility.EVENT;
                        }
                    }
                    //If the CRUD is on the task object then updating the field on the task object
                    
                    if(sobjType==TFS_Utility.TASK){
                        List<Task> lstTskIn = new List<Task>();
                        if(setTskIds!=null)
                            lstTskIn =([select id from task where id in :setTskIds limit 50000]);
                        if(lstTskIn != null && !lstTskIn.isEmpty()){
                            for(Task tIn : lstTskIn )
                            {
                                tIn.Attachment__c=false;
                                lstTsk.add(tIn);
                            }
                        }
                        update lstTsk;
                    }else{
                        //If the CRUD is on the event object then updating the field on the event object
                        List<Event> lstEvtIn = new List<Event>();
                        lstEvtIn =([select id from event where id in :setTskIds limit 50000]);
                        if(lstEvtIn != null && !lstEvtIn.isEmpty())
                        {
                            for(Event eIn : lstEvtIn )
                            {
                                eIn.Attachment__c=false;
                                lstEvt.add(eIn);
                            }
                        }
                        update lstEvt;
                    }
                }  
            }
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'TFSC_EventTriggerHelper.OnEventDeleteController', Log_Message__c = TFS_Utility.SFDC_LOG+err.getStackTraceString()+TFS_Utility.LINE+err.getLineNumber(), Log_Type__c = TFS_Utility.TRIGGER_HELPER , Log_Severity__c = TFS_Utility.HIGH); 
            if(errLog!=null)
                insert errLog;
        } 
    }
    /********************************************************************************************
    * Class Name: Attachment_TriggerHelper
    * Author: Deeksha Singhal (Deloitte)
    * Date: [06/08/2017]
    * Requirement Description:W-005794 As a SRM user, I want to be able to upload documents and share with Dealer Connect users.
    ***********************************************************************************************/
    public void attachmentLimitations(list<Attachment> newListAttachments){
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('attachmentLimitations')){
            Id userId=userinfo.getUserId();
            set<String> Titles = new set<String>{TFS_Utility.NATIONAL_ACCOUNT_MANAGER, TFS_Utility.SALESHQADMIN,TFS_Utility.REGION_MANAGER, TFS_Utility.REGION_AA, TFS_Utility.DSM, TFS_Utility.DSSM, TFS_Utility.DSSO_AA, TFS_Utility.ASM,TFS_Utility.SERVICE_OPS};
            User userProfile = [SELECT TFS_SRM_Title__c FROM User where id =: userId];
            for(Attachment Attach : newListAttachments){
                String parentFormID = Attach.parentID;
                if(parentFormID.subString(0,3)=='a0c'){
                    if(!trigger.isDelete){
                        if(userProfile != null && !Titles.contains(userProfile.TFS_SRM_Title__c)){
                            Attach.addError(TFS_Utility.ERROR_MESSAGE_ATTACH1);
                        }
                    }
                    else{
                        Attach.addError(TFS_Utility.ERROR_MESSAGE_ATTACH2);
                    }
                }
            }
        }
    }
}