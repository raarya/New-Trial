/********************************************************************************************
* Class Name: DealerASM_AssignASMUnassignedBatchTest
* Author: Rajeev Arya (Deloitte)
* Date: [08/03/2017]
* Requirement Description: Test class for DealerASM_AssignASMUnassignedBatch 
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest(SeeAllData=false)
public class DealerASM_AssignASMUnassignedBatchTest{
    @testSetup
    public static void createTestData() {    
        TestUtility.insertCustomSetting();
        //creating CHICAGO DSSO
        Account chicagoDSSO = TestUtility.createLocationDSSO('CHICAGO','001');
        if(chicagoDSSO != null){
            insert chicagoDSSO;
        }
        
        //creating TFS Area on CHICAGO DSSO
        TFS_Area__c tfsA = TestUtility.createTFSArea('CHICAGO', '02');
        if(tfsA != null){
            insert tfsA;
        }
               
        //creating a tfs area user on the CHICAGO TFS Area
        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        if(tfsAU != null){
            insert tfsAU;
        }
        
        //creating dealers on CHICAGO DSSO 
         List<Account> accLst = new List<Account>();
            accLst.add(TestUtility.createAccount('Test1','645654', tfsA));
            accLst.add(TestUtility.createAccount('Test2','6534222', tfsA));
            
        if(accLst!= null){
            accLst[0].Updated_to_unassigned__c = true;
            accLst[1].Updated_to_unassigned__c = true;
            insert accLst;  
        }
        system.assert(accLst.size() == 2);
    }
    
    static testMethod void TFSC_DealerContactStatusTestMethod() 
    {
        Test.startTest();
        DealerASM_AssignASMUnassignedBatch batchJob = new DealerASM_AssignASMUnassignedBatch();
        Database.executebatch(batchJob);
        DealerASM_AssignASMUnassignedBatch schJob = new DealerASM_AssignASMUnassignedBatch();
        String sch = label.Scheduling_String; 
        system.schedule('Test Territory Check', sch, schJob);
        Test.stopTest();  
        system.assertEquals('ASM Unassigned', [select owner.name from account where recordtype.name != 'Location' limit 1][0].owner.name);
    }
}