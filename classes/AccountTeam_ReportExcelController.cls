/********************************************************************************************
* Class Name: AccountTeamReportExcelController 
* Author: Bhargavaramu (Deloitte)
* Date: [05/31/2017] : 
* Description: It is custom controller for AccountTeamReportExcel VF Page to generate excel file based on the
               requirement. Story: 6910
* Date Modified                Modified By                  Description of the update
***********************************************************************************************/
public with sharing class AccountTeam_ReportExcelController{
    //Variable declaration: get set variables
    public List<accountWrapper> accWrapperList{get;set;} 
    Public List<String> roleList{get;set;}
    //Constructor
    public AccountTeam_ReportExcelController(){
        Set<string> dealerRoleSet = new set<String>();
        Set<string> dssoRoleSet = new set<String>();
        Set<string> regionRoleSet = new set<String>();
        
        //Fetching roles from custom setting
        Map<String,Account_Team_Report_Columns__c> atrMap = Account_Team_Report_Columns__c.getAll();
        List<roleWrapper> userRoleList = new List<roleWrapper>();
        for(Account_Team_Report_Columns__c atr : atrMap.values()){
            roleWrapper rw = new rolewrapper(atr);
            userRoleList.add(rw);
        }  
        //Custom sorting
        userRoleList.sort(); 
        //Conveting roles data from wrapper to list 
        roleList = new List<String>();
        for(roleWrapper uRole:userRoleList){
            roleList.add(uRole.obj.Name);
            if(uRole.obj.Type__c != null){
                if(uRole.obj.Type__c == TFS_Utility.DEALER){
                    dealerRoleSet.add(uRole.obj.Name);
                }
                else if(uRole.obj.Type__c == TFS_Utility.DSSO){
                    dssoRoleSet.add(uRole.obj.Name);
                }
                else if(uRole.obj.Type__c == TFS_Utility.REGION){
                    regionRoleSet.add(uRole.obj.Name);
                }
            }
        } 
        
        //Dealer record type id
        string dealerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(TFS_Utility.DEALER).getRecordTypeId();
        //Fetching all dealers including child records of AccounTeamMember and TMS detail
        List<Account> accDealerList = [select id,Name,Region_Name__c,DSSO_ID__c,DSSO_Name__c,TFS_Area__c,
                                        TFS_Area__r.Name,Area_ID__c,Type,ownerId,owner.Name,owner.email,
                                        owner.Phone,AccountNumber,Status__c,Vehicle_Benefit__c,
                                        Previous_Account_No__c,Related_Account__c,Related_Account__r.Name,
                                        TFS_Relationship__c,(Select id,Region_Name__c from TMS_details_del__r),
                                        (Select Id, AccountId,userId,user.Name,TeamMemberRole From AccountTeamMembers 
                                        where TeamMemberRole in :dealerRoleSet) 
                                        From Account where recordTypeId = :dealerRecTypeId order by id limit 50000];  
        
        //Unique DSSO 
        set<string> dssoNameSet = new set<String>(); 
        set<string> regionNameSet = new set<String>();
        for(Account acc:accDealerList){
            if(acc.DSSO_Name__c != null){
                dssoNameSet.add(acc.DSSO_Name__c);
            }
            if(acc.Region_Name__c != null){
                regionNameSet.add(acc.Region_Name__c); 
            }
        } 
        
        List<AccountTeamMember> atmList = [select id,AccountId,Account.Name,Account.Type,TeamMemberRole,
                                                            userId,user.Name,Account.RecordType.Name    
                                                            From AccountTeamMember 
                                                            Where (Account.Name in :regionNameSet and 
                                                                   TeamMemberRole in :regionRoleSet) 
                                                            Or (Account.Name in :dssoNameSet and 
                                                                TeamMemberRole in :dssoRoleSet) 
                                                            Or (accountId in :accDealerList and 
                                                                TeamMemberRole in :dealerRoleSet)];
        
        //storing roles in map based on DEALER/DSSO/REGION
        Map<String,Map<String,String>> dealerRoleUserMap = new Map<String,Map<String,String>>(); 
        Map<String,Map<String,String>> dssoRoleUserMap = new Map<String,Map<String,String>>();
        Map<String,Map<String,String>> regionRoleUserMap = new Map<String,Map<String,String>>();
        for(AccountTeamMember atm : atmList){           
            if(atm.Account.RecordType.Name == TFS_Utility.DEALER){  //Dealer team members
                dealerRoleUserMap = getRoleUserMap(dealerRoleUserMap,atm,atm.AccountId);   
            }
            else if(atm.Account.RecordType.Name == TFS_Utility.LOCATION){
                if(atm.Account.Type == TFS_Utility.DSSO){  //Dsso team members
                    dssoRoleUserMap = getRoleUserMap(dssoRoleUserMap,atm,atm.Account.Name);    
                }
                else if(atm.Account.Type == TFS_Utility.REGION){  // Region team members
                    regionRoleUserMap = getRoleUserMap(regionRoleUserMap,atm,atm.Account.Name); 
                } 
            }
        }
         
        //Dealers iteration to prepare wrapper class to display on the page
        accWrapperList = new List<accountWrapper>();
        for(Account acc:accDealerList){
            TMS_detail__c tmsDetail = acc.TMS_details_del__r.size() > 0 ? acc.TMS_details_del__r[0] : null;
            if(!(tmsDetail != null && tmsDetail.Region_Name__c != null 
                                  && tmsDetail.Region_Name__c.contains(TFS_Utility.SOUTHEAST_TOYOTA))){
            
                accountWrapper aw = new accountWrapper();
                aw.TFSRegion = acc.Region_Name__c;
                aw.DSSOId = acc.DSSO_ID__c != null ? acc.DSSO_ID__c : '';
                aw.DSSOName = acc.DSSO_Name__c;
                aw.TFSArea = acc.TFS_Area__r.Name != null ? acc.TFS_Area__r.Name : '';
                aw.TFSAreaId = acc.Area_ID__c != null ? acc.Area_ID__c : '';
                aw.dealerType = acc.type;
                aw.ASM = acc.owner.Name;
                aw.dealerNumber = acc.accountNumber != null ? acc.accountNumber : '';
                aw.dealerName = acc.Name;
                aw.TMSRegionName = null;
                if(acc.TMS_details_del__r.size() > 0){
                    aw.TMSRegionName = acc.TMS_details_del__r[0].Region_Name__c;
                }
                aw.dealerStatus = acc.status__c;
                aw.vehicleBenefit = acc.Vehicle_Benefit__c;
                aw.preAccNumber = acc.Previous_Account_No__c != null ? acc.Previous_Account_No__c : '';
                aw.prevAccName = acc.Related_Account__r.Name;
                aw.ASMPhoneNumber = acc.owner.phone;
                aw.ASMEmailAddress = acc.owner.email;
                aw.TFSRelationship = acc.TFS_Relationship__c; 
                
                Map<string,string> roleUserMap = new Map<string,string>();
                //Get account team info from Dealer
                if(dealerRoleUserMap.containsKey(acc.Id)){
                    roleUserMap.putAll(dealerRoleUserMap.get(acc.Id));
                }
                
                //Get account team info from DSSO
                if(acc.DSSO_Name__c != null  && acc.DSSO_Name__c != TFS_Utility.BLANK){
                    if(dssoRoleUserMap.containskey(acc.DSSO_Name__c)){
                        roleUserMap.putAll(dssoRoleUserMap.get(acc.DSSO_Name__c));
                    }
                }
                
                //Get account team info from Region
                if(acc.Region_Name__c != null  && acc.Region_Name__c != TFS_Utility.BLANK){
                    if(regionRoleUserMap.containskey(acc.Region_Name__c)){
                        roleUserMap.putAll(regionRoleUserMap.get(acc.region_Name__c));
                    }
                }
                
                //If roles are not existed in database, assigning blank values as username
                for(string str:roleList){
                    if(!roleUserMap.containskey(str)){
                        roleUserMap.put(str,TFS_Utility.BLANK);
                    }
                } 
                aw.roleUserMap = roleUserMap;

                accWrapperList.add(aw);
            }     
        }      
    }
    
    //Get user name based on roles from account team members. if role is not existed, we are adding roles
    //which are existed in custom settings roles
    public Map<string,Map<string,string>> getRoleUserMap(Map<string,Map<String,String>> roleUserMap,AccountTeamMember atm,string key){
        string mapKey = key;
        if(roleUserMap.containsKey(mapKey)){
            Map<string,string> roleMap = roleUserMap.get(mapKey);
            if(roleMap.containsKey(atm.TeamMemberRole)){
               string str = roleMap.get(atm.TeamMemberRole)+TFS_Utility.COMMA+atm.user.Name;
               roleMap.put(atm.TeamMemberRole,str);     
            }
            else{
                roleMap.put(atm.TeamMemberRole,atm.user.Name);
            }
            roleUserMap.put(mapKey,roleMap);
        }
        else{
            Map<string,string> roleMap = new Map<string,string>();
            roleMap.put(atm.TeamMemberRole,atm.user.Name);
            roleUserMap.put(mapKey,roleMap);
        }
        
        return roleUserMap;
    } 
    
    //created a wrapper class for Custom sorting on roles based on priority
    public class roleWrapper implements Comparable {

        public Account_Team_Report_Columns__c obj{get;set;}
        
        // Constructor
        public roleWrapper(Account_Team_Report_Columns__c obj) {
            this.obj = obj;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            roleWrapper compareToObj = (roleWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (obj.Priority__c > compareToObj.obj.Priority__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (obj.Priority__c< compareToObj.obj.Priority__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    //Account Wrapper class to display the data page
    public class accountWrapper{
        public String TFSRegion{get;set;}
        public String DSSOId{get;set;}
        public String DSSOName{get;set;}
        public String TFSArea{get;set;}
        public String TFSAreaId{get;set;}
        public String dealerType{get;set;}
        public String ASM{get;set;}
        public String dealerNumber{get;set;}
        public String dealerName{get;set;}
        public String TMSRegionName{get;set;}
        public String dealerStatus{get;set;}
        public boolean vehicleBenefit{get;set;}
        public String preAccNumber{get;set;}
        public String prevAccName{get;set;}
        public String ASMPhoneNumber{get;set;}
        public String ASMEmailAddress{get;set;}
        public String TFSRelationship{get;set;}
        public Map<string,string> roleUserMap{get;set;} 
    }
}