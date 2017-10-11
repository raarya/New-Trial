@isTest(SeeAllData=false)
        public class ContentVersion_TriggerHelperTest {
        public static testMethod void ContentVersionTest(){
        TestUtility.insertCustomSetting();
         TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
            if(tfsA != null)
                insert tfsA;
          Account a = TestUtility.createAccount('Saint Mount','12813', tfsA);
            if(a != null)
                insert a;
          Contact c = TestUtility.createContact(a);
            if(c!=null)
                insert c;     
            Form__c f = new Form__c(Account__c = a.id, Form_Document_Type__c='1023: Authorization to Share Information',Product_Line__c ='Wholesale', Amount__c =200);
            if(f!=null)
              insert f;
           Profile pr= [select Id from Profile where UserLicenseId in (SELECT Id FROM UserLicense where name ='Partner Community Login') limit 1];
           User ur = new User(profileid = pr.Id, lastname = 'asdf' , email = 'ajfgl@test.com', username = 'djge@google.com', contactid = c.id,TFS_SRM_Title__c='DSSM',alias = 'test3',emailencodingkey='UTF-8', languagelocalekey='en_US',localesidkey='en_US', isActive = true,timezonesidkey='America/Los_Angeles', CommunityNickname='Dealer');
            if(ur!=null)
                insert ur;
            // RecordType ContentRT = [select Id FROM RecordType WHERE Name='Documents'];
             ContentVersion testContentInsert =new ContentVersion(); 
             testContentInsert.ContentURL= 'http://google.com';
             testContentInsert.Title ='Google.com'; 
             // testContentInsert.RecordTypeId = ContentRT.Id; 
             Test.startTest();
                 try{
                     System.runAs(ur){
                     insert testContentInsert;
                     }
                 }Catch(exception e){
             system.debug(e);
             }
             
             Test.stopTest();
        }
      }