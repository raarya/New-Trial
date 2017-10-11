/**************************************************************************************************************************************************
* Class Name: AccountTeamReportExcelControllerTest
* Author: Bhargavaramu
* Date: [06/Sep/2017]
* Requirement Description:  User story: 6910
* Date Modified                Modified By                  Description of the update  
***************************************************************************************************************************************************/
@isTest
private class AccountTeam_ReportExcelControllerTest{
    static testMethod void unitTest1(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        User u1 = TestUtility.createUser(pr.id);
        u1.username = 'fdasdfjasdfasdfa@abc.com';
        u1.communitynickname = 'fdsdsd';
        u1.alias = 'dfsdf';
        if(u1 != null){
            insert u1;
        } 
        system.assert(u1.id != null);
        
        List<Account_Team_Report_Columns__c> testDataList = TestUtility.createAccTeamReportCustomSettingData();
        if(testDataList != null && !testDataList.isEmpty()){
            insert testDataList;
        }
        
        system.runas(u){
            Test.startTest();
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.AccountNumber = '69780';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '6978078';
            dssoAcnt.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt != null){
                insert dssoAcnt;
            }
            system.assert(dssoAcnt.id != null);
            
            TFS_Area__c tfsA = TestUtility.createTFSArea(dssoAcnt.Name,'02');
            if(tfsA != null){
                insert tfsA;
            }
            system.assert(tfsA.id != null);
            
            TFS_Area__c tfsA1 = TestUtility.createTFSArea(dssoAcnt.Name,'03');
            if(tfsA1 != null){
                insert tfsA1;
            }
            system.assert(tfsA1.id != null);
            
            //Creating Account Data
            List<Account> dealerList = new List<Account>();
            dealerList.add(TestUtility.createAccount(dssoAcnt.Name,'455436567', tfsA));
            dealerList.add(TestUtility.createAccount(dssoAcnt.Name,'656543', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                dealerList[0].DSSO_Name__c = dssoAcnt.Name;
                dealerList[1].DSSO_Name__c = dssoAcnt.Name;
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
            
            AccountTeamMember regionAT1 = TestUtility.accountTeamMemberInsrt(regionAcc);
            regionAT1.TeamMemberRole = 'Region Manager';
            regionAT1.UserId = u.id;
            AccountTeamMember regionAT2 = TestUtility.accountTeamMemberInsrt(regionAcc);
            regionAT2.TeamMemberRole = 'Region Manager';
            regionAT2.UserId = u1.id;
            AccountTeamMember dssoAT1 = TestUtility.accountTeamMemberInsrt(dssoAcnt);
            dssoAT1.TeamMemberRole = 'DSSM';
            dssoAT1.UserId = u.id;
            AccountTeamMember dssoAT2 = TestUtility.accountTeamMemberInsrt(dssoAcnt);
            dssoAT2.TeamMemberRole = 'DSSM';
            dssoAT2.UserId = u1.id;
            AccountTeamMember dealerAT1 = TestUtility.accountTeamMemberInsrt(dealerList[0]);
            dealerAT1.TeamMemberRole = 'Product Manager';
            dealerAT1.UserId = u.id;
            AccountTeamMember dealerAT2 = TestUtility.accountTeamMemberInsrt(dealerList[0]);
            dealerAT2.TeamMemberRole = 'Product Manager';
            dealerAT2.UserId = u1.id;
            
            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            atmList.add(regionAT1);
            atmList.add(regionAT2);
            atmList.add(dssoAT1);
            atmList.add(dssoAT2);
            atmList.add(dealerAT1);
            atmList.add(dealerAT2);
            
            if(atmList != null && !atmList.isEmpty()){
                insert atmList;
            }
            system.assert(atmList.size() == 6);
            
            AccountTeam_ReportExcelController atec = new AccountTeam_ReportExcelController();
            
            Test.stopTest(); 
        }
    }
}