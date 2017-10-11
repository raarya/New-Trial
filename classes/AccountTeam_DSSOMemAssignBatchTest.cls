/********************************************************************************************
* Class Name: AccountTeam_DSSOMemAssignBatchTest
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/20/2017]
* Requirement Description:W-004163 : As a Region AA, Sales HQ Admin I want be able to assign a product manager
* to a DSSO within a region and to dealers within the same region so that I can manage product manager assignments
* Date Modified                Modified By                  Description of the update
* [06/15/2017]               Rajeev Arya (Deloitte)        W-005910 : SRM_BR_TM_063 – Assigning Account Team Members to DSSOs and Dealers
* [09/14/2017]               Rajeev Arya (Deloitte)        W-006309 : Redesigning the complete batch class based on new requiremnts
***********************************************************************************************/
@isTest(SeeAllData=false)
public class AccountTeam_DSSOMemAssignBatchTest {
    @testSetup
    public static void createTestData() {    
        //creating Custom Setting record
        TestUtility.insertCustomSetting(); 
        
        //creating users
        Profile pr = [select id from profile where name = 'SRM User'];
        map<String, ID> mapRoleNameToID = new map<String, ID>();
        for(UserRole ur : [SELECT Id, name from UserRole where PortalType != 'Partner' and name in ('BALTIMORE ASM', 'FAIRFAX ASM', 'SEATTLE ASM', 'DETROIT ASM', 'ATLANTA ASM', 'Western Region Management', 'Central Region Management', 'Eastern Region Management')]){
        	mapRoleNameToID.put(ur.name, ur.Id);
        }
        list<User> lstUsr = new list<User>();
        User u1 = TestUtility.createUser(pr.Id);
        u1.userroleId = mapRoleNameToID.get('BALTIMORE ASM');
        u1.TFS_SRM_Title__c = 'ASM';
        u1.username = 'TFSabcTFS1@xyz1.com';
        lstUsr.add(u1);
        User u2 = TestUtility.createUser(pr.Id);
        u2.userroleId = mapRoleNameToID.get('FAIRFAX ASM');
        u2.TFS_SRM_Title__c = 'ASM';
        u2.username = 'TFSabcTFS2@xyz2.com';
        lstUsr.add(u2);
        User u3 = TestUtility.createUser(pr.Id);
        u3.userroleId = mapRoleNameToID.get('SEATTLE ASM');
        u3.TFS_SRM_Title__c = 'ASM';
        u3.username = 'TFSabcTFS3@xyz3.com';
        lstUsr.add(u3);
        User u4 = TestUtility.createUser(pr.Id);
        u4.userroleId = mapRoleNameToID.get('DETROIT ASM');
        u4.TFS_SRM_Title__c = 'ASM';
        u4.username = 'TFSabcTFS4@xyz4.com';
        lstUsr.add(u4);
        User u5 = TestUtility.createUser(pr.Id);
        u5.userroleId = mapRoleNameToID.get('BALTIMORE ASM');
        u5.TFS_SRM_Title__c = 'ASM';
        u5.username = 'TFSabcTFS5@xyz5.com';
        lstUsr.add(u5);
        User uPMWestern = TestUtility.createUser(pr.Id);
        uPMWestern.userroleId = mapRoleNameToID.get('Western Region Management');
        uPMWestern.TFS_SRM_Title__c = 'Region Manager';
        uPMWestern.username = 'TFSabcTFS6@xyz6.com';
        User uPMEastern = TestUtility.createUser(pr.Id);
        uPMEastern.userroleId = mapRoleNameToID.get('Eastern Region Management');
        uPMEastern.TFS_SRM_Title__c = 'Region Manager';
        uPMEastern.username = 'TFSabcTFS7@xyz7.com';
        System.runas(new User(Id = UserInfo.getUserId())){
		    insert lstUsr;
		    insert uPMEastern;
		    insert uPMWestern;
		}
        
        map<String, ID> mapTerrNameToID = new map<String, ID>();
        for(Territory2 terr : [select id, name from Territory2 where name in ('BALTIMORE', 'FAIRFAX', 'SEATTLE', 'DETROIT', 'Western Region', 'Eastern Region')]){
        	mapTerrNameToID.put(terr.name, terr.Id);
        }
        list<UserTerritory2Association> lstUt = new list<UserTerritory2Association>();
        UserTerritory2Association ut1 = TestUtility.createUserTerr(lstUsr[0].Id, mapTerrNameToID.get('BALTIMORE'));
        //lstUt.add(ut1);
        UserTerritory2Association ut2 = TestUtility.createUserTerr(lstUsr[1].Id, mapTerrNameToID.get('FAIRFAX'));
        lstUt.add(ut2);
        UserTerritory2Association ut3 = TestUtility.createUserTerr(lstUsr[2].Id, mapTerrNameToID.get('SEATTLE'));
        lstUt.add(ut3);
        UserTerritory2Association ut4 = TestUtility.createUserTerr(lstUsr[3].Id, mapTerrNameToID.get('DETROIT'));
        //lstUt.add(ut4); 
        UserTerritory2Association ut5 = TestUtility.createUserTerr(lstUsr[3].Id, mapTerrNameToID.get('BALTIMORE'));
        lstUt.add(ut5);
        UserTerritory2Association ut6 = TestUtility.createUserTerr(uPMWestern.Id, mapTerrNameToID.get('SEATTLE'));
        lstUt.add(ut6); 
        UserTerritory2Association ut7 = TestUtility.createUserTerr(uPMWestern.Id, mapTerrNameToID.get('Western Region'));
        lstUt.add(ut7); 
        System.runas(new User(Id = UserInfo.getUserId())){
		    insert lstUt;
		}
        
        map<String, ID> mapRoleNameToUsrID = new map<String, ID>();
        for(User u : [select id, userrole.name from user limit 10]){
        	mapRoleNameToUsrID.put(u.userrole.name, u.Id);	
        }
        
        //creating parent regions
        list<Account> lstRegions = new list<Account>();
        Account cenRegion = TestUtility.createRegion('Central', '01');
        lstRegions.add(cenRegion);
        Account wesRegion = TestUtility.createRegion('Western', '02');
        lstRegions.add(wesRegion);
        Account easRegion = TestUtility.createRegion('Eastern', '03');
        lstRegions.add(easRegion);
        if(!lstRegions.isEmpty())
        	insert lstRegions;
        
        //creating DSSOs
        list<Account> lstDSSOs = new list<Account>();
        Account balDSSO = TestUtility.createLocationDSSO('BALTIMORE', '');
        balDSSO.accountNumber = '031';
        balDSSO.parentId = lstRegions[0].Id;
        lstDSSOs.add(balDSSO);
        Account fairDSSO = TestUtility.createLocationDSSO('FAIRFAX', '');
        fairDSSO.accountNumber = '032';
        fairDSSO.parentId = lstRegions[0].Id;
        lstDSSOs.add(fairDSSO);
        Account seaDSSO = TestUtility.createLocationDSSO('SEATTLE', '');
        seaDSSO.accountNumber = '033';
        seaDSSO.parentId = lstRegions[1].Id;
        lstDSSOs.add(seaDSSO);
        Account detDSSO = TestUtility.createLocationDSSO('DETROIT', '');
        detDSSO.accountNumber = '034';
        detDSSO.parentId = lstRegions[2].Id;
        lstDSSOs.add(detDSSO);
        Account atlDSSO = TestUtility.createLocationDSSO('ATLANTA', '');
        atlDSSO.accountNumber = '039';
        atlDSSO.parentId = lstRegions[1].Id;
        lstDSSOs.add(atlDSSO);
        insert lstDSSOs;
        
        //creating team members on the DSSOs
        list<AccountTeamMember> lstAccTeamForDSSOs = new list<AccountTeamMember>();
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'DSSM', userid = lstUsr[1].Id, accountId = lstDSSOs[1].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'DSSM', userid = lstUsr[1].Id, accountId = lstDSSOs[0].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'DSSM', userid = lstUsr[4].Id, accountId = lstDSSOs[2].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'DSSM', userid = lstUsr[4].Id, accountId = lstDSSOs[4].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'DSSM', userid = lstUsr[2].Id, accountId = lstDSSOs[2].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = lstUsr[2].Id, accountId = lstDSSOs[3].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = lstUsr[3].Id, accountId = lstDSSOs[3].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = lstUsr[0].Id, accountId = lstDSSOs[3].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = lstUsr[0].Id, accountId = lstDSSOs[0].Id));
        lstAccTeamForDSSOs.add(new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = lstUsr[0].Id, accountId = lstDSSOs[4].Id));
        
        if(!lstAccTeamForDSSOs.isEmpty()) 
        	insert lstAccTeamForDSSOs;
        
        AccountTeamMember PMSeattle = new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = uPMWestern.Id, accountId = lstDSSOs[2].Id);
        if(PMSeattle != null)
        	insert PMSeattle;
        AccountTeamMember PMDetroit = new AccountTeamMember(TeamMemberRole = 'Product Manager', userid = uPMWestern.Id, accountId = lstDSSOs[3].Id);
        if(PMDetroit != null)
        	insert PMDetroit;
        	
        //updating the team members to a past created date
        Test.setCreatedDate(lstAccTeamForDSSOs[0].Id, DateTime.newInstance(2016,12,12));
        Test.setCreatedDate(lstAccTeamForDSSOs[2].Id, DateTime.newInstance(2016,12,12));
        Test.setCreatedDate(lstAccTeamForDSSOs[4].Id, DateTime.newInstance(2016,12,12));
        Test.setCreatedDate(PMSeattle.Id, DateTime.newInstance(2016,12,12));

        //creating test dealers on those DSSOs
        list<Account> listAcc = new list<Account>();
        Account acc = TestUtility.createAccount('ABC','1289783',null);
        acc.TFS_Area__c = null;
        acc.DSSO_Name__c = 'BALTIMORE';
        listAcc.add(acc);
        Account acc1 = TestUtility.createAccount('ABCD','1222334',null);
        acc1.TFS_Area__c = null;
        acc1.DSSO_Name__c = 'FAIRFAX';
        listAcc.add(acc1);
        Account acc2 = TestUtility.createAccount('AC','1354331',null);
        acc2.TFS_Area__c = null;
        acc2.DSSO_Name__c = 'SEATTLE';
        listAcc.add(acc2);
        Account acc3 = TestUtility.createAccount('AC','1354332',null);
        acc3.TFS_Area__c = null;
        acc3.DSSO_Name__c = 'DETROIT';
        listAcc.add(acc3);
        Account acc4 = TestUtility.createAccount('AC','1354338',null);
        acc4.TFS_Area__c = null;
        acc4.DSSO_Name__c = 'ATLANTA';
        listAcc.add(acc4);
        if(listAcc != null)
        insert listAcc;
        
        //creating account team members
        list<AccountTeamMember> lstAccTeam = new list<AccountTeamMember>();
        lstAccTeam.add(new AccountTeamMember(TeamMemberRole = 'DSM', userid = lstUsr[1].Id, accountId = listAcc[0].Id));
        lstAccTeam.add(new AccountTeamMember(TeamMemberRole = 'DSOM', userid = lstUsr[2].Id, accountId = listAcc[1].Id));
        if(!lstAccTeam.isEmpty()) 
        	insert lstAccTeam;
        	
        //creating tasks 
        list<Task> lstTasks = TestUtility.createTaskBulkified(5, listAcc[0], 'CFPB-Related');
        lstTasks[0].OwnerID = lstUsr[1].Id;
        lstTasks[0].ActivityDate = Date.today() - 2;
        lstTasks[0].contact_type__c = 'Associate Changes';
        lstTasks[0].Subject = '';
        lstTasks[1].OwnerID = lstUsr[1].Id;
        lstTasks[1].ActivityDate = Date.today() + 10;
        lstTasks[1].contact_type__c = 'Associate Changes';
        lstTasks[1].Subject = '';
        
        lstTasks[2].OwnerID = lstUsr[4].Id;
        lstTasks[2].ActivityDate = Date.today() - 2;
        lstTasks[2].contact_type__c = 'Associate Changes';
        lstTasks[2].Subject = '';
        lstTasks[3].OwnerID = lstUsr[4].Id;
        lstTasks[3].ActivityDate = Date.today() + 10;
        lstTasks[3].contact_type__c = 'Associate Changes';
        lstTasks[3].Subject = '';
        
        lstTasks[4].OwnerID = lstUsr[2].Id;
        lstTasks[4].ActivityDate = Date.today() - 2;
        lstTasks[4].contact_type__c = 'Associate Changes';
        lstTasks[4].Subject = '';
        lstTasks[5].OwnerID = lstUsr[2].Id;
        lstTasks[5].ActivityDate = Date.today() + 10;
        lstTasks[5].contact_type__c = 'Associate Changes';
        lstTasks[5].Subject = '';
        if(!lstTasks.isEmpty())
        	insert lstTasks;
       
        //creating events
        list<Event> lstEvents = TestUtility.createEventBulkified(5, listAcc[0]);
        lstEvents[0].OwnerID = lstUsr[1].Id;
        lstEvents[0].ActivityDateTime = Date.today() - 2;
        lstEvents[0].contact_type__c = 'Associate Changes';
        lstEvents[1].OwnerID = lstUsr[1].Id;
        lstEvents[1].ActivityDateTime = Date.today() + 10;
        lstEvents[1].contact_type__c = 'Associate Changes';
        
        lstEvents[2].OwnerID = lstUsr[4].Id;
        lstEvents[2].ActivityDateTime = Date.today() - 2;
        lstEvents[2].contact_type__c = 'Associate Changes';
        lstEvents[3].OwnerID = lstUsr[4].Id;
        lstEvents[3].ActivityDateTime = Date.today() + 10;
        lstEvents[3].contact_type__c = 'Associate Changes';
        
        lstEvents[4].OwnerID = lstUsr[2].Id;
        lstEvents[4].ActivityDateTime = Date.today() - 2;
        lstEvents[4].contact_type__c = 'Associate Changes';
        lstEvents[5].OwnerID = lstUsr[2].Id;
        lstEvents[5].ActivityDateTime = Date.today() + 10;
        lstEvents[5].contact_type__c = 'Associate Changes';
        if(!lstEvents.isEmpty())
        	insert lstEvents;

    } 
    
    static testMethod void TFSC_DealerContactStatusTestMethod() 
    {
        
        AccountTeam_DSSOMemAssignBatch batchJob = new AccountTeam_DSSOMemAssignBatch();
        Database.executebatch(batchJob);
        AccountTeam_DSSOMemAssignScheduler  schJob = new AccountTeam_DSSOMemAssignScheduler();
        String sch = label.Scheduling_String; 
        Test.startTest();
        system.schedule('Test Territory Check', sch, schJob);
        Test.stopTest();
        System.AssertNotEquals(database.countquery('SELECT COUNT() FROM AccountTeamMember where account.recordtype.name != \'Location\''),0);

        
    }
}