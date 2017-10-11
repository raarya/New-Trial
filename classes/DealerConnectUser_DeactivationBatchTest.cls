/********************************************************************************************************************
* Class Name: DealerConnectUser_DeactivationBatchTest
* Author: Deeksha Singhal (Deloitte)
* Date: [07/05/2017]
* Requirement Description:Test class for DealerConnectUser_DeactivationBatch 
* Date Modified                Modified By                  Description of the update

*******************************************************************************************************************/
@isTest(SeeAllData=false)
public class DealerConnectUser_DeactivationBatchTest{
    @testSetup
    public static void createTestData() {
        //creating TFS Area on ATLANTA DSSO
        TFS_Area__c tfsA1 = TestUtility.createTFSArea('ATLANTA', '02');
        if(tfsA1 != null){
            insert tfsA1;
        }
        
        //creating Account
        Account Account1 = TestUtility.createAccount('Account1','186523', tfsA1);
        if(Account1 != null){
            insert Account1;
        }
        
        //creating Contact
        List<Contact> listCon= TestUtility.createContactBulkified(Account1, 10);
        if(!listCon.isEmpty()){
            insert listCon;
        }
        
        //Creating Portal Users
        Profile profileDetail = [SELECT Id FROM Profile WHERE Name = 'Community Dealer' LIMIT 1];
        list<User> listUser = TestUtility.createListUser(profileDetail.Id, 10);
        integer i=0;
        for(User u :listUser){
            u.ContactId= listCon[i].Id;
            i++;
        }
        if(!listUser.isEmpty())
            insert listUser;
    }
    static testMethod void DealerConnectUser_DeactivationBatchTestMethod(){
        
        DealerConnectUser_DeactivationBatch batchJob= new DealerConnectUser_DeactivationBatch();
        batchJob.lastLoginDays =0;
        String sch = label.Scheduling_String; 
        Test.startTest();
        Database.executebatch(batchJob);
        system.schedule('Test DealerConnectUser_DeactivationBatch', sch, batchJob);
        Test.stopTest();
    }
}