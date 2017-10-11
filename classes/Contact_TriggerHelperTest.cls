@isTest(SeeAllData=False)
public class Contact_TriggerHelperTest {

    public static testMethod void testContact1(){
        
        Set<String> rolesAuthorized = new Set<String>();
        rolesAuthorized.addAll(Label.Contact_Deletion_Titles_Authorized.split(';'));
        String tfsrl = Label.Contact_Deletion_Titles_Authorized.split(';')[0];
        
        User lo_u = new User(id=UserInfo.getUserid());
        lo_u.TFS_SRM_Title__c = tfsrl;
        if(lo_u != null){
            update lo_u;
        }
        
        TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
        if(ts != null){
            insert ts;
        }
        
        Account  testAcc= TestUtility.createAccount('testName','12378', ts);
        if(testAcc != null){
            //testAcc.Account.RecordType.DeveloperName ='Location';
            testAcc.Type='Lexus';
            testAcc.Related_Account__c = null;
            insert testAcc;
        }
        
        Account  testAcc2= TestUtility.createAccount('testName','156234', ts);
        testAcc2.Related_Account__c = testAcc.id;
        if(testAcc2 != null){
            insert testAcc2;
        }
        
        Contact con = TestUtility.createContact(testAcc);
        con.Title__c ='General Manager (GM)';
        con.Status__c='Active';
        con.Held_Offering_Email__c = false;
        con.OwnerId = UserInfo.getUserid();
        con.Email='deekshatest1234@test.com';
        con.accountID = testAcc.id;
        
        Contact con2 = TestUtility.createContact(testAcc);
        con2.Title__c ='Dealer Principal (DP)';
        con2.Held_Offering_Email__c = true;
        con2.Status__c='Active';
        con2.Email='deekshatest12334@test.com';
        con2.accountID = testAcc.id;
        
        Contact con3 = TestUtility.createContact(testAcc);
        con3.Title__c ='Dealer Principal (DP)';
        con3.Status__c='Active';
        con3.Held_Offering_Email__c = true;
        con3.OwnerId = UserInfo.getUserid();
        con3.Email='deekshatest1234@test.com';
        con3.AccountId = testAcc.id;
        //con3.accountID = testAcc;
        
        List<Contact> lsCon = new List<Contact>();
        lsCon.add(con);
        lsCon.add(con2);
        lsCon.add(con3);
        if(lsCon != null && lsCon.size() > 0){
            insert lsCon;
        }
        
        for(contact cone: [SELECT account.type from contact where ID in :lsCon]){
            System.debug('Cone'+ cone.account.type);
        }
        
        List<Task> tsk = TestUtility.createTaskBulkifiedforContact(5,con,''); 
        tsk[0].OwnerId = con.OwnerId;
        tsk[1].OwnerId = con.OwnerId;
        tsk[2].OwnerId = con.OwnerId;
        tsk[3].OwnerId = con.OwnerId;
        tsk[4].OwnerId = con.OwnerId;
        if(tsk != null && tsk.size() > 0){
            insert tsk; 
        }
        
        list<event> lev = TestUtility.createEventBulkifiedforContact(5,con); 
        lev[0].OwnerId = con.OwnerId;
        lev[1].OwnerId = con.OwnerId;
        lev[2].OwnerId = con.OwnerId;
        lev[3].OwnerId = con.OwnerId;
        lev[4].OwnerId = con.OwnerId;
        
        lev[0].ActivityDateTime = system.now().addHours(1);
        lev[1].ActivityDateTime = system.now().addHours(1);
        lev[2].ActivityDateTime = system.now().addHours(1);
        lev[3].ActivityDateTime = system.now().addHours(1);
        lev[4].ActivityDateTime = system.now().addHours(1);
        if(lev != null && lev.size() > 0){
            insert lev;
        }
        
        for(contact conex: [SELECT account.type from contact where ID in :lsCon]){
            System.debug('Conex'+ conex.account.type);
        }
        if(lsCon != null && lsCon.size() > 0)
            update lsCon;
        
        Contact con2_1 = TestUtility.createContact(testAcc);
        con2_1.Title__c ='General Manager (GM)';
        con2_1.Status__c='Active';
        
        Contact con2_2 = TestUtility.createContact(testAcc);
        con2_2.Title__c ='Dealer Principal (DP)';
        con2_2.Status__c='Active';
        
        List<Contact> lsCon2 = new List<Contact>();
        lscon2.add(con2_1);
        lscon2.add(con2_2);
        if(lscon2 != null && lscon2.size() > 0){
            insert lscon2;
        }
        for(contact conex1: [SELECT account.type from contact where ID in :lsCon2]){
            System.debug('conex1' + conex1.account.type);
        }
        
        if(lscon2 != null && lscon2.size() > 0){
            update lscon2;
        }
        
        
        List<Contact> allCons = new List<Contact>();
        allCons.add(lscon[1]);
        allCons.addAll(lscon2);
        for(contact conex2: [SELECT account.type from contact where ID in :allCons]){
            System.debug('Conex2' + conex2.account.type);
        }
        
        
        if(allCons != null && allCons.size() > 0){
        
            update allCons;
        }

        if(allCons != null && allCons.size() > 0){
            delete allCons;
        }
        
        User u = TestUtility.getTestCandidateUserInsert();
       
        List<Contact> lscDel = [select id from contact limit 6];
        Database.update(lscDel, false);   
    }
    
    public static testMethod void testContact2(){
            Profile pr= [select Id from Profile where UserLicenseId in (SELECT Id FROM UserLicense where name ='Partner Community Login') limit 1];
            
            Test.startTest();
            TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
            insert ts;
            system.assert(ts.Id != null);
            account acc = TestUtility.createAccount('ABC','127345', ts);
            insert acc;
            system.assert(acc.Id != null);
            Contact c = TestUtility.createContact(acc);
            insert c; 
            system.assert(c.Id != null);
            //Creating portal user
            User ur = new User(profileid = pr.Id, lastname = 'asdf' , email = 'ajfgl@test.com', username = 'djge@google.com', contactid = c.id,TFS_SRM_Title__c='DSSM',alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles', CommunityNickname='Dealer');
            insert ur;
            system.assert(ur.Id != null);
            
            Profile pr1= [select Id from Profile where name='System Administrator']; 
            User u = TestUtility.createUser(pr1.id);
            u.tfs_srm_title__c = 'ASM';
            if(u != null){
                insert u;
            } 
            system.assert(u.id != null);
        
            system.runas(u){  
                c.status__c = 'Inactive';
                update c;
            }
            
            Test.stopTest();       
    }
    
    public static testMethod void testContact3(){
        Test.startTest();
        TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
        if(ts != null){
            insert ts;
        }
        
        Account  testAcc= TestUtility.createAccount('testName','123456', ts);
        if(testAcc != null){
            testAcc.Type='Lexus';
            testAcc.Related_Account__c = null;
            insert testAcc;
        }
        
        Contact con = TestUtility.createContact(testAcc);
        con.Title__c ='General Manager (GM)';
        con.Status__c='Active';
        con.Held_Offering_Email__c = false;
        con.OwnerId = UserInfo.getUserid();
        con.Email='deekshatest1234@test.com';
        con.accountID = testAcc.id;   
        
        if(con != null){
            insert con;
            con.Title__c = 'Dealer Principal (DP)';
            update con;
        }
        
        Profile p = [select id from profile where name = 'System administrator' limit 1];
        User u = TestUtility.createUser(p.id);
        u.TFS_SRM_Title__c = 'Region AA';
        if(u != null){
            insert u;
        }
        
        system.runAs(u){
            if(con != null){
                delete con;
            }
        }
        Test.stopTest();
    }
    public static testMethod void testContact4(){
        Test.startTest();
        Contact_TriggerHelper.createErrorLog('error',5,'testContact4');
        Test.stopTest();
    }
    
    public static testMethod void testContact5(){
        Test.startTest();
        TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
        if(ts != null){
            insert ts;
        }
        
        Account  testAcc= TestUtility.createAccount('testName','238945', ts);
        if(testAcc != null){
            testAcc.Type='Lexus';
            testAcc.Related_Account__c = null;
            insert testAcc;
        }
        
        Contact con = TestUtility.createContact(testAcc);
        con.Title__c ='General Manager (GM)';
        con.Status__c='Active';
        con.Held_Offering_Email__c = false;
        con.OwnerId = UserInfo.getUserid();
        con.Email='deekshatest1234@test.com';
        con.accountID = testAcc.id;   
        
        if(con != null){
            insert con;
            con.Title__c = 'Dealer Principal (DP)';
            update con;
        }
        
        Profile p = [select id from profile where name = 'System administrator' limit 1];
        User u = TestUtility.createUser(p.id);
        u.TFS_SRM_Title__c = 'Region AA';
        if(u != null){
            insert u;
        }
        
        system.runAs(u){
            if(con != null){
                List<Task> tsk = TestUtility.createTaskBulkifiedforContact(5,con,''); 
                tsk[0].OwnerId = con.OwnerId;
                tsk[1].OwnerId = con.OwnerId;
                tsk[2].OwnerId = con.OwnerId;
                tsk[3].OwnerId = con.OwnerId;
                tsk[4].OwnerId = con.OwnerId;
                if(tsk != null && tsk.size() > 0){
                    insert tsk; 
                }
                try{
                    delete con;
                }
                catch(Exception e){}
            }
        }
        Test.stopTest();
    }
    
    public static testMethod void testContact6(){
        Test.startTest();
        TFS_Area__c ts = TestUtility.createTFSArea('ATLANTA', '01');
        if(ts != null){
            insert ts;
        }
        
        Account  testAcc= TestUtility.createAccount('testName','328961', ts);
        if(testAcc != null){
            testAcc.Type='Lexus';
            testAcc.Related_Account__c = null;
            insert testAcc;
        }
        
        Contact con = TestUtility.createContact(testAcc);
        con.Title__c ='General Manager (GM)';
        con.Status__c='Active';
        con.Held_Offering_Email__c = false;
        con.OwnerId = UserInfo.getUserid();
        con.Email='deekshatest1234@test.com';
        con.accountID = testAcc.id;   
        
        if(con != null){
            insert con;
            con.Title__c = 'Dealer Principal (DP)';
            update con;
        }
        
        Profile p = [select id from profile where name = 'System administrator' limit 1];
        User u = TestUtility.createUser(p.id);
        u.TFS_SRM_Title__c = 'Region AA';
        if(u != null){
            insert u;
        }
        
        system.runAs(u){
            if(con != null){
                list<event> lev = TestUtility.createEventBulkifiedforContact(5,con); 
                lev[0].OwnerId = con.OwnerId;
                lev[1].OwnerId = con.OwnerId;
                lev[2].OwnerId = con.OwnerId;
                lev[3].OwnerId = con.OwnerId;
                lev[4].OwnerId = con.OwnerId;
                
                lev[0].ActivityDateTime = system.now().addHours(1);
                lev[1].ActivityDateTime = system.now().addHours(1);
                lev[2].ActivityDateTime = system.now().addHours(1);
                lev[3].ActivityDateTime = system.now().addHours(1);
                lev[4].ActivityDateTime = system.now().addHours(1);
                if(lev != null && lev.size() > 0){
                    insert lev;
                }
                
                try{
                    delete con;
                }
                catch(Exception e){}
            }
        }
        Test.stopTest();
    }
}