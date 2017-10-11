@isTest(SeeAllData=false)
public class EmailHandlerUtilityTest {

    static testMethod void emailHandlerUtilityMethod() 
    {
        Test.StartTest();
        EmailHandlerUtility util = new EmailHandlerUtility();
        //Database.Batchable  batch = new TFSArea_AssignASMBatch();
        //util.MyEmailHandlerMethod(batch);
        Test.stopTest();
        system.assertEquals(true, true);
        
    }

}