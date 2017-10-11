/**************************************************************************************************************************************************
* Class Name: Account_BuySellBatchTest
* Author: Deloitte
* Date: [04/05/2017]
* Requirement Description:  User story W-004010 - Migrate and overwrite Account team, Area ID, TMS Details, and Dealer Objectives information
* Date Modified                Modified By                  Description of the update

***************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Account_BuySellBatchTest {
    @testSetup
    public static void createTestData() {
        TestUtility.insertCustomSetting();
         Profile pr= [select Id from Profile where name='HQ Admin'];
         List<User> lstUsr = new List<User>();
         lstUsr.add(new User(profileid = pr.Id, lastname = 'asdf' , email = 'ajfgl@test.com', username = 'djge@google.com',TFS_SRM_Title__c='Sales HQ Admin', alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles'));
         if(lstUsr != null && !lstUsr.isEmpty()){
            insert lstUsr;
         }
        //creating a DSSO record
        Account dsso0 = TestUtility.createLocationDSSO('BOSTON', '00');
        dsso0.AccountNumber = '52343452';
        if(dsso0 != null){
            insert dsso0;
        }
        system.debug(' dsso acc num: ' +dsso0.AccountNumber);
        
        Account dsso1 = TestUtility.createLocationDSSO('CHICAGO', '01');
        dsso1.AccountNumber = '453434';
        if(dsso1 != null){
            insert dsso1;
        }
        Account dsso2 = TestUtility.createLocationDSSO('SEATTLE', '02');
        dsso2.AccountNumber = '5244343452';
        if(dsso2 != null){
            insert dsso2;
        }
        //creating team member on DSSO
        AccountTeamMember mem1 = TestUtility.accountTeamMemberInsrt(dsso1);
        mem1.TeamMemberRole = 'DSM';
        if(mem1 != null){
            insert mem1;
        }
        AccountTeamMember mem2 = TestUtility.accountTeamMemberInsrt(dsso2);
        mem2.TeamMemberRole = 'ASM';
        if(mem2 != null){
            insert mem2;
        }
        ID recTypeIDLocation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        system.debug([select id, Name from Account where RecordTypeId = :recTypeIDLocation]);

        //creating TFS Area without Account
        TFS_Area__c tfsA0 = TestUtility.createTFSArea('BOSTON','01');
        tfsA0.DSSO__c =  dsso0.Id;
        if(tfsA0 != null){
            insert tfsA0;
        }
        
        TFS_Area__c tfsA1 = TestUtility.createTFSArea('CHICAGO','01');
        tfsA1.DSSO__c = dsso1.id;
        if(tfsA1 != null){    
            insert tfsA1;
        }
        
        tfsA1.DSSO__c = dsso1.id;
        if(tfsA1 != null){
            update tfsA1;
        }
        TFS_Area__c tfsA2 = TestUtility.createTFSArea('SEATTLE','02');
        tfsA2.DSSO__c = dsso2.id;
        if(tfsA2 != null) {   
            insert tfsA2;
        }    
        tfsA2.DSSO__c = dsso2.id;
        if(tfsA2 != null) 
            update tfsA2;

        //Creating Account Data
         List<Account> acc = new List<Account>();
            acc.add(TestUtility.createAccount('Test1','43254', tfsA1));
            acc.add(TestUtility.createAccount('Test2','32167', tfsA2));
            if(acc!=null && !acc.isEmpty()){
                insert acc;
            }
            system.assert(acc.size() == 2);
        Date dt1 = Date.today();
        
        //No related account
        Account acc0 = TestUtility.createAccount('Atlanta0','123787',tfsA0);
        acc0.Start_Date__c = dt1;
        acc0.End_Date__c = dt1.addDays(30);
        acc0.isProcessed__c = false;
        if(acc0 != null)  {   
            insert acc0;
        }
        //Creating Account without Area ID
        Account acc1 = TestUtility.createAccount('Atlanta1','123486',tfsA1);
        acc1.Start_Date__c = dt1;
        acc1.End_Date__c = dt1.addDays(30);
        acc1.isProcessed__c = false;
        acc1.Related_Account__c = acc0.Id;
        //acc1.AccountNumber = 'acc1Num';
        if(acc1 != null)  {  
            insert acc1;
        }
         system.debug(' ??? ' + acc1.Related_Account__r.DSSO_ID__c);
        
       
        //Creating Account without DSSO Name
        Account acc2 = TestUtility.createAccount('Atlanta2','1234589',tfsA2);
        acc2.Start_Date__c = dt1;
        acc2.End_Date__c = dt1.addDays(30);
        acc2.isProcessed__c = false;    
        acc2.Related_Account__c = acc1.Id; 
        //acc2.AccountNumber = 'acc2Num';  
        if(acc2 != null){
            insert acc2;
        }
        Account acc3 = TestUtility.createAccount('Atlanta3','321239',tfsA2);
        acc3.Start_Date__c = dt1;
        acc3.End_Date__c = dt1.addDays(30);
        acc3.isProcessed__c = false;   
        if(acc3 != null)  {  
            insert acc3;
        }
        
        //acc1.Related_Account__c = acc0.Id;
        //acc2.Related_Account__c = acc1.Id; 
        acc3.Related_Account__c = acc2.Id;
        //acc0.Related_Account__c = acc3.Id;
        //update acc1;
        //update acc2;
        if(acc3 != null){
            update acc3; 
         }
        //update acc0;
        Account accQuried = [select id,Name,DSSO_ID__c, Related_Account__r.TFS_Area__r.DSSO__c from Account where Id=:acc1.Id];
        system.debug('acc1 related for : ' + accQuried.Name + ' is ' + accQuried.Related_Account__r.TFS_Area__r.DSSO__c);
        
        //list<TFS_Area__c> lstfs = [select DSSO__c from TFS_Area__c ];
        //system.debug(lstfs);
        
        //list<account> lst = [select DSSO_ID__c, Id, TFS_Area__r.DSSO__r.AccountNumber, TFS_Area__c, TFS_Area__r.DSSO__c from account where TFS_Area__c!=  null ];
        //system.debug(lst);
    }

   static testMethod void Account_BuySellBatchTestMethod1() 
    {
        
        Test.startTest();
        Account_BuySellBatch batchAssign = new Account_BuySellBatch();
        id batchid=Database.executeBatch(batchAssign);
        SchedulableContext sc = null;
        String schedule = Label.Scheduling_String;
        System.schedule('Batch Update for Account Buy Sell Test Method', schedule, batchAssign);
        test.stopTest();
        system.assertNotEquals(null, batchid);
    }
}