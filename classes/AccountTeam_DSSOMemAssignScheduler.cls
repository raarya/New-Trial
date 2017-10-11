/********************************************************************************************
* Class Name: AccountTeam_DSSOMemAssignScheduler
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/20/2017]
* Requirement Description:W-004163 : As a Region AA, Sales HQ Admin I want be able to assign a product manager
* to a DSSO within a region and to dealers within the same region so that I can manage product manager assignments
* Date Modified                Modified By                  Description of the update
* [06/15/2017]               Rajeev Arya (Deloitte)        W-005910 : SRM_BR_TM_063 – Assigning Account Team Members to DSSOs and Dealers
* [08/30/2017]               Rajeev Arya(Deloitte)         W-006309 : Reduced batch size based on new design
***********************************************************************************************/

//Schedule class for batch class
global class AccountTeam_DSSOMemAssignScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {        
        AccountTeam_DSSOMemAssignBatch  schBatch = new AccountTeam_DSSOMemAssignBatch();
        database.executebatch(schBatch, 80); 
    }
    
}