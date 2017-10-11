/********************************************************************************************
* Class Name: Dealer_UpdatedASMEmailBatchTest
* Author:Deloitte
* Date: [02/2/2017]
* Requirement Description: 
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
public class Dealer_UpdatedASMEmailBatchTest {
    @testSetup
     public static void createTestData() {  
         TestUtility.insertCustomSetting();  
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago','03');
        if(tfsA!=null)
            insert tfsA;

        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        if(tfsAU!=null)
        insert tfsAU;
        
          List<Account> accLst = new List<Account>();
            accLst.add(TestUtility.createAccount('Test1','4534235', tfsA));
            accLst.add(TestUtility.createAccount('Test2','523234', tfsA));
            if(accLst!=null && !accLst.isEmpty()){
                insert accLst;
            }
            system.assert(accLst.size() == 2);
       }

    static testMethod void Dealer_UpdatedASMEmailBatchTestMethod() {
        Test.startTest();
        Dealer_UpdatedASMEmailBatch batchObj = new Dealer_UpdatedASMEmailBatch();
        id batchid=Database.executeBatch(batchObj);
        Dealer_UpdatedASMEmailScheduler schJob = new Dealer_UpdatedASMEmailScheduler();
        SchedulableContext sc = null;
        String schedule = Label.Scheduling_String;
        System.schedule('Batch Update', schedule, schJob);
        test.stopTest();
        system.assertNotEquals(null, batchid);
    }
    
}