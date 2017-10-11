/********************************************************************************************
* Class Name: DealerContact_UpdateNotifScheduler
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/2/2017]
* Requirement Description:  W-004398
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
global class DealerContact_UpdateNotifScheduler implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        DealerContact_UpdateNotificationBatch schBatch = new DealerContact_UpdateNotificationBatch();
        database.executebatch(schBatch);
    }
    
}