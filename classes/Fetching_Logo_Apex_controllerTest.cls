@isTest
private class Fetching_Logo_Apex_controllerTest {

    @isTest
    private Static void testMethod1(){
        Profile p = [select id from profile where name = 'System Administrator' limit 1];
        UserRole urole = [select id from userrole where name = 'Corporate' limit 1]; 
        User adminUser = TestUtility.createUser(p.id);
        adminUser.userroleid = urole.id;
        Test.startTest();
        User testUser1;
        system.runAs(adminUser){ 
            Account rec1 = new Account();
            rec1.Name = 'Test';
            rec1.Type ='Toyota';
            rec1.AccountNumber = '623542';
            if(rec1 != null)
            insert rec1;
            Contact con1 = new Contact();
            con1.AccountId = rec1.Id;
            con1.Title__c = 'Controller';
            con1.LastName = 'Test Lname';
            con1.Email = 'test@test.com';
            if(con1 != null)
            insert con1;
            Profile p1 = [Select Id,Name From Profile Where Name = 'Community Dealer' Limit 1];
            testUser1 = new User();
            testUser1.ContactId = con1.Id; 
            testUser1.LastName = 'Test LName';
            testUser1.Alias = 'Test';
            testUser1.Username = 'test@test1234TFs.com';
            testUser1.EmailEncodingKey='UTF-8';
            testUser1.LastName='Testing'; 
            testUser1.LanguageLocaleKey='en_US';
            testUser1.LocaleSidKey='en_US'; 
            testUser1.ProfileId = p1.Id;
            testUser1.TimeZoneSidKey='America/Los_Angeles';
            testUser1.Email = 'test@test.com';
            testUser1.TFS_SRM_Title__c = 'DSSO AA';
            testUser1.ProfileId = p1.Id; 
            if(testUser1 != null)
            insert testUser1;
        }
        System.runAs(testUser1){
            String userName = Fetching_Logo_Apex_controller.getUserName();
            System.assert(userName != NULL);
            
        }
        test.stopTest();
    }
}