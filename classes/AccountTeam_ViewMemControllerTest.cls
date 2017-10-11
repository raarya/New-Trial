@isTest(SeeAllData=False)
public class AccountTeam_ViewMemControllerTest {
     
    @isTest
    public static void testBatchWithxception(){
        TestUtility.insertCustomSetting();
        Profile pr= [select Id from Profile where UserLicenseId in (SELECT Id FROM UserLicense where name ='Partner Community Login') limit 1];
        
        TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
        if(tfsA != null)
            insert tfsA;
        
        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        if(tfsAU != null)
            insert tfsAU;
        
        Account a = TestUtility.createAccount('Saint Mount','65433312', tfsA);
        if(a != null)
            insert a;
        
        Contact c = TestUtility.createContact(a);
        if(c != null)
            insert c;
        
        User ur = new User(profileid = pr.Id, lastname = 'asdf' , email = 'ajfgl@test.com', username = 'djge@google.com',contactid = c.id,TFS_SRM_Title__c='DSSM',alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles', CommunityNickname='Dealer');
        if(ur != null)
            insert ur;
        
        User usr =  [SELECT id,accountId,contactid from user where id=:ur.id];
      
        List<AccountTeamMember>  acctmLst= TestUtility.createAccountTeamMemberBulkified(a,5);
        if(acctmLst != null && !acctmLst.isEmpty())
            insert acctmLst;
         
        Test.startTest();
        
        System.RunAs(ur){    
            AccountTeam_ViewMemController tst = new AccountTeam_ViewMemController();
            AccountTeam_ViewMemController.displayDSSOMemberWrapper display = new AccountTeam_ViewMemController.displayDSSOMemberWrapper('abs','abs','abs','abs');
            List<AccountTeam_ViewMemController.displayDSSOMemberWrapper>  lstcheckrec = new  List<AccountTeam_ViewMemController.displayDSSOMemberWrapper>();
            lstcheckrec = AccountTeam_ViewMemController.getDSSOTeam();
            system.assertEquals(2,lstcheckrec.size());
               
         
         }
        Test.stopTest();
    }
    
    
    
    
}