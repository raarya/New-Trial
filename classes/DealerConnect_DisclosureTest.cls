/********************************************************************************************
* Class Name: DealerConnect_DisclosureTest
* Author: Deloitte
* Date: [07/20/2017]
* Requirement Description: DealerConnect_DisclosureTest
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest(SeeAllData=False)
public class DealerConnect_DisclosureTest {
   @isTest
    public static void testBatchWithxception(){
        Profile p = [select id from profile where name = 'System Administrator' limit 1];
        UserRole urole = [select id from userrole where name = 'Corporate' limit 1]; 
        User adminUser = TestUtility.createUser(p.id);
        adminUser.userroleid = urole.id;
        User ur; 
        Test.startTest();
        system.runAs(adminUser){ 
            TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
            if(tfsA!=null){
                insert tfsA;
            }
            Account a = TestUtility.createAccount('Saint Mount','174523', tfsA);
            if(a!=null){
                insert a;
            }
            Contact c = TestUtility.createContact(a);
            if(c!=null){
                insert c; 
            }
            List<AccountTeamMember>  acctmLst= TestUtility.createAccountTeamMemberBulkified(a,5);
            if(acctmLst!=null && !acctmLst.isEmpty()){
                insert acctmLst;
            }
            
            ur = TestUtility.createPortalUser(c.id);   
            if(ur!=null){
                insert ur;
            }
            List<Held_Offering__c> helOffLst = new List<Held_Offering__c>();
            helOffLst.add(TestUtility.createHeldOffering(a.Id, 'Test20'));
            helOffLst.add(TestUtility.createHeldOffering(a.Id, 'Test21'));
            helOffLst.add(TestUtility.createHeldOffering(a.Id, 'Test22'));
            
            if(helOffLst!=null && !helOffLst.isEmpty()){
                insert helOffLst;
            }
            system.assert(helOffLst.size() == 3);
        }

        System.RunAs(ur){
            DealerConnect_Disclosure tst= new DealerConnect_Disclosure();
            DealerConnect_Disclosure.initClass();
                        
            User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
            System.assertNotEquals(null,usr.accountid);
        }
        Test.stopTest();
    }
}