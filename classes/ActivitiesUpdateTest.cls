@isTest
private class ActivitiesUpdateTest {

    @isTest
    private Static void testMethod1(){

        test.startTest();
        //insert Training Event
        Training_Event__c rec = new Training_Event__c();
        rec.Name = 'Test';
        rec.dt_Event_Start_Time__c = Datetime.newInstance(2020, 2, 17);
        rec.dt_Event_End_Time__c = Datetime.newInstance(2020, 2, 19);
        rec.lr_Assigned_To_User__c = UserInfo.getUserId();
        if(rec != null)
        insert rec;
        //Insert Event
        Event rec1 = new Event();
        rec1.subject = 'Test';
        rec1.StartDateTime = Datetime.newInstance(1960, 2, 17);
        rec1.EndDateTime = Datetime.newInstance(1960, 2, 19);
        rec1.WhatId = rec.Id;
        if(rec1 != null)
        insert rec1;
        //Insert Task
        Task rec2 = new Task();
        rec2.WhatId = rec.Id;
        rec2.Contact_Type__c = 'Associate Changes';
        if(rec2 != null)
        insert rec2;
        rec.Name = 'Test1';
        if(rec1 != null)
        update rec;
        Training_Event__c testOutput = [Select Id,Name From Training_Event__c Where Id =: rec.Id];
        //System.assert(testOutput.Name == 'Test1');
        test.stopTest();
        
    }
}