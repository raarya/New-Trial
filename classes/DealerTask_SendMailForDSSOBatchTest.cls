/********************************************************************************************
* Class Name: DealerTask_SendMailForDSSOBatchTest 
* Author: Deeksha Singhal(Deloitte)
* Date: [01/30/2017]
* Requirement Description: Test Class for DealerTask_SendMailForDSSOBatch
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest(SeeAllData=false)
public class DealerTask_SendMailForDSSOBatchTest {
    @testSetup
    public static void createTestData() {
         Profile pr= [select Id from Profile where name='HQ Admin'];
         List<User> lstUsr = new List<User>();
         lstUsr.add(new User(profileid = pr.Id, lastname = 'asdf' , email = 'ajfgl@test.com', username = 'djge@google.com',TFS_SRM_Title__c='Sales HQ Admin', alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles'));
         if(lstUsr != null && lstUsr.size() > 0){
             insert lstUsr;
         }
         
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('Atlanta','02');
        if(tfsA != null){
            insert tfsA;
        }
        
        //creating a DSSO record
        Account dsso = TestUtility.createLocationDSSO('Chicago', '367654');
        if(dsso != null){
            insert dsso;
        }
        
        //creating team member on DSSO
        AccountTeamMember mem = TestUtility.accountTeamMemberInsrt(dsso);
        mem.TeamMemberRole = 'DSM';
        if(mem != null){
            insert mem;
        }
        
        //Creating Account Data
          List<Account> accLst = new List<Account>();
            accLst.add(TestUtility.createAccount('Test1','123454', tfsA));
            accLst.add(TestUtility.createAccount('Test2','145523', tfsA));
            if(accLst!=null && !accLst.isEmpty()){
                insert accLst;
            }
            system.assert(accLst.size() == 2);
            
            
        //Creating Account without Area ID
        Account acc1 = TestUtility.createAccount('Atlanta','123456',tfsA);
        acc1.TFS_Area__c = null;
        acc1.Area_ID__c = '';
        if(acc1 != null){
            insert acc1;
        }
        
        //Creating Account without DSSO Name
        Account acc2 = TestUtility.createAccount('Atlanta','2654312',tfsA);
        acc2.TFS_Area__c = null;
        acc2.DSSO_Name__c = '';
        acc2.Area_ID__c = '';
        if(acc2 != null){
            insert acc2;
        }
        
      //creating task list
      List<Task> listTask = TestUtility.createTaskBulkified(10, accLst[0],''); 
      listTask[0].Subject = Label.Task_Subject_for_no_AreaID;
      listTask[0].OwnerId = lstUsr[0].Id;
      if(listTask != null && listTask.size() > 0){
          insert listTask;  
      }
    }
    
        static TestMethod void DealerTask_SendMailForDSSOBatchTestMethod(){
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new DealerTask_SendMailForDSSOBatch());
         system.assertNotEquals(null, batchprocessid );
        Test.stopTest();
    }
}