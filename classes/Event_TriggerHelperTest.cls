/********************************************************************************************
* Class Name: Event_TriggerHelperTest
* Author:Ritesh Jaiswal
* Date: [01/30/2017]
* Requirement Description:
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest(SeeAllData=false)
public class Event_TriggerHelperTest {  

    @testSetup
    public static void createTestData() {     
        StopRecurssion.flag = true;
        //creating Custom Setting record
        TestUtility.insertCustomSetting();
        
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
        if(tfsA != null){
            insert tfsA;
        }

        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        if(tfsAU != null){
            insert tfsAU;
        }
        
        Account acc = TestUtility.createAccount('Saint Mount','123456',tfsA);
        if(acc != null){
            insert acc;
        }
        
        List<AccountteamMember> accMember = TestUtility.createAccountTeamMemberBulkified(acc,5);
        if(accMember != null && !accMember.isEmpty() ){
            insert accMember;    
        }    
        
        List<Event> evt = TestUtility.createEventBulkified(5,acc); 
        
        if(evt!= null && !evt.isEmpty()){
            insert evt;    
        }      
        
        List<Event> CFPBevt = TestUtility.createEventBulkified(1,acc); 
        CFPBevt[0].contact_type__c = 'CFPB-Related';
    CFPBevt[0].Subject = '' ;
        if(CFPBevt != null && !CFPBevt.isEmpty() ){
            insert CFPBevt; 
        }
        
   CFPBevt[0].contact_type__c = 'CFPB-Related;Associate Changes';
            if(CFPBevt[0] != null)
            update CFPBevt[0];

            CFPBevt[0].Subject ='';
            if(CFPBevt != null)
            update CFPBevt;
        
        List<Attachment> att=  TestUtility.createAttachmentForEventBulkified(evt[0],2);
        if(att != null && !att.isEmpty()){
            insert att;    
        }    
    }
    
    static testMethod  void AccountTFSUpdateCLstestmethod() {
    Map<Id, Event> mapOldEvent = new Map<Id, Event>();
        Map<Id, Event> mapNewEvent = new Map<Id, Event>(); 
    
     try{
        Test.startTest();
        List<Event> evt =([select id,Description from event limit 2]);
        List<Attachment> att=  TestUtility.createAttachmentForEventBulkified(evt[0],4);
        if(att != null && !att.isEmpty()){
            insert att;
        }  
        
        List<Event> evtToUpdate = new List<Event>();
        for(Event evts : evt)
           {
            evts.Description='check again';
            evts.contact_type__c = 'CFPB-Related';
               evtToUpdate.add(evts);
           }
          StopRecurssion.flag = true;
          
        if(evtToUpdate != null && !evtToUpdate.isEmpty()){
            update evtToUpdate;
        }

        //update evtToUpdate;
        if(evtToUpdate != null && !evtToUpdate.isEmpty()){
            delete evtToUpdate;
        }
        Test.stopTest();
       } catch(Exception e) {
            system.assertEquals(e.getMessage(), e.getMessage());
      }
   }
   @isTest
   public static void testMethod1() 
   {
     try{
        Test.startTest();
        StopRecurssion.flag = true;
        //creating Custom Setting record
        /*BypassTriggerLogicSettings__c customSetting = new BypassTriggerLogicSettings__c();
        customSetting.Bypassed_Trigger_Methods__c = '';
        customSetting.Disable_Triggers__c = false;
        insert customSetting;
        
        //creating TFS Area
        TFS_Area__c tfsA = TestUtility.createTFSArea('Chicago', '04');
        insert tfsA;

        TFS_Area_User__c tfsAU = TestUtility.createTFSAreaUser(tfsA);
        insert tfsAU;
        
        Account acc = TestUtility.createAccount('Saint Mount',tfsA);
        insert acc;
        
        AccountteamMember accMember = TestUtility.createAccountTeamMemberBulkified(acc,5).get(0);
        insert accMember; */

        //Event evt = TestUtility.createEventBulkified(5,acc).get(0); 
        //insert evt;
        Account testAccountRec = new Account();
        testAccountRec.Name = 'Test';
        testAccountRec.Area_Id__c = NULL;
        testAccountRec.DSSO_Name__c = 'CHICAGO';
        if(testAccountRec != null){
            insert testAccountRec;  
        }   
         
         Event evt = new Event();
         evt.Attachment__c=true;
         Evt.ownerid=userinfo.getuserId();
         Evt.Description='Imdtest';
         Evt.contact_type__c='Contact Type';
         Evt.DurationInMinutes=20;
         Evt.ActivityDateTime=Date.Today(); 
         Evt.whatid=testAccountRec.id;     
         if(Evt != null){   
             insert Evt;
         }
        
        Attachment att=  TestUtility.createAttachmentForEventBulkified(evt,2).get(0);
        if(att != null){
            insert att;
        }
        
 
        
         
        StopRecurssion.flag = true;
        evt.Description = 'test1';
        if(evt != null){
            update evt;
         }
         StopRecurssion.flag = true;
        
        if(evt != null){
            delete evt;
        }
        
        Test.stopTest();
       } 
       catch(Exception e) 
       {
            system.assertEquals(e.getMessage(), e.getMessage());
      }
   }
        @isTest
   public static void testEventSubjectUpdateContact() 
   {
     try{
        //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','123567',tfsABal02);
        if(accBal != null){
        insert accBal;
        }
        
        Account accBal2= TestUtility.createAccount('ABC','123789',tfsABal02);
        if(accBal2 != null){
        insert accBal2;
        }
        
        Contact con = TestUtility.createContact(accBal);
        if(con!=null){
        insert con;
        }
         
         Contact con2 = TestUtility.createContact(accBal2);
         if(con2 != null){
         insert con2;
         }
        
        Test.startTest();
        
        list<event> levContact = TestUtility.createEventBulkifiedforContact(0,con); 
         levContact[0].Subject = '';
         levContact[0].Location = '';
        if(levContact != null && !levContact.isEmpty()){
            insert levContact;
        }
         if(levContact != null && !levContact.isEmpty()){
             levContact[0].Subject = '';
         levContact[0].Location = '';
            levContact[0].WhoId = con2.Id;
            update levContact; 
        }
         Event evntqueried = [Select id,subject from Event where id=:levContact[0].id];
        system.assertNotEquals(evntqueried.subject,'');
        Test.stopTest();
       } 
       catch(Exception e) 
       {
            system.assertEquals(e.getMessage(), e.getMessage());
      }
   }
    @isTest
   public static void testEventSubjectUpdate() 
   {
     try{
         Test.startTest();
        //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','123567',tfsABal02);
        if(accBal != null){
        insert accBal;
        }
        
        Account accBal2= TestUtility.createAccount('ABC','123789',tfsABal02);
        if(accBal2 != null){
        insert accBal2;
        }
        
        Contact con = TestUtility.createContact(accBal);
        if(con!=null){
        insert con;
        }
         
         Test.stopTest();
        list<event> lev = TestUtility.createEventBulkified(0,accBal); 
        if(lev != null && !lev.isempty()){
            lev[0].WhoId = con.id;
            insert lev;
        }
        
        if(lev != null && !lev.isempty()){
            
            lev[0].WhatId = accBal2.Id;
            update lev; 
        }
		Event evntqueried = [Select id,subject from Event where id=:lev[0].id];
        system.assertEquals(evntqueried.subject,'ABC 123789');
        
       } 
       catch(Exception e) 
       {
            system.assertEquals(e.getMessage(), e.getMessage());
      }
   }
    @isTest
   public static void testAccountUpdate() 
   {
     try{
         Test.startTest();
        //creating TFS Area
        TFS_Area__c tfsABal02 = TestUtility.createTFSArea('BALTIMORE', '02');
        if(tfsABal02 != null){
            insert tfsABal02;
        }
        //Creating Dealer 
        Account accBal= TestUtility.createAccount('XYZ','123567',tfsABal02);
        if(accBal != null){
        insert accBal;
        }
        
        Account accBal2= TestUtility.createAccount('ABC','123789',tfsABal02);
        if(accBal2 != null){
        insert accBal2;
        }
        
         Test.stopTest();
         
        list<event> lev = TestUtility.createEventBulkified(0,accBal); 
        if(lev != null && !lev.isempty()){
            insert lev;
        }
        
        if(lev != null && !lev.isempty()){
            lev[0].WhatId = accBal2.Id;
            update lev; 
        }
		Event evntqueried = [Select id,subject from Event where id=:lev[0].id];
        system.assertEquals(evntqueried.subject,'ABC 123789');
        
       } 
       catch(Exception e) 
       {
            system.assertEquals(e.getMessage(), e.getMessage());
       }
   }
}