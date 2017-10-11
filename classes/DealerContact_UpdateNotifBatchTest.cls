/********************************************************************************************
* Class Name: DealerContact_UpdateNotifBatchTest 
* Author:Ritesh Jaiswal (Deloitte)
* Date: [02/2/2017]
* Requirement Description: 
* Date Modified                Modified By                  Description of the update
* [09/04/2017]               Rajeev Arya (Deloitte)        W-006695:SRM_BR_BS_009 – Automated Notifications: New Dealer Record
***********************************************************************************************/
@isTest(SeeAllData=false)
public class DealerContact_UpdateNotifBatchTest {
    @testSetup
    public static void createTestData() {    
        //creating Custom Setting record
        TestUtility.insertCustomSetting();
        
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
        if(tfsA!=null)
        insert tfsA;

        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        if(tfsAU!=null)
        insert tfsAU;
        
        Account acc = TestUtility.createAccount('Saint Mount','1324424',tfsA);
        if(acc!=null)
        insert acc;

        //Creating test data for the contact related to account
        List<Contact> con =TestUtility.createContactBulkified(acc,5);
        if(con!=null)
        insert con;
        
    }
    
    static testMethod void TFSC_DealerContactStatusTestMethod() 
    {
        Test.startTest();
        //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
        list<Contact> lstCon = [select id from contact limit 5];
        User u = TestUtility.createPortalUser(lstCon[0].id);
        insert u;
        test.stopTest();
        
        System.runAs(u){
        	lstCon[0].Phone = '5435678901';
        	update lstCon[0];
        }
        //[09/04/2017]-Rajeev Arya (Deloitte)-W-006695
        
        //Calling the batch class related to account
        DealerContact_UpdateNotificationBatch batchJob = new DealerContact_UpdateNotificationBatch();
        Database.executebatch(batchJob);
        //Calling the schedule class related to account
        DealerContact_UpdateNotifScheduler schJob = new DealerContact_UpdateNotifScheduler();
        String sch = label.Scheduling_String; 
        system.schedule('Test Territory Check', sch, schJob);
        System.AssertEquals(database.countquery('SELECT COUNT() FROM contact'),6);
        
    }
}