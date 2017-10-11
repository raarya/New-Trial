/********************************************************************************************
* Class Name: Event_TriggerHandler 
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/21/2017]
* Requirement Description: W-004023 1. I am not able to update or delete tasks or events that are owned by others.
2. I am able to update tasks or events I own.
* Date Modified                Modified By                  Description of the update
* [08/28/2017]              Rajeev Arya(Deloitte)       W-004475 : Removed the code logic restricting the event assignment only to the parent team members
***********************************************************************************************/

public with sharing class Event_TriggerHandler {
        
    //Creating the object of the custom setting for method customisation
    BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(UserInfo.getUserId());
    static Boolean isReEntry = false;
    //creating the object of the trigger controller class
    Event_TriggerHelper controllerobj = new Event_TriggerHelper();
    
     //calling after update methods
    public void onAfterUpdate(Event[] eventObjIns,Event[] eventObjOld,map<id, Event> newMapEvent, map<id, Event> oldMapEvent)
    {
        controllerobj.onEventAccountUpdate(newMapEvent,oldMapEvent);
    }
    //calling after update methods
    public void onBeforeUpdate(Map<Id,Event> eventNew, Map<Id,Event> eventOld){
         if(Stoprecurssion.runonce() || Test.isRunningTest())
        {
            controllerobj.populateAccountLocation(eventNew,eventOld); 
        }
        controllerobj.setSubjectOnUpdate(eventNew, eventOld);
        controllerobj.onEventAttachmentUpdate(eventNew.values(),eventOld.values());
    }
    //calling beforee insert methods
    public void onBeforeInsert(Event[] eventObjIns){
        
        if(Stoprecurssion.runonce() || Test.isRunningTest())
        {
            controllerobj.populateLocation(eventObjIns);
        }
        controllerobj.setSubjectOnInsert(eventObjIns);
        controllerobj.onEventAttachmentInsert(eventObjIns); 
    }
    
    //calling after insert methods
    public void onEventAfterInsert(Event[] eventAttIns)
    {   

    }
    
    //calling before delete methods
    public void onEventDelete(Event[] eventObjDel){  
        //Checking the boolean value of isReEntry to stop the recursive loop condition
        if(!isReEntry){
            //controller method to stop the deletion of task
            controllerobj.onEventDeleteController(eventObjDel);
            isReEntry=true;
        }
    }
    
    
}