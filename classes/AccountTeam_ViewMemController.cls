/********************************************************************************************
* Class Name: AccountTeam_ViewMemController Apex
* Author: Shourya Solipuram (Deloitte)
* Date: [01/24/2017]
* Requirement Description: User story W-004042 - As a Dealer I want view the TFS members of the DSSO team associated to their respective DSSO
* Date Modified                Modified By                  Description of the update
* [08/28/2017]              Rajeev Arya(Deloitte)       W-004475 : Future Territory Assignment: ASM from One DSSO to Another
*******************************************************************************************/
public without sharing class AccountTeam_ViewMemController {
@AuraEnabled
public static List<displayDSSOMemberWrapper> getDSSOTeam() {
    
    //[08/28/2017]-Rajeev Arya(Deloitte)- W-004475 : Future Territory Assignment: ASM from One DSSO to Another
    //Query to get the logged in User record
    User usr =  [SELECT id,accountId from user where id=:userinfo.getUserID()];
    list<displayDSSOMemberWrapper> lstDSSOWrapper = new list<displayDSSOMemberWrapper>();
    if(usr.AccountId != NULL){
        List<Account> acc= [SELECT Id,TFS_Area__c,TFS_Area__r.DSSO__c FROM Account WHERE Id =:usr.AccountId];
        //Query to get the PM details for the account the user belongs to
        for(AccountTeamMember accTeamMem : [SELECT Account.Owner.Name, Account.Owner.User_Email__c, Account.Owner.Phone,
                                            User.Name, User.Phone, User.User_Email__c, TeamMemberRole
                                            from AccountTeamMember
                                            where AccountId=: usr.accountid and user.isactive=true
                                            and teammemberrole = :TFS_Utility.PM]){
           lstDSSOWrapper.add(new displayDSSOMemberWrapper(accTeamMem.User.Name, accTeamMem.TeamMemberRole, accTeamMem.User.User_Email__c, accTeamMem.User.Phone));    
        }
        
        //fetching the other team members from the parent DSSO
        if(acc!= NULL && !acc.isEmpty()){
            // Start for #W-007172 
            String excludedvalues =Configurable_Values__c.getInstance().Exclude_Roles_from_TFS_Contacts__c;         
            List<String> excludedAccountTeamRoles = new List<String>();
            if(excludedvalues != NULL){
              excludedAccountTeamRoles = excludedvalues.split(TFS_Utility.SemiColon);
            }
            // End for #W-007172 - Divya B
            for(AccountTeamMember accTeamMem : [SELECT Account.Owner.Name, Account.Owner.User_Email__c, Account.Owner.Phone,
                                            User.Name, User.Phone, User.User_Email__c, TeamMemberRole
                                            from AccountTeamMember
                                            where AccountId=: acc[0].TFS_Area__r.DSSO__c and user.isactive=true
                                            and teammemberrole NOT IN: excludedAccountTeamRoles ]){ //#W-007172 Divya B 
                lstDSSOWrapper.add(new displayDSSOMemberWrapper(accTeamMem.User.Name, accTeamMem.TeamMemberRole, accTeamMem.User.User_Email__c, accTeamMem.User.Phone));     
            } 
            //fetching the ASMs from the related TFS Areas of parent DSSO
            for(TFS_Area__c tfs : [select ASM__r.name, ASM__r.Phone, ASM__r.User_Email__c from TFS_Area__c where Status__c =: TFS_Utility.ACTIVE
                                    and ASM__r.name != 'ASM Unassigned' and DSSO__c = :acc[0].TFS_Area__r.DSSO__c]){
                lstDSSOWrapper.add(new displayDSSOMemberWrapper(tfs.ASM__r.Name, 'ASM', tfs.ASM__r.User_Email__c, tfs.ASM__r.Phone));
            }                                
        }
    //[08/28/2017]-Rajeev Arya(Deloitte)- W-004475 : Future Territory Assignment: ASM from One DSSO to Another
    }
    return lstDSSOWrapper;
}

/*******************************************/
/* Wrapper class to display data      
/*****************************************/

public class displayDSSOMemberWrapper {
    
    @AuraEnabled public String name;
    @AuraEnabled public String role;
    @AuraEnabled public String email;
    @AuraEnabled public String phone;
    
    public displayDSSOMemberWrapper(String Dname, String Drole, String Demail, String Dphone){
        name = Dname;
        role = Drole;
        email = Demail;
        phone = Dphone;
    }
}

}