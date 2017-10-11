/********************************************************************************************************************
* Class Name: AccountTeam_DSSOMemAssignBatch
* Author: Ritesh Jaiswal (Deloitte)
* Date: [02/20/2017]
* Requirement Description:W-004163 : As a Region AA, Sales HQ Admin I want be able to assign a product manager
* to a DSSO within a region and to dealers within the same region so that I can manage product manager assignments
* Date Modified                Modified By                  Description of the update
* [06/15/2017]               Rajeev Arya (Deloitte)        W-005910 : SRM_BR_TM_063 – Assigning Account Team Members to DSSOs and Dealers
* [08/30/2017]               Rajeev Arya(Deloitte)         W-006309 : Redesigning the complete batch class based on new requiremnts
* [09/20/2017]               Rajeev Arya(Deloitte)         W-007151 : Future activities getting reassigned to same user for account team batch
* [09/21/2017]               Rajeev Arya(Deloitte)         W-007152 : Code update to allow the presence of same user on multiple DSSOs
* [09/25/2017]               Rajeev Arya(Deloitte)         W-007164 : DSSO Exclusion Lists enhancement for stories W-004475 and W-006309
*******************************************************************************************************************/
global class AccountTeam_DSSOMemAssignBatch implements Database.Batchable<sObject> , Database.Stateful{
   
    Id locationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(TFS_Utility.LOCATION).getRecordTypeId();    
    String query = TFS_Utility.BLANK;
    public set<String> setProcessedDSSOs = new set<String>();
    public map<ID, list<UserTerritory2Association>> mapUsrIDToTerrAssociations = new map<ID, list<UserTerritory2Association>>();
    public map<ID, User> mapUsrIDToUsrDetails = new map<ID, User>();
    list<UserTerritory2Association> lstUsrTerrToDelete = new list<UserTerritory2Association>();
    set<ID> setUsrTerrToDelete = new set<ID>();
    set<ID> setMemberProcessed = new set<ID>(); //For story W-007152 
    
    //fetching the customizable date time values for the time filter
    DateTime dtSchedule1 = Configurable_Values__c.getInstance().Account_Team_Batch_Schedule_1__c;
    DateTime dtSchedule2 = Configurable_Values__c.getInstance().Account_Team_Batch_Schedule_2__c;
    Integer currentHour = datetime.now().hour();
    Date previousDate;
    DateTime dtSchedule1GMT;
    DateTime dtSchedule2GMT;
    DateTime dt1;
    DateTime dt2;
    DateTime dt3; 
    
    //Querying all the dealers with their team members in child query   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'select id, name, DSSO_Name__c, (select id, userId, teammemberrole, lastmodifiedbyId from accountteammembers where ';
        query += 'user.isactive = true) from account where account.name!=null ';
        query += 'and account.recordtypeId != :locationRecordTypeId and DSSO_Name__c != null order by DSSO_Name__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lstAcc) {
        try{
            //initializing all required variables
            if(dtSchedule1 != null && dtSchedule2 != null){ 
                previousDate = date.today()-1;
                dtSchedule1GMT = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day(), dtSchedule1.hour(), dtSchedule1.minute(), dtSchedule1.second());
                dtSchedule2GMT = DateTime.newInstance(date.today().year(), date.today().month(), date.today().day(), dtSchedule2.hour(), dtSchedule2.minute(), dtSchedule2.second());
                //previous day's schedule 2 datetime
                dt1 = DateTime.newInstance(previousDate.year(), previousDate.month(), previousDate.day(), dtSchedule2.hour(), dtSchedule2.minute(), dtSchedule2.second());
                //current day's schedule 1 datetime
                dt2 = dtSchedule1GMT;
                //current day's schedule 2 datetime
                dt3 = dtSchedule2GMT; 
            }
            set<String> setDSSOs = new set<String>();
           
            Map<String, list<AccountTeamMember>> mapDSSONameToPMMembers = new Map<String, list<AccountTeamMember>>();
            list<AccountTeamMember> lstAccTeamMemberToDelete = new list<AccountTeamMember>();
            list<AccountTeamMember> lstPMAccTeamMemberToDelete = new list<AccountTeamMember>();
            list<AccountTeamMember> lstAccTeamMemberCurrent = new list<AccountTeamMember>();
            list<AccountTeamMember> lstAccTeamMemberPast = new list<AccountTeamMember>();
            String strAccTeamQuery = TFS_Utility.BLANK;
            map<ID, String> mapUserIdToDSSOName = new map<ID, String>();
            map<ID, String> mapUserIdToOldDSSOName = new map<ID, String>();
            list<AccountTeamMember> lstDealerMemToInsert = new list<AccountTeamMember>();
            map<ID, String> mapUserIdToRegionName = new map<ID, String>();
            map<ID, String> mapUserIdToRoleName = new map<ID, String>();
            Boolean isPM = false;
            Boolean PMToBeDeleted = false;
            Error_Log__c errLog = new Error_Log__c();
            list<Error_Log__c> listErrLog = new list<Error_Log__c>();
            String errMsg = TFS_Utility.BLANK;
            map<String, ID> mapTerrNameToID = new map<String, ID>(); 
            String strDSSOs = TFS_Utility.BLANK;
            set<ID> setProcessedUsers = new set<ID>();
            set<ID> setProcessedUsersForAccTeam = new set<ID>();
            set<ID> setPMUsers = new set<ID>();
            map<String, ID> mapRoleNameToRoleID = new map<String, ID>();
            map<ID, set<ID>> mapASMIDToSetUsrTerrID = new map<ID, set<ID>>();
            map<ID, String> mapUserIdToTerritory = new map<ID, String>(); 
            set<String> setOldDSSONames = new set<String>();
            map<String, ID> mapDSSOToUserID = new map<String, ID>();
            list<Task> lstTasksToUpdate = new list<Task>();
            list<Event> lstEventsToUpdate = new list<Event>();
            ID oldOwnerID;
            String strRoleName = TFS_Utility.BLANK;
            set<String> setRegionNames = new set<String>();
            String strRegionTerrName = TFS_Utility.BLANK;
            //new change for W-007152
            map<ID, set<String>> mapUserIDToOldDSSONames = new map<ID, set<String>>();
            set<String> setOldDSSONamesReass;
            set<ID> setOldDSSOAndDealerIDs = new set<ID>();
            map<ID, String> mapDSSOorDealerIdToDSSOName = new map<ID, String>();
            //new change for W-007152
            
            // Start for #W-007164
            //fetching the DSSO Exclusion values
            map<String, Integer> mapDSSONameToGrpNum = new map<String, Integer>();
            mapDSSONameToGrpNum = TFS_Utility.fetchDSSOExclusions();
            // End for #W-007164
                   
            //creating a set of DSSOs from fetched dealers
            for(Account acc : lstAcc){
                setDSSOs.add(acc.DSSO_Name__c);
            }
            
            //retrieving DSSO Team Members for the set of DSSOs created above, and putting them in a map
            strAccTeamQuery = 'select id, user.name, account.Name, account.parent.name, user.userrole.name,';
            strAccTeamQuery += 'userId, teammemberrole from accountteammember ';
            strAccTeamQuery += 'where user.isactive = true and account.Name in :setDSSOs ';
            strAccTeamQuery += 'and account.type = \'DSSO\' and account.recordtypeId = :locationRecordTypeId ';
            if(dtSchedule1 == null || dtSchedule2 == null)
                strAccTeamQuery += 'and (createddate = today) ';
            else if(currentHour < dt3.hour())
                strAccTeamQuery += 'and (createddate >= :dt1 and createddate < :dt2) ';
            else if (currentHour >= dt3.hour())
                strAccTeamQuery += 'and (createddate >= :dt2) ';
            //strAccTeamQuery += 'and account.name not in :setProcessedDSSOs and account.name != null';
            lstAccTeamMemberCurrent = Database.query(strAccTeamQuery);
            for(AccountTeamMember dssoMem: lstAccTeamMemberCurrent){
                if(dssoMem.teammemberrole == TFS_Utility.PM){
                    if(!mapDSSONameToPMMembers.containsKey(dssoMem.account.name)){
                        mapDSSONameToPMMembers.put(dssoMem.account.name, new list<AccountTeamMember>{dssoMem});
                    }
                    else if(mapDSSONameToPMMembers.containsKey(dssoMem.account.name)){
                        list<AccountTeamMember> lstATM = new list<AccountTeamMember>();
                        lstATM = mapDSSONameToPMMembers.get(dssoMem.account.name);
                        lstATM.add(dssoMem);
                        mapDSSONameToPMMembers.put(dssoMem.account.name, lstATM);
                    }
                }
                mapUserIdToDSSOName.put(dssoMem.userId, dssoMem.account.name);
                mapUserIdToRegionName.put(dssoMem.userId, dssoMem.account.parent.name);
                mapUserIdToRoleName.put(dssoMem.userId, dssoMem.teammemberrole);
                setProcessedDSSOs.add(dssoMem.account.name);
                setRegionNames.add(dssoMem.account.parent.name + '%');
                
            }
            
            //fetching the territory IDs for new territories
            for(Territory2 terr : [select id, name from Territory2 where (name in :setProcessedDSSOs or name like :setRegionNames)]){
                mapTerrNameToID.put(terr.name, terr.Id);
            }
            
            //fetching the non-partner roles and mapping them based on names
            for(UserRole usrRole : [SELECT Id, name from UserRole where PortalType != 'Partner']){
                mapRoleNameToRoleID.put(usrRole.name, usrRole.Id);
            }
            system.debug('testing1' + mapRoleNameToRoleID);
            
            //fetching the territories the users are added to
            set<ID> setTerrIDs = new set<ID>();
            for(UserTerritory2Association usrTerr : [SELECT Id, Territory2.name, UserID FROM UserTerritory2Association where isActive = true and UserId in :mapUserIdToDSSOName.keySet()]){
                mapUserIdToTerritory.put(usrTerr.UserID, usrTerr.Territory2.name);
                if(!mapASMIDToSetUsrTerrID.containsKey(usrTerr.UserID))
                  mapASMIDToSetUsrTerrID.put(usrTerr.UserID, new set<ID>());
                setTerrIDs = mapASMIDToSetUsrTerrID.get(usrTerr.UserID); 
                setTerrIDs.add(usrTerr.Id);
                mapASMIDToSetUsrTerrID.put(usrTerr.UserID, setTerrIDs);
            }
            
            for(Account acc : lstAcc){
                isPM = false;
                for(AccountTeammember dealerMem : acc.accountteammembers){
                    if(dealerMem.teammemberrole == TFS_Utility.PM){
                        isPM = true;
                        PMToBeDeleted = true;
                        if(dealerMem.lastmodifiedbyId == userinfo.getuserID() && !mapDSSONameToPMMembers.containsKey(acc.dsso_name__c))
                            lstPMAccTeamMemberToDelete.add(dealerMem);
                        else if(dealerMem.lastmodifiedbyId == userinfo.getuserID() && mapDSSONameToPMMembers.containsKey(acc.dsso_name__c)){
                            for(AccountTeamMember atm : mapDSSONameToPMMembers.get(acc.dsso_name__c)){
                                if(dealerMem.userId == atm.userID)
                                    PMToBeDeleted = false;
                            }
                            if(PMToBeDeleted)
                                lstPMAccTeamMemberToDelete.add(dealerMem);
                        }
                    }
                }
                if(!isPM && mapDSSONameToPMMembers.containsKey(acc.dsso_name__c)){
                    for(AccountTeamMember atm : mapDSSONameToPMMembers.get(acc.dsso_name__c)){
                        lstDealerMemToInsert.add(new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = TFS_Utility.PM, 
                                                UserId = atm.userID));
                    }
                }
                
            }
            
            set<ID> setSameUserIDs = mapUserIdToDSSOName.KeySet();
            strAccTeamQuery = 'select id, accountId, account.Name, account.parent.name, user.userrole.name,'; //new change for W-007152
            strAccTeamQuery += 'userId, user.Associated_DSSOs__c, teammemberrole ';
            strAccTeamQuery += 'from accountteammember where user.isactive = true and userId in :setSameUserIDs ';
            strAccTeamQuery += 'and account.type = \'DSSO\' and account.recordtypeId = :locationRecordTypeId ';
            if(dtSchedule1 == null || dtSchedule2 == null)
                strAccTeamQuery += 'and (createddate < today)';
            else if(currentHour < dt3.hour())
                strAccTeamQuery += 'and (createddate < :dt1)';
            else if (currentHour >= dt3.hour())
                strAccTeamQuery += 'and (createddate < :dt2)';
            lstAccTeamMemberPast = Database.query(strAccTeamQuery);
            list<UserTerritory2Association> lstUTerr = new list<UserTerritory2Association>();
            for(AccountTeamMember dssoMem: lstAccTeamMemberPast){
                //new change for W-007152
                mapDSSOorDealerIdToDSSOName.put(dssoMem.accountId, dssoMem.account.Name);
                setOldDSSONames.add(dssoMem.account.Name);
                if(!mapUserIDToOldDSSONames.containsKey(dssoMem.UserId))
                	mapUserIdToOldDSSONames.put(dssoMem.UserId, new set<String>());
                setOldDSSONamesReass = new set<String>();
                setOldDSSONamesReass = mapUserIDToOldDSSONames.get(dssoMem.UserId);
                setOldDSSONamesReass.add(dssoMem.account.Name);
                mapUserIdToOldDSSONames.put(dssoMem.UserId, setOldDSSONamesReass);
                setOldDSSOAndDealerIDs.add(dssoMem.accountId);
                //new change for W-007152
                //multiple DSSOs check - //For story W-007152
                if(!setMemberProcessed.contains(dssoMem.UserId) && 
                ((!dssoMem.user.userrole.name.contains(TFS_Utility.REGION) && dssoMem.user.userrole.name.contains(dssoMem.account.name)) 
                || (dssoMem.user.userrole.name.contains(TFS_Utility.REGION) && dssoMem.user.userrole.name.contains(dssoMem.account.parent.name)))){ //End for story W-007152
                    setMemberProcessed.add(dssoMem.UserId);
                    // Start for #W-007164
                    if(mapDSSONameToGrpNum.containsKey(dssoMem.account.Name) && mapDSSONameToGrpNum.containsKey(mapUserIdToDSSOName.get(dssoMem.UserId)) &&
                    mapDSSONameToGrpNum.get(dssoMem.account.Name) == mapDSSONameToGrpNum.get(mapUserIdToDSSOName.get(dssoMem.UserId))
                    && mapUserIdToRoleName.get(dssoMem.UserId) != TFS_Utility.PM){ // End for #W-007164
                        mapUserIdToOldDSSOName.put(dssoMem.UserId, dssoMem.account.Name);
                        if(!mapUsrIDToTerrAssociations.containsKey(dssoMem.UserId)){
                            UserTerritory2Association uTerr = new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId)));
                            mapUsrIDToTerrAssociations.put(dssoMem.UserId, new list<UserTerritory2Association>{uTerr});
                        }
                        else{
                            lstUTerr = mapUsrIDToTerrAssociations.get(dssoMem.UserId);
                            lstUTerr.add(new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId))));
                            mapUsrIDToTerrAssociations.put(dssoMem.UserId, lstUTerr);
                        }
                        
                        strDSSOs = dssoMem.User.Associated_DSSOs__c;
                        if(strDSSOs != TFS_Utility.BLANK && strDSSOs != null && !strDSSOs.contains(mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase()))
                            strDSSOs += TFS_Utility.SemiColon + mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase();
                        else 
                            strDSSOs = mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase();
                        User u = new User(id = dssoMem.UserId, Associated_DSSOs__c = strDSSOs);
                        mapUsrIDToUsrDetails.put(dssoMem.UserId, u);
                    } 
                    else if(mapUserIdToRegionName.get(dssoMem.UserId) != dssoMem.account.parent.name){
                        mapUserIdToOldDSSOName.put(dssoMem.UserId, dssoMem.account.Name);
                        setProcessedUsers.add(dssoMem.UserID);
                        setProcessedUsersForAccTeam.add(dssoMem.UserID);
                        if(mapASMIDToSetUsrTerrID.containsKey(dssoMem.UserID)){
                            for(ID usrTerrId : mapASMIDToSetUsrTerrID.get(dssoMem.UserID)){
                              if(!setUsrTerrToDelete.contains(usrTerrId)){
                                  lstUsrTerrToDelete.add(new UserTerritory2Association(Id = usrTerrId));
                                  setUsrTerrToDelete.add(usrTerrId);
                              }
                            }
                        }
                        if(mapUserIdToRoleName.get(dssoMem.UserId) != TFS_Utility.REGION_MANAGER){   
                            if(!mapUsrIDToTerrAssociations.containsKey(dssoMem.UserId)){
                                UserTerritory2Association uTerr = new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId)));
                                mapUsrIDToTerrAssociations.put(dssoMem.UserId, new list<UserTerritory2Association>{uTerr});
                            }
                            else{
                                lstUTerr = mapUsrIDToTerrAssociations.get(dssoMem.UserId);
                                lstUTerr.add(new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId))));
                                mapUsrIDToTerrAssociations.put(dssoMem.UserId, lstUTerr);
                            }
                        }
                        if(mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.PM || mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.REGION_MANAGER){
                          strRegionTerrName = mapUserIdToRegionName.get(dssoMem.UserId);
                          if(strRegionTerrName.equalsIgnoreCase(TFS_Utility.NATIONAL))
                            strRegionTerrName += ' Accounts';
                          else if(strRegionTerrName.equalsIgnoreCase('Central') || strRegionTerrName.equalsIgnoreCase('Eastern')
                              || strRegionTerrName.equalsIgnoreCase('Western'))
                          strRegionTerrName += TFS_Utility.BLANK_SPACE + TFS_Utility.REGION;
                          if(mapUsrIDToTerrAssociations.containsKey(dssoMem.UserId) && mapUsrIDToTerrAssociations.get(dssoMem.UserId) != null)
                            lstUTerr = mapUsrIDToTerrAssociations.get(dssoMem.UserId);
                          else
                            lstUTerr = new list<UserTerritory2Association>();
                          lstUTerr.add(new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(strRegionTerrName)));
                            mapUsrIDToTerrAssociations.put(dssoMem.UserId, lstUTerr);
                        }
                        if(dssoMem.user.userrole.name != null && dssoMem.user.userrole.name.containsIgnoreCase(TFS_Utility.REGION)){
                            strRoleName = mapUserIdToRegionName.get(dssoMem.UserId) + ' Region Management';
                        }
                        else if(dssoMem.user.userrole.name != null && !dssoMem.user.userrole.name.containsIgnoreCase(TFS_Utility.REGION) && dssoMem.user.userrole.name.containsIgnoreCase(dssoMem.account.Name)){
                            strRoleName = mapUserIdToDSSOName.get(dssoMem.UserId) + dssoMem.user.userrole.name.substringAfter(dssoMem.account.Name);
                        }
                        
                        //updating the user details
                        strDSSOs = mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase();
                        User u = new User(id = dssoMem.UserId, UserRoleId = mapRoleNameToRoleID.get(strRoleName), Associated_DSSOs__c = strDSSOs);
                        mapUsrIDToUsrDetails.put(dssoMem.UserId, u);
                        if(mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.PM)
                            setPMUsers.add(dssoMem.UserId);
                    }
                    else if(mapUserIdToRegionName.get(dssoMem.UserId) == dssoMem.account.parent.name){ 
                        mapUserIdToOldDSSOName.put(dssoMem.UserId, dssoMem.account.Name); 
                        if(mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.PM || mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.REGION_MANAGER){
                          //updating the user details
                          strDSSOs = mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase();
                          User u = new User(id = dssoMem.UserId, Associated_DSSOs__c = strDSSOs);
                          mapUsrIDToUsrDetails.put(dssoMem.UserId, u);
                        }
                        else if(mapUserIdToRoleName.get(dssoMem.UserId) != TFS_Utility.PM && mapUserIdToRoleName.get(dssoMem.UserId) != TFS_Utility.REGION_MANAGER){
                            if(mapASMIDToSetUsrTerrID.containsKey(dssoMem.UserID) && mapUserIdToRoleName.get(dssoMem.UserId) != TFS_Utility.DSSM){
                              for(ID usrTerrId : mapASMIDToSetUsrTerrID.get(dssoMem.UserID)){
                                if(!setUsrTerrToDelete.contains(usrTerrId)){
                                  lstUsrTerrToDelete.add(new UserTerritory2Association(Id = usrTerrId));
                                  setUsrTerrToDelete.add(usrTerrId);
                                }
                              }
                            }
                            if(!mapUsrIDToTerrAssociations.containsKey(dssoMem.UserId)){
                                UserTerritory2Association uTerr = new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId)));
                                mapUsrIDToTerrAssociations.put(dssoMem.UserId, new list<UserTerritory2Association>{uTerr});
                            }
                            else{
                                lstUTerr = mapUsrIDToTerrAssociations.get(dssoMem.UserId);
                                lstUTerr.add(new UserTerritory2Association(UserID = dssoMem.UserId, Territory2ID = mapTerrNameToID.get(mapUserIdToDSSOName.get(dssoMem.UserId))));
                                mapUsrIDToTerrAssociations.put(dssoMem.UserId, lstUTerr);
                            }
                           
                            if(dssoMem.user.userrole.name != null && dssoMem.user.userrole.name.containsIgnoreCase(TFS_Utility.REGION)){
                                strRoleName = mapUserIdToRegionName.get(dssoMem.UserId) + ' Region Management';
                            }
                            else if(dssoMem.user.userrole.name != null && !dssoMem.user.userrole.name.containsIgnoreCase(TFS_Utility.REGION) && dssoMem.user.userrole.name.containsIgnoreCase(dssoMem.account.Name)){
                                strRoleName = mapUserIdToDSSOName.get(dssoMem.UserId) + dssoMem.user.userrole.name.substringAfter(dssoMem.account.Name);
                            }
                            system.debug('testing2' + mapUserIdToDSSOName.get(dssoMem.UserId));
                            system.debug('testing3' + dssoMem.user.userrole.name.substringAfter(dssoMem.account.Name));
                            system.debug('testing4' + strRoleName);
                            system.debug('testing5' + mapRoleNameToRoleID.get(strRoleName));
                            
                            //updating the user details
                          	strDSSOs = mapUserIdToDSSOName.get(dssoMem.UserId).toUpperCase();
                          	User u = new User(id = dssoMem.UserId, UserRoleId = mapRoleNameToRoleID.get(strRoleName), Associated_DSSOs__c = strDSSOs);
                            mapUsrIDToUsrDetails.put(dssoMem.UserId, u);
                          
                            if(mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.DSM || mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.DSSO_AA ||
                                            mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.DSOM){
                                setProcessedUsers.add(dssoMem.UserID);
                                setProcessedUsersForAccTeam.add(dssoMem.UserID);
                            }
                            else if(mapUserIdToRoleName.get(dssoMem.UserId) == TFS_Utility.DSSM){
                              setProcessedUsers.add(dssoMem.UserID);
                            } 
                        }
                    }
                }  
            }
            
            //new change for W-007152
            //fetching all dealer IDs related to the old DSSO Names
            for(Account dealer : [select id, dsso_name__c from account where recordtype.developername = :TFS_Utility.Account_RecordType
            						and dsso_name__c in :setOldDSSONames]){
            	setOldDSSOAndDealerIDs.add(dealer.Id);
            	mapDSSOorDealerIdToDSSOName.put(dealer.Id, dealer.dsso_name__c);
            }
            //new change for W-007152
            
            //fetching the next person in hierarchy for activities reassignment
            
            mapDSSOToUserID = TFS_Utility.retrieveUserForReassignment(setOldDSSONames, mapUserIdToOldDSSONames); //For story W-007151
            
            //fetching the tasks and events related to the moving ASMs
            for(Task tsk : [select id, ownerid, owner.UserRole.Name, whatId, activitydate from task where status not in :TFS_Utility.setOpenActivityStatus
                            and OwnerID in :setProcessedUsers]){
                if(tsk.whatId != null && tsk.whatId.getSObjectType() == Account.SObjectType){
                    oldOwnerID = tsk.OwnerId;
                    
                    if(dtSchedule1 == null || dtSchedule2 == null){                    	
                    	
                        if(setOldDSSOAndDealerIDs.contains(tsk.whatId) && (tsk.activitydate == null || tsk.activitydate > date.today())){ //new change for W-007152 
                            tsk.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(tsk.whatId)); //new change for W-007152
                            lstTasksToUpdate.add(tsk);
                        }
                        else if(tsk.activitydate <= date.today()){
                            tsk.status = TFS_Utility.COMPLETED;
                            lstTasksToUpdate.add(tsk);
                        }
                    }
                    else if(currentHour < dt3.hour()){
                        if(setOldDSSOAndDealerIDs.contains(tsk.whatId) && (tsk.activitydate == null || tsk.activitydate > dt2.date())){ //new change for W-007152 
                            tsk.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(tsk.whatId)); //new change for W-007152
                            lstTasksToUpdate.add(tsk);
                        }
                        else if(tsk.activitydate <= dt1.date()){ 
                            tsk.status = TFS_Utility.COMPLETED;
                            lstTasksToUpdate.add(tsk);
                        }
                    }
                    else if (currentHour >= dt3.hour()){
                        if(setOldDSSOAndDealerIDs.contains(tsk.whatId) && (tsk.activitydate == null || tsk.activitydate > dt3.date())){ //new change for W-007152 
                            tsk.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(tsk.whatId)); //new change for W-007152
                            lstTasksToUpdate.add(tsk);
                        }
                        else if(tsk.activitydate <= dt2.date()){
                            tsk.status = TFS_Utility.COMPLETED;
                            lstTasksToUpdate.add(tsk);
                        }
                    }
                }
            }
            
            for(Event evt : [select id, ownerId, owner.UserRole.Name, whatId, enddatetime from event 
            				where OwnerID in :setProcessedUsers and whatId in :setOldDSSOAndDealerIDs]){ //new change for W-007152
                if(evt.whatId != null && evt.whatId.getSObjectType() == Account.SObjectType){
                    oldOwnerID = evt.OwnerId;
                    
                    if(dtSchedule1 == null || dtSchedule2 == null){
                        if(evt.enddatetime > system.now()){
                            evt.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(evt.whatId)); //new change for W-007152
                            lstEventsToUpdate.add(evt);
                        }
                    }
                    else if(currentHour < dt3.hour()){
                        if(evt.enddatetime > dt2){
                            evt.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(evt.whatId)); //new change for W-007152
                            lstEventsToUpdate.add(evt);
                        }
                    }
                    else if (currentHour >= dt3.hour()){
                        if(evt.enddatetime > dt3){
                            evt.OwnerId = mapDSSOToUserID.get(mapDSSOorDealerIdToDSSOName.get(evt.whatId)); //new change for W-007152
                            lstEventsToUpdate.add(evt);
                        }
                    }
                }
            }
            
            strAccTeamQuery = 'select id, user.name from AccountTeamMember where ((userID in :setPMUsers) OR (userID in :setProcessedUsersForAccTeam ';
            strAccTeamQuery += 'and teammemberrole != \'Product Manager\')) ';
            if(dtSchedule1 == null || dtSchedule2 == null)
                strAccTeamQuery += 'and createddate < today';
            else if(currentHour < dt3.hour())
                strAccTeamQuery += 'and (createddate < :dt1)';
            else if (currentHour >= dt3.hour())
                strAccTeamQuery += 'and (createddate < :dt2)';
            lstAccTeamMemberToDelete = Database.query(strAccTeamQuery);
            if(!lstTasksToUpdate.isEmpty())
                Database.SaveResult[] resultsUpdateTasks = Database.update(lstTasksToUpdate, false); 
            if(!lstEventsToUpdate.isEmpty())
                Database.SaveResult[] resultsUpdateEvents = Database.update(lstEventsToUpdate, false);
            
            /*if(!lstPMAccTeamMemberToDelete.isEmpty())
                Database.DeleteResult[] resultsDeleteAccTeamPM = Database.delete(lstPMAccTeamMemberToDelete, false);
            if(!lstAccTeamMemberToDelete.isEmpty())
                Database.DeleteResult[] resultsDeleteAccTeam = Database.delete(lstAccTeamMemberToDelete, false);
            */
            
            //inserting new dealer team members
            if(!lstDealerMemToInsert.isEmpty()){
                Database.SaveResult[] resultsInsertDealerMem = Database.insert(lstDealerMemToInsert, false);
                errLog = new Error_Log__c();
            }
            
        }
        catch (Exception err){
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'AccountTeam_DSSOMemAssignBatch', Log_Message__c = TFS_Utility.SFDC_LOG+err.getStackTraceString()+TFS_Utility.LINE+err.getLineNumber(), Log_Type__c = 'Apex Trigger' , Log_Severity__c = TFS_Utility.HIGH); 
            if(errLog!=null && Limits.getDmlRows() < Limits.getLimitDmlRows())
            	insert errLog;
        }
    }
    //Calling another batch to update user role and territory when this job gets finished    
    global void finish(Database.BatchableContext BC) {
        if(!mapUsrIDToTerrAssociations.isEmpty())
            Database.executeBatch(new User_RoleAndTerritoryUpdateBatch(mapUsrIDToTerrAssociations, mapUsrIDToUsrDetails, lstUsrTerrToDelete));
    }
    
}