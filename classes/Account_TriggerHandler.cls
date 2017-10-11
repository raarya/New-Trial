/********************************************************************************************
* Class Name: Account_TriggerHandler
* Author: Ritesh Jaiswal (Deloitte)
* Date: [01/24/2017]
* Requirement Description: User story W-004007 - able to assign or update the TFS area number for a dealer within a DSSO, but not across DSSOs.
* Date Modified                Modified By                  Description of the update
***********************************************************************************************/
public class Account_TriggerHandler {
    Account_TriggerHelper helper= new Account_TriggerHelper (); 
    static Boolean isReEntry = false;
    public void onBeforeinsert(list<Account> lstAccNew, map<id, account> mapAccount){
        //isRentry is used to check the recursiveness    
        if(!isReEntry){
            helper.updateDealerTFSAndASM(lstAccNew, null);
            helper.updateAMSAssignedDateOnInsert(lstAccNew);
            helper.onBeforeInsert(lstAccNew); // Adde by Bhargavaramu : W-006601
        }
        isReEntry = true;
    }
    
    public void onAfterInsert(list<Account> lstAccNew, map<id, account> mapAccount){
        helper.createTasksOnDealers(lstAccNew); 
        helper.createAccountProducts(lstAccNew);
    }
    
    public void onBeforeupdate(list<Account> lstAccNew, map<ID, Account> mapOldAcc, map<ID, Account> mapNewAcc){
        if(!isReEntry){
            helper.updateDealerTFSAndASM(lstAccNew, mapOldAcc);
            helper.updateASMAssignedDate(mapNewAcc, mapOldAcc);
            helper.onBeforeUpdate(lstAccNew,mapOldAcc); // Adde by Bhargavaramu : W-006601
        }
        isReEntry = true;
    }
    // Deloitte starts W-005884
    public void onAfterUpdate(map<ID, Account> mapOldAcc, map<ID, Account> mapNewAcc){
            helper.updateTaskSubjectEventLocation(mapOldAcc,mapNewAcc); // Added by Mounika : W-006601
    }
    //Deloitte ends W-005884
}