/********************************************************************************************
* Class Name: DealerASM_AssignASMUnassignedBatch 
* Author: Rajeev Arya (Deloitte)
* Date: [08/02/2017]
* Requirement Description: W-006359 : SRM_BR_TM_015 – User Permissions: ASM permissions
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
global class DealerASM_AssignASMUnassignedBatch implements Database.Batchable<sObject> , Database.Stateful, Schedulable{
    
    ID usrIdASMUnassigned = Label.ASM_Unassigned_User_ID;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //retrieving all dealers where the unassigned ASM needs to be assigned
        String objQuery = 'select id from account where recordtype.name != \'Location\' and Updated_to_unassigned__c = true';
        return Database.getQueryLocator(objQuery);
    }
    
    // Execute for each batch
    global void execute(Database.BatchableContext BC, List<Account> lstDealers) {
        list<Account> lst = new list<Account>();
        //setting the ASM to ASM Unassigned in system mode
        for(Account acc : lstDealers)
        {
            lst.add(new Account(id = acc.Id, ownerID = usrIdASMUnassigned, Updated_to_unassigned__c = false ));
        }
        
        if (!lst.isEmpty()){  
            Database.SaveResult[] results = Database.update(lst, false);
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }

    global void execute(SchedulableContext sc) {
        id batchId = Database.executeBatch(new DealerASM_AssignASMUnassignedBatch ()); 
    }
}