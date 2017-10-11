/********************************************************************************************
* Class Name: Attachment_TriggerHandler 
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/21/2017]
* Requirement Description: W-004023 
1. I am not able to update or delete tasks or events that are owned by others.
2. I am able to update tasks or events I own.
* Date Modified     27 Feb           Modified By   Ritesh Jaiswal               Description of the update
***********************************************************************************************/

public with sharing class Attachment_TriggerHandler {
    Attachment_TriggerHelper attHlpr = new Attachment_TriggerHelper();
        public void onBeforeInsert(list<Attachment> newListAttachments){
        attHlpr.attachmentLimitations(newListAttachments);
        }
        
    public void onBeforeUpdate(list<Attachment> newListAttachments){
        attHlpr.attachmentLimitations(newListAttachments);
        }
        
    public void onBeforeDelete(list<Attachment> attList){
        //Method in helper class to check the attachment parent/related to (Task or Event) and updating the field attachment on the basis of it
        attHlpr.checkTaskIDRelatedToAttachment(attList);
        attHlpr.attachmentLimitations(attList);
        }
}