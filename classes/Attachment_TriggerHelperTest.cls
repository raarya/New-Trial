/********************************************************************************************
* Class Name: Attachment_TriggerHelperTest
* Author:Ritesh Jaiswal (Deloitte)
* Date: [02/2/2017]
* Requirement Description: 
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest(SeeAllData=false)
public class Attachment_TriggerHelperTest {

    static testMethod void TFSC_DealerEventTestMethod() 
    {
        //creating Custom Setting record
        TestUtility.insertCustomSetting();
          TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
        if(tfsA != null)
            insert tfsA;
        Account a = TestUtility.createAccount('Saint Mount','12655', tfsA);
        if(a != null)
            insert a;
        Form__c f = new Form__c(Account__c = a.id, Form_Document_Type__c='1023: Authorization to Share Information',Product_Line__c ='Wholesale', Amount__c =200);
        if(f!=null)
          insert f;
        Task tsk = TestUtility.createTask(); 
        if(tsk != null){
            insert tsk; 
        }  
        Profile Pr = [Select id,name from profile where name='System Administrator' limit 1];
        User usr = TestUtility.createUser(Pr.id);
        usr.TFS_SRM_Title__c ='Credit Analyst';
        if(usr != null)
        insert usr;
        
        
        List<Attachment> attachList = new List<Attachment>();
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attachList.add(new Attachment(Name = 'Unit Test Attachment',body=bodyBlob,parentID = f.id));
        try{
            System.runAs(usr){
                if(attachList != null && attachList .size() > 0){
                    insert attachList ;
                    delete attachList;
                    }
                    
                }
                   
            }
        catch(exception ee){
        }
          
        List<Attachment> attch = TestUtility.createAttachmentForTaskBulkified(tsk,5);
        if(attch != null && attch.size() > 0){
            insert attch;
        }
        Test.startTest();
        List<Attachment> attachments=[select id,parentid  from Attachment limit 20];
        if(attachments != null && attachments.size() > 0){
            Delete attachments;
        }
        
        tsk = [select Attachment__c from task where id=:tsk.id limit 1];
        system.assert(tsk.Attachment__c == false);
        Test.stopTest();
    }
    static testMethod void TFSC_DealerEventTestMethod1() 
    {
        //creating Custom Setting record
        TestUtility.insertCustomSetting();
        
        Event evt = TestUtility.createEvent(); 
        if(evt != null){
            insert evt;  
        }         
      	Test.startTest();
        Attachment_TriggerHandler handler = new Attachment_TriggerHandler();
        List<Attachment> attches = TestUtility.createAttachmentForEventBulkified(evt,5);
        if(attches != null && attches.size() > 0){
        	handler.onBeforeInsert(attches);
            insert attches;
        }
        
        handler.onBeforeUpdate(attches);
        List<Attachment> attachments=[select id,parentid  from Attachment limit 20];
        if(attachments != null && attachments.size() > 0){
            Delete attachments;
        }
        evt= [select Attachment__c from event where id=:evt.id limit 1];
        system.assert(evt.Attachment__c == false);
        
        Test.stopTest();
    }

    
}