public class ContentVersion_TriggerHandler {
    ContentVersion_TriggerHelper conHlpr = new ContentVersion_TriggerHelper();
	public void onBeforeInsert(list<ContentVersion> newListAttachments){
        conHlpr.NoAttachmentUploadByDealerConnectUser(newListAttachments);
    }
}