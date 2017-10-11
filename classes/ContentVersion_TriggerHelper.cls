/********************************************************************************************************************
* Class Name: TFS_Utility
* Author: Deeksha (Deloitte)
* Date: [06/08/2017]
* Requirement Description:005794 : As a SRM user, I want to be able to upload documents and share with Dealer Connect users.
* Date Modified            Modified By                 Description of the update
    06/08/2017               Deeksha Singhal           
*******************************************************************************************************************/
public with sharing class ContentVersion_TriggerHelper {
    String loggedInUserId = Userinfo.getUserId();
    BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(loggedInUserId);
    /********************************************************************************************
    * Class Name: Attachment_TriggerHelper
    * Author: Deeksha Singhal (Deloitte)
    * Date: [06/08/2017]
    * Requirement Description:W-005794 As a SRM user, I want to be able to upload documents and share with Dealer Connect users.
    ***********************************************************************************************/
    public void NoAttachmentUploadByDealerConnectUser(list<ContentVersion> newListContentVersion){
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('NoAttachmentUploadByDealerConnectUser')){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            for(ContentVersion conVer : newListContentVersion){
                if(profileName==TFS_Utility.PROFILENAME){
                    conVer.addError(TFS_Utility.ERRORMESSAGE2);
                }
            } 
        }
    }
}