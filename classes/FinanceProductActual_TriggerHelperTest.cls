@isTest(SeeAllData=False)
public class FinanceProductActual_TriggerHelperTest {

    public static testMethod void test1(){
        Test.startTest();
        TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
        if(ts != null){
            insert ts;
        }
        
        Account  acc= TestUtility.createAccount('testName','37876548', ts);
        if(acc!= null){
            insert acc;
        }
        
        Finance_Actual__c fa =  TestUtility.createFinanceActual(acc);
        if(fa != null){
            insert fa;
        }
        
        Product__c pd = TestUtility.createProduct();
        if(pd!= null){
            insert pd;
        }
        
        Product_Objective__c po = TestUtility.createProductObjective(acc,pd);
        if(po != null){
            insert po;
        }
        
        Finance_Product_Actual__c fpa = TestUtility.createFinanceProductActual(fa, pd, po);
        fpa.Volume__c = 4;
        if(fpa != null){
            insert fpa;
        }
        
        system.assertEquals(fpa.Trigger_Plan__c,null);
        system.assertEquals(fpa.Trigger_Stretch__c,null);
        
        
        fpa.Volume__c = 6;
        if(fpa != null){
            update fpa;
        }
        Test.stopTest();
    }

}