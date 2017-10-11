/********************************************************************************************
* Class Name: Account_TriggerHelperTest 
* Author: Rajeev Arya(Deloitte)
* Date: [01/30/2017]
* Requirement Description: Test Class for TFSC_DealerTriggerHelper
* Date Modified                Modified By                  Description of the update
* [06/05/2017]              Rajeev Arya(Deloitte)       W-004682 : SRM_BR_Box_026: Box Territory Structure
***********************************************************************************************/
@isTest(SeeAllData=false)
public class Account_TriggerHelperTest {
    @testSetup
    public static void createTestData() {     
        
        //creating Custom Setting record
        TestUtility.insertCustomSetting();
        
        //creating a DSSO record
        Account dsso = TestUtility.createLocationDSSO('CHICAGO', '3667890');
        dsso.start_date__c = null;
        if(dsso != null){
            insert dsso;
        }
        
        //creating team member on DSSO
        AccountTeamMember mem = TestUtility.accountTeamMemberInsrt(dsso);
        mem.TeamMemberRole = 'DSM';
        if(mem != null){
            insert mem;
        }
        /*
        AccountTeamMember mem2 = TestUtility.accountTeamMemberInsrt(dsso);
        mem2.TeamMemberRole = 'DSSM';
        insert mem2;
        
        AccountTeamMember mem3 = TestUtility.accountTeamMemberInsrt(dsso);
        mem3.TeamMemberRole = 'DSSO AA';
        insert mem3;
        */
        
        //creating TFS Area
        TFS_Area__c tfsA99 = TestUtility.createTFSArea('CHICAGO', '02');
        if(tfsA99 != null){
            insert tfsA99;
        }
        //creating TFS Area
        TFS_Area__c tfsA0 = TestUtility.createTFSArea('CHICAGO', '01');
        if(tfsA0 != null){
            insert tfsA0;
        }
        //creating TFS Area User
        TFS_Area_User__c tfsAU0 = TestUtility.createTFSAreaUser(tfsA0);
        tfsAU0.Start_Date__c = system.today().addDays(1);
        if(tfsAU0 != null){
            insert tfsAU0;
        }
        
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('CHICAGO', '04');
        if(tfsA != null){
            insert tfsA;
        }
        
        /*//creating TFS Area User
        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        tfsAU.Start_Date__c = Date.today() - 2;
        if(tfsAU != null){
            insert tfsAU;
        }*/
        
        //creating account   
         List<Account> accLst = new List<Account>();
            accLst.add(TestUtility.createAccount('Test1','1234789', tfsA));
            accLst.add(TestUtility.createAccount('Test2','1456723', tfsA));
            if(accLst!=null && !accLst.isEmpty()){
                insert accLst;
            }
            system.assert(accLst.size() == 2);
        //Creating Account without Area ID
        Account acc1 = TestUtility.createAccount('Atlanta','13678935',tfsA);
        acc1.TFS_Area__c = null;
        acc1.Area_ID__c = null;
        //acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        if(acc1 != null){
            insert acc1;
        }
        
        //Creating Account without DSSO Name
        Account acc2 = TestUtility.createAccount('Atlanta','43456721',tfsA);
        acc2.TFS_Area__c = null;
        acc2.DSSO_Name__c = null;
        acc2.Area_ID__c = null;
        //acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        if(acc2 != null){
            insert acc2;
        }
        
        //creating task
        List<Task> tsk = TestUtility.createTaskBulkified(5,accLst[0],''); 
        tsk[0].OwnerId = accLst[0].OwnerId;
        tsk[1].OwnerId = accLst[0].OwnerId;
        tsk[2].OwnerId = accLst[0].OwnerId;
        tsk[3].OwnerId = accLst[0].OwnerId;
        tsk[4].OwnerId = accLst[0].OwnerId;
        if(tsk != null && tsk.size() > 0){
            insert tsk; 
        }
        list<event> lev = TestUtility.createEventBulkified(5,accLst[0]); 
        lev[0].OwnerId = accLst[0].OwnerId;
        lev[1].OwnerId = accLst[0].OwnerId;
        lev[2].OwnerId = accLst[0].OwnerId;
        lev[3].OwnerId = accLst[0].OwnerId;
        lev[4].OwnerId = accLst[0].OwnerId;
        
        lev[0].ActivityDateTime = system.now().addHours(1);
        lev[1].ActivityDateTime = system.now().addHours(1);
        lev[2].ActivityDateTime = system.now().addHours(1);
        lev[3].ActivityDateTime = system.now().addHours(1);
        lev[4].ActivityDateTime = system.now().addHours(1);
        /*
        lev[0].StartDateTime = system.now().addHours(1);
        lev[1].StartDateTime = system.now().addHours(1);
        lev[2].StartDateTime = system.now().addHours(1);
        lev[3].StartDateTime = system.now().addHours(1);
        lev[4].StartDateTime = system.now().addHours(1);*/
        if(lev != null && lev.size() > 0){
            insert lev;
        }
        
        AccountTeamMember accTeamMember =  TestUtility.accountTeamMemberInsrt(accLst[0]);
        if(accTeamMember!=null)
            insert accTeamMember;
        
        List<Task> insrtTask =  TestUtility.createTaskBulkified(2,accLst[0],'');
        if(insrtTask!=null && !insrtTask.isEmpty())
            insert insrtTask;
    }
    
    static testMethod  void AccountTFSUpdateCLstestmethod() {
        ID recTypeIDDealer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Profile pr= [select Id from Profile where name='System Administrator'];
        User Usr = new User(profileid = pr.Id, firstname = 'ABC', lastname = 'asdf' ,TFS_SRM_Title__c='Sales HQ Admin' ,email = 'ajfgl@test.com', username = 'djge@google.com', alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles');
        if(usr != null)
            insert usr;
                
        Test.startTest();
        List<Account> acc=([select id,Phone,DSSO_Name__c,Area_Id__c,RecordTypeId from Account where name != null]);
        System.runAs(Usr){
            acc[0].OwnerId = Usr.Id;
            acc[0].AccountNumber = '123456';
            acc[0].RecordTypeId = recTypeIDDealer;
            acc[0].Type = 'Lexus';
            acc[0].start_date__c = null;
            if(acc != null && acc.size() > 0){
                update acc[0];
            }
            
            acc[1].TFS_Area__c = null;
            acc[1].DSSO_Updated_By__c = '';
            acc[1].AccountNumber = '12463456';
            acc[1].DSSO_Name__c = null;
            acc[1].Area_ID__c = null;
            acc[1].RecordTypeId = recTypeIDDealer;
            acc[1].Type='Lexus';
            if(acc != null && acc.size() > 1){
                update acc[1];
            }
            
            acc[2].TFS_Area__c = null;
            acc[2].Area_ID__c = null;
            acc[2].RecordTypeId = recTypeIDDealer;
            acc[2].Type = 'Lexus';
            if(acc != null && acc.size() > 2){
                update acc[2];
            }
        }
        
        for(Account act: acc){
            act.Phone='123456789';
        }
        if(acc != null){
            update acc; 
        } 
        System.assertEquals(5,acc.size());  
        Test.stopTest();
        
        set<String> st1 = new Set<String>();
        set<String> st2 = new Set<String>();
        for(TFS_Area__c ta: [select id, Area_Id__c, DSSO_Name__c from TFS_Area__c where name != null]){
            st1.add(ta.DSSO_Name__c);
            st2.add(ta.Area_Id__c);
        }
        Account_TriggerHelper th = new Account_TriggerHelper();
        
        map<String, map<ID, ID>> mapAreaIdDSSONameToTFSArea = new map<String, map<ID, ID>>();
        mapAreaIdDSSONameToTFSArea = th.retrieveTFSAreaUserMap(st1,st2);
        System.assertEquals(3, mapAreaIdDSSONameToTFSArea.size());
    }
    
    static testMethod  void AccountTFSUpdateCLstestmethod_2() {
        ID recTypeIDDealer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        Profile pr= [select Id from Profile where name='System Administrator'];
        User Usr = new User(profileid = pr.Id, firstname = 'ABC', lastname = 'asdf' ,TFS_SRM_Title__c='Sales HQ Admin' ,email = 'ajfgl@test.com', username = 'djge@google.com', alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles');
        if(usr != null){
            insert usr;
        }
        
        Test.startTest();
        List<Account> acc=([select id,Phone,DSSO_Name__c,Area_Id__c,RecordTypeId from Account where name != null ]);        
                
        System.runAs(Usr){
            acc[0].RecordTypeId = recTypeIDDealer;
            acc[0].Type = 'Lexus';
            if(acc != null && acc.size() > 0){
                update acc[0];
            }
            
            acc[1].TFS_Area__c = null;
            acc[1].DSSO_Updated_By__c = '';
            acc[1].DSSO_Name__c = null;
            acc[1].Area_ID__c = null;
            acc[1].RecordTypeId = recTypeIDDealer;
            acc[1].Type = 'Lexus';
            if(acc != null && acc.size() > 1){
                update acc[1];
            }
            
            acc[2].TFS_Area__c = null;
            acc[2].Area_ID__c = null;
            acc[2].RecordTypeId = recTypeIDDealer;
            acc[2].Type = 'Lexus';
            if(acc != null && acc.size() > 2){
                update acc[2];
            }
        }
        
        
        for(Account act: acc){
            act.Phone='123456789';
        }
        if(acc != null){
            update acc; 
        }
        system.assertEquals(5,acc.size());   
        Test.stopTest();
    }    
    
     static testMethod  void AccountTFSUpdateCLstestmethod_3() {
        test.startTest();
        Profile pr= [select Id from Profile where name='System Administrator'];
        User Usr = new User(profileid = pr.Id, firstname = 'ABC', lastname = 'asdf' ,TFS_SRM_Title__c='Sales HQ Admin' ,email = 'ajfgl@test.com', username = 'djge@google.com', alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles');
        if(Usr != null){
            insert Usr;
        }
        Usr.TFS_SRM_Title__c = 'Sales HQ Admin';
        if(Usr != null){
            update Usr;
        }
        
        ID recTypeIDLocation2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        Account acdsso = [select id,name from account where recordtypeid=:recTypeIDLocation2 limit 1];
        
        AccountTeamMember mem2 = TestUtility.accountTeamMemberInsrt(acdsso);
        mem2.TeamMemberRole = 'DSSM';
        if(mem2 != null){
            insert mem2;
        }
        
        AccountTeamMember mem3 = TestUtility.accountTeamMemberInsrt(acdsso);
        mem3.TeamMemberRole = 'DSSO AA';
        if(mem3 != null){
            insert mem3;
        }
        for(AccountTeamMember accTeam : [select UserId, Account.Name, TeamMemberRole
                                    from AccountTeamMember where UserId != null
                                    ]){
                
             // system.debug(accTeam);                      
        }
                                    
        set<String> st3 = new set<String>();
        for(Account ac: [select name from account where name != null]){
            st3.add(ac.name);
        }
      
        Account_TriggerHelper th = new Account_TriggerHelper();
        map<String, list<ID>> mapDSSONameToMemberAndDSSO = new map<String, list<ID>>();
        mapDSSONameToMemberAndDSSO = th.retrieveDSMAndDSSMOnDSSO(st3);
        system.assertequals(0,mapDSSONameToMemberAndDSSO.size());
        
        //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
        List<Account> lsa2 = [select name, DSSO_Name__c, Area_Id__c from account where name != null];
        Account accTest = new Account();
        for(Account ac: lsa2)
        {
            ac.DSSO_Name__c = 'CHICAGO';
            ac.Area_Id__c = '04';
            ac.TFS_area__c = null;
            accTest = ac;
            //ac.DSSO_Updated_By__c = UserInfo.getUserId();
        }
        Database.update(lsa2, false);

        //nullifying DSSO and Area ID
        accTest.DSSO_Name__c = null;
        accTest.Area_ID__c = null;
        accTest.DSSO_Updated_By__c = '';
        system.runAs(Usr){
            if(accTest != null)
                update accTest;
        }
        
        //creating a TFS Area without a user and assigning it to a Dealer
        //creating a DSSO record
        Account dssoBal = TestUtility.createLocationDSSO('BALTIMORE', '018');
        dssoBal.AccountNumber = '4532223423';
        if(dssoBal != null){
            insert dssoBal;
        }
        
        //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
          //creating TFS Area User
       TFS_Area_User__c tfsAreaUsr = new  TFS_Area_User__c();
      
        tfsAreaUsr.TFS_Area__c=tfsABal02.Id;
        tfsAreaUsr.Start_Date__c=Date.newInstance(2008, 1, 1);
        insert  tfsAreaUsr;


        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','3234561',tfsABal02);
        accBal.Area_ID__c = '02';
        accBal.DSSO_Name__c = 'BALTIMORE';
        if(accBal != null){
            insert accBal;
        }
        accBal.Area_ID__c = '06';
        accBal.DSSO_Name__c = 'CHICAGO';
         update accBal;

        system.assertNotEquals([select TFS_Area__c from account where id = :accBal.Id].TFS_Area__c, null);

        Account accNone= TestUtility.createAccount('ABC','434521',tfsABal02);
        accNone.Area_ID__c = '05';
        accNone.DSSO_Name__c = 'BALTIMORE';
        accNone.TFS_Area__c = null;
        if(accNone != null){
            insert accNone;
        }
        system.assertNotEquals(accNone.TFS_Area__c, tfsABal02.Id);
        //[06/05/2017]-Rajeev Arya(Deloitte)- W-004682 : SRM_BR_Box_026: Box Territory Structure
        test.stopTest();
     } 
     static testMethod  void AccountTaskEventUpdate() {
         //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','12343253',tfsABal02);
        if(accBal != null){
        insert accBal;
        }
        
        Contact con = TestUtility.createContact(accBal);
        if(con != null){
        insert con;
        }
        
         //creating task
        List<Task> tsk = TestUtility.createTaskBulkified(2,accBal,''); 
        if(tsk != null && tsk.size() > 0){
            tsk[0].subject = '';
            insert tsk; 
        }
        list<event> lev = TestUtility.createEventBulkified(2,accBal); 
        if(lev != null && lev.size() > 0){
            lev[0].subject = '';
            lev[0].Location = '';
            insert lev;
        }
         accBal.Name = 'test';
         accBal.AccountNumber = '124567';
         if(accBal != null){
         update accBal;
         }
         system.assertEquals([select AccountNumber from account where id = :accBal.Id].AccountNumber, '124567');

     }
     static testMethod  void AccountContactTaskEventUpdate() {
         //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','12343253',tfsABal02);
        if(accBal != null){
        insert accBal;
        }
        Contact con = TestUtility.createContact(accBal);
        if(con != null){
        insert con;
        }
       
        //creating task
        List<Task> tskContact = TestUtility.createTaskBulkifiedforContact(2,con,''); 
        if(tskContact != null && tskContact.size() > 0){
            tskContact[0].subject = '';
            insert tskContact; 
        }
        list<event> levContact = TestUtility.createEventBulkifiedforContact(2,con); 
        if(levContact != null && levContact.size() > 0){
            levContact[0].subject = '';
            levContact[0].Location = '';
            insert levContact;
        }
         accBal.Name = 'test';
         accBal.AccountNumber = '124567';
         if(accBal != null){
         update accBal;
         }
                 system.assertEquals([select AccountNumber from account where id = :accBal.Id].AccountNumber, '124567');

     }
    static testMethod  void AccountTestMethod() {
                ID recTypeIDDealer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

         //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','12343253',tfsABal02);
        accBal.RecordTypeId =recTypeIDDealer;
        accBal.DSSO_Name__c = '';
        accBal.Area_ID__c = '';
        insert accBal;
        accBal.DSSO_Name__c = null;
        accBal.Area_ID__c = null;
        if(accBal != null){
        update accBal;
        }
                 system.assertEquals([select DSSO_Name__c from account where id = :accBal.Id].DSSO_Name__c, null);

    }
}