/**************************************************************************************************************************************************
* Class Name: DealerObjVariancePageCustControllerTest
* Author: Deloitte
* Date: [04/05/2017]
* Requirement Description:  User story W-004133
* Date Modified                Modified By                  Description of the update
* 6th June 2017                Bhargavaramu (Deloitte)       created mehtods to cover the new code    
***************************************************************************************************************************************************/
@isTest
private class DealerObjVariancePageCustControllerTest{
    static testMethod void unitTest1(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '674500';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
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
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','455436567', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','656543', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
        
            FinancialYear__c fy = TestUtility.createFinancialYear();
            if(fy != null){
                insert fy;
            }
            system.assert(fy.id != null);
            
            List<Product__c> prodList = TestUtility.createProducts();
            if(prodList != null && prodList.size() > 0){
                insert prodList;
            }
            system.assert(prodList.size() > 0);
            
            String cYear;
            if(System.today().month()>3){
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
            }else{
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
            }

            string cMonth = datetime.now().format(TFS_Utility.MMM).substring(0,3);
            
            //creating DSSO & Dealer Level Objectives
            List<product_Objective__c> dssoObjList = TestUtility.createDSSOObjectives(prodList,dssoAcnt, cYear,'In Progress', cMonth);
            if(dssoObjList != null && dssoObjList.size() > 0){
                insert dssoObjList;
            }
            system.assert(dssoObjList.size() > 0);
         
         
            List<product_Objective__c> dealerObjList = TestUtility.createDealerObjectives(prodList,dssoObjList, dealerList, cYear,'In Progress');
            if(dealerObjList != null && dealerObjList.size() > 0){
                insert dealerObjList;
            }
            system.assert(dealerObjList.size() > 0);
            
            Account TFSAreaNumber = [select TFS_Area_Number__c from account where id = :dealerList[0].id];
           
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<SelectOption> yrs = con.years;
            con.getMonthList();
            List<SelectOption> cat = con.categories;
            con.getRegionList();
            con.selectedYear = cYear;  
            con.selectedMonth = cMonth;
            con.category = 'Insurance';
            con.selectedRegion = regionAcc.Id;
            con.getDssoList();
            con.selectedDsso = dssoAcnt.Name;
            con.getTFSAreaNumberList();
            con.selectedTfsAreaNumber = TFSAreaNumber.TFS_Area_Number__c;
            con.selectPicklistVal();
            con.editObjectives();
            con.calculate();
            con.saveObjectives();
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest2(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '8566500';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '6978078';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '697807778';
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
            
            //Creating Account Data
            List<Account> dealerList = new List<Account>();
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','35634456', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','63455654', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
        
            FinancialYear__c fy = TestUtility.createFinancialYear();
            if(fy != null){
                insert fy;
            }
            system.assert(fy.id != null);
            
            List<Product__c> prodList = TestUtility.createProducts();
            if(prodList != null && prodList.size() > 0){
                insert prodList;
            }
            system.assert(prodList.size() > 0);
            
            String cYear;
            if(System.today().month()>3){
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
            }else{
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
            }

            string cMonth = datetime.now().format(TFS_Utility.MMM).substring(0,3);
            
            //creating DSSO & Dealer Level Objectives
            List<product_Objective__c> dssoObjList = TestUtility.createDSSOObjectives(prodList,dssoAcnt, cYear,'In Progress', cMonth);
            if(dssoObjList != null && dssoObjList.size() > 0){
                insert dssoObjList;
            }
            system.assert(dssoObjList.size() > 0);
            
            List<product_Objective__c> dealerObjList = TestUtility.createDealerObjectives(prodList,dssoObjList, dealerList, cYear,'In Progress');
            if(dealerObjList != null && dealerObjList.size() > 0){
                insert dealerObjList;
            }
            system.assert(dealerObjList.size() > 0);
            
            Account TFSAreaNumber = [select TFS_Area_Number__c from account where id = :dealerList[0].id];
           
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<SelectOption> yrs = con.years;
            con.getMonthList();
            List<SelectOption> cat = con.categories;
            con.getRegionList();
            con.selectedYear = cYear;  
            con.selectedMonth = cMonth;
            con.category = 'Insurance';
            con.selectedRegion = regionAcc.Id;
            con.getDssoList();
            con.selectedDsso = dssoAcnt.Name;
            con.getTFSAreaNumberList();
            con.selectedTfsAreaNumber = 'All';
            con.selectPicklistVal();
            con.submitObjectives();
            con.editObjectives();
            con.saveObjectives();
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest3(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '65600';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '69780777876';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '697807778';
            dssoAcnt.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt != null){
                insert dssoAcnt;
            }
            Account dssoAcnt1 = new Account();
            dssoAcnt1.Type = 'DSSO';
            dssoAcnt1.ParentId = regionAcc.Id;
            dssoAcnt1.Name = 'KANSAS CITY';
            dssoAcnt1.AccountNumber = '6978027876';
            dssoAcnt1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt1 != null){
                insert dssoAcnt1;
            }
            system.assert(dssoAcnt1.id != null);
            
            TFS_Area__c tfsA = TestUtility.createTFSArea(dssoAcnt.Name,'02');
            if(tfsA != null){
                insert tfsA;
            }
            system.assert(tfsA.id != null);
            
            //Creating Account Data
            List<Account> dealerList= new List<Account>();
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','6345987', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','563454897', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
         
            FinancialYear__c fy = TestUtility.createFinancialYear();
            if(fy != null){
                insert fy;
            }
            system.assert(fy.id != null);
            
            List<Product__c> prodList = TestUtility.createProducts();
            if(prodList != null && prodList.size() > 0){
                insert prodList;
            }
            system.assert(prodList.size() > 0);
            
            String cYear;
            if(System.today().month()>3){
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
            }else{
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
            }

            string cMonth = datetime.now().format(TFS_Utility.MMM).substring(0,3);
            
            //creating DSSO & Dealer Level Objectives
            List<product_Objective__c> corpObjList = TestUtility.createCorpObjectives(prodList,companyAcc, cYear,'In Progress', cMonth);
            if(corpObjList != null && corpObjList.size() > 0){
                insert corpObjList;
            }
            system.assert(corpObjList.size() > 0);
            
            List<product_Objective__c> regionObjList = TestUtility.createRegionObjectives(prodList,regionAcc, cYear,'In Progress', cMonth);
            if(regionObjList != null && regionObjList.size() > 0){
                regionObjList[0].product_objective__c = corpObjList[0].id;
                regionObjList[1].product_objective__c = corpObjList[1].id;
                insert regionObjList;
            }
            system.assert(regionObjList.size() > 0);
            
            List<product_Objective__c> dssoObjList = TestUtility.createDSSOObjectives(prodList,dssoAcnt, cYear,'In Progress', cMonth);
            if(dssoObjList != null && dssoObjList.size() > 0){
                dssoObjList[0].product_objective__c = regionObjList[0].id;
                dssoObjList[1].product_objective__c = regionObjList[1].id;
                insert dssoObjList;
            }
            system.assert(dssoObjList.size() > 0);
            
            List<product_Objective__c> dealerObjList = TestUtility.createDealerObjectives(prodList,dssoObjList, dealerList, cYear,'In Progress');
            if(dealerObjList != null && dealerObjList.size() > 0){
                dealerObjList[0].product_objective__c = dssoObjList[0].id;
                dealerObjList[1].product_objective__c = dssoObjList[1].id;
                insert dealerObjList;
            } 
            system.assert(dealerObjList.size() > 0);
           
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<SelectOption> yrs = con.years;
            con.getMonthList();
            List<SelectOption> cat = con.categories;
            con.getRegionList();
            con.selectedYear = cYear;  
            con.selectedMonth = cMonth;
            con.category = 'Insurance';
            con.selectedRegion = regionAcc.Id;
            con.getDssoList();
            con.selectedDsso = 'All';

            con.selectPicklistVal();
            con.editObjectives();
            con.cancel();
            con.editObjectives();
            con.calculate();
            con.saveObjectives();
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest3_1(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '5634600';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '6978027876';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '697802786776';
            dssoAcnt.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt != null){
                insert dssoAcnt;
            }
            Account dssoAcnt1 = new Account();
            dssoAcnt1.Type = 'DSSO';
            dssoAcnt1.ParentId = regionAcc.Id;
            dssoAcnt1.Name = 'KANSAS CITY';
            dssoAcnt1.AccountNumber = '69780876';
            dssoAcnt1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt1 != null){
                insert dssoAcnt1;
            }
            system.assert(dssoAcnt1.id != null);
            
            TFS_Area__c tfsA = TestUtility.createTFSArea(dssoAcnt.Name,'02');
            if(tfsA != null){
                insert tfsA;
            }
            system.assert(tfsA.id != null);
            
            //Creating Account Data
            List<Account> dealerList= new List<Account>();
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','6543789', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','567890', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
        
            FinancialYear__c fy = TestUtility.createFinancialYear();
            if(fy != null){
                insert fy;
            }
            system.assert(fy.id != null);
            
            List<Product__c> prodList = TestUtility.createProducts();
            if(prodList != null && prodList.size() > 0){
                insert prodList;
            }
            system.assert(prodList.size() > 0);
            
            String cYear;
            if(System.today().month()>3){
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
            }else{
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
            }

            string cMonth = datetime.now().format(TFS_Utility.MMM).substring(0,3);
            
            //creating DSSO & Dealer Level Objectives
            List<product_Objective__c> corpObjList = TestUtility.createCorpObjectives(prodList,companyAcc, cYear,'In Progress', cMonth);
            if(corpObjList != null && corpObjList.size() > 0){
                insert corpObjList;
            }
            system.assert(corpObjList.size() > 0);
            
            List<product_Objective__c> regionObjList = TestUtility.createRegionObjectives(prodList,regionAcc, cYear,'In Progress', cMonth);
            if(regionObjList != null && regionObjList.size() > 0){
                regionObjList[0].product_objective__c = corpObjList[0].id;
                regionObjList[1].product_objective__c = corpObjList[1].id;
                insert regionObjList;
            }
            system.assert(regionObjList.size() > 0);
            
            List<product_Objective__c> dssoObjList = TestUtility.createDSSOObjectives(prodList,dssoAcnt, cYear,'In Progress', cMonth);
            if(dssoObjList != null && dssoObjList.size() > 0){
                dssoObjList[0].product_objective__c = regionObjList[0].id;
                dssoObjList[1].product_objective__c = regionObjList[1].id;
                insert dssoObjList;
            }
            system.assert(dssoObjList.size() > 0);
            
            List<product_Objective__c> dealerObjList = TestUtility.createDealerObjectives(prodList,dssoObjList, dealerList, cYear,'In Progress');
            if(dealerObjList != null && dealerObjList.size() > 0){
                dealerObjList[0].product_objective__c = dssoObjList[0].id;
                dealerObjList[1].product_objective__c = dssoObjList[1].id;
                insert dealerObjList;
            } 
            system.assert(dealerObjList.size() > 0);
           
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<SelectOption> yrs = con.years;
            con.getMonthList();
            List<SelectOption> cat = con.categories;
            con.getRegionList();
            con.selectedYear = cYear;  
            con.selectedMonth = cMonth;
            con.category = 'Insurance';
            con.selectedRegion = 'Corporate All';
            con.getDssoList();
            con.selectedDsso = 'All';

            con.selectPicklistVal();
            con.editObjectives();
            con.cancel();
            con.editObjectives();
            con.calculate();
            con.saveObjectives();
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest4(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '634500';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '6978027876';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '69027876';
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
            
            //Creating Account Data
            List<Account> dealerList = new List<Account>();
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','563432', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','676321', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
        
            
            FinancialYear__c fy = TestUtility.createFinancialYear();
            if(fy != null){
                insert fy;
            }
            system.assert(fy.id != null);
            
            List<Product__c> prodList = TestUtility.createProducts();
            if(prodList != null && prodList.size() > 0){
                insert prodList;
            }
            system.assert(prodList.size() > 0);
            
            String cYear;
            if(System.today().month()>3){
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
            }else{
                cYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
            }

            string cMonth = datetime.now().format(TFS_Utility.MMM).substring(0,3);
            
            //creating DSSO & Dealer Level Objectives
            List<product_Objective__c> dssoObjList = TestUtility.createDSSOObjectives(prodList,dssoAcnt, cYear,'In Progress', cMonth);
            if(dssoObjList != null && dssoObjList.size() > 0){
                insert dssoObjList;
            }
            system.assert(dssoObjList.size() > 0);
            
            List<product_Objective__c> dealerObjList = TestUtility.createDealerObjectives(prodList,dssoObjList, dealerList, cYear,'In Progress');
            if(dealerObjList != null && dealerObjList.size() > 0){
                insert dealerObjList;
            } 
            system.assert(dealerObjList.size() > 0);
           
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<SelectOption> yrs = con.years;
            con.getMonthList();
            List<SelectOption> cat = con.categories;
            con.getRegionList();
            con.selectedYear = cYear;  
            con.selectedMonth = cMonth;
            con.category = 'Insurance';
            con.selectedRegion = regionAcc.Id;
            con.getDssoList();
            con.selectedDsso = 'All';

            con.selectPicklistVal();
            con.submitObjectives();
            con.editObjectives();
            con.saveObjectives();
            
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest5(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account acnt1 = new Account();
            acnt1.Type = 'Region';
            acnt1.Name = 'Central';
            acnt1.AccountNumber = '6978027876';
            acnt1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(acnt1 != null){
                insert acnt1;
            }
            system.assert(acnt1.id != null);
            
            PageReference pageRef = Page.DealerObjVariancePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('isExport','true');
            ApexPages.currentPage().getParameters().put('year', 'FY18');
            ApexPages.currentPage().getParameters().put('month', 'Dec');
            ApexPages.currentPage().getParameters().put('category','Insurance Objective');
            ApexPages.currentPage().getParameters().put('Region',acnt1.Id);
            ApexPages.currentPage().getParameters().put('DSSO','All');
            ApexPages.currentPage().getParameters().put('TFSArea','0');
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            con.selectedRegion = 'Corporate All';
            con.selectedDSSO = 'ALL';
            con.setValuesforExcelPDF();
            Test.stopTest(); 
        }
    }
    static testMethod void unitTest6(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account acnt1 = new Account();
            acnt1.Type = 'Region';
            acnt1.Name = 'Central';
            acnt1.AccountNumber = '6978027876';
            acnt1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(acnt1 != null){
                insert acnt1;
            }
            system.assert(acnt1.id != null);
            
            PageReference pageRef = Page.DealerObjVariancePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('isExport','true');
            ApexPages.currentPage().getParameters().put('year', 'FY18');
            ApexPages.currentPage().getParameters().put('month', 'Dec');
            ApexPages.currentPage().getParameters().put('category','Insurance Objective');
            ApexPages.currentPage().getParameters().put('Region','Corporate All');
            ApexPages.currentPage().getParameters().put('DSSO','All');
            ApexPages.currentPage().getParameters().put('TFSArea','0');
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            con.selectedRegion = 'Corporate All';
            con.selectedDSSO = 'ALL';
            con.setValuesforExcelPDF();
            Boolean b = con.isEdit;
            Boolean b1 = con.isRendered;
            Boolean b2 = con.isRenderSummary;
            Boolean b3 = con.isSummary;
            Boolean b4 = con.isComplete;
            con.category = 'Insurance Objective';
            con.selectedCategory = 'Insurance Objective';
            
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest7(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account acnt1 = new Account();
            acnt1.Type = 'Region';
            acnt1.Name = 'Central';
            acnt1.AccountNumber = '6978027876';
            acnt1.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(acnt1 != null){
                insert acnt1;
            }
            system.assert(acnt1.id != null);
            
            PageReference pageRef = Page.DealerObjVariancePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('isExport','true');
            ApexPages.currentPage().getParameters().put('year', 'FY18');
            ApexPages.currentPage().getParameters().put('month', 'Dec');
            ApexPages.currentPage().getParameters().put('category',null);
            ApexPages.currentPage().getParameters().put('Region',acnt1.id);
            ApexPages.currentPage().getParameters().put('DSSO','All');
            ApexPages.currentPage().getParameters().put('TFSArea','Summary');
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            con.init();
            
            Test.stopTest(); 
        }
    }

    static testMethod void unitTest8(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
             Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '763400';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '6978027876';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '697845027876';
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
            
            //Creating Account Data
            List<Account> dealerList = new List<Account>();
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','176234', tfsA));
            dealerList.add(TestUtility.createAccount('dssoAcnt.Name','185623', tfsA));
            if(dealerList!=null && !dealerList.isEmpty()){
                insert dealerList;
            }
            system.assert(dealerList.size() == 2);
        
            PageReference pageRef = Page.DealerObjVariancePage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('year', 'FY18');
            ApexPages.currentPage().getParameters().put('month', 'Dec');
            ApexPages.currentPage().getParameters().put('category','Insurance Objective');
            ApexPages.currentPage().getParameters().put('Region','Corporate All');
            ApexPages.currentPage().getParameters().put('DSSO','All');
            ApexPages.currentPage().getParameters().put('TFSArea','1');
            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            con.selectedRegion = 'Corporate All';
            con.selectedDsso = 'All';
            con.pdfButton();
            con.excelButton();
            con.getAreaNumberList();
            Test.stopTest(); 
        }
    }
    
    static testMethod void unitTest9(){
        Profile pr= [select Id from Profile where name='System Administrator']; 
        User u = TestUtility.createUser(pr.id);
        if(u != null){
            insert u;
        } 
        system.assert(u.id != null);
        
        system.runas(u){
            Test.startTest();
            Account companyAcc = new Account();
            companyAcc.Type = 'Company';
            companyAcc.Name = 'TFS';
            companyAcc.AccountNumber = '85600';
            companyAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(companyAcc != null){
                insert companyAcc;
            }
            system.assert(companyAcc.id != null);
            
            Account regionAcc = new Account();
            regionAcc.Type = 'Region';
            regionAcc.Name = 'Central';
            regionAcc.parentId = companyAcc.Id;
            regionAcc.AccountNumber = '69727876';
            regionAcc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(regionAcc != null){
                insert regionAcc;
            }
            system.assert(regionAcc.id != null);
            
            Account dssoAcnt = new Account();
            dssoAcnt.Type = 'DSSO';
            dssoAcnt.ParentId = regionAcc.Id;
            dssoAcnt.Name = 'DALLAS';
            dssoAcnt.AccountNumber = '697876027876';
            dssoAcnt.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Location').RecordTypeId;
            if(dssoAcnt != null){
                insert dssoAcnt;
            }
            system.assert(dssoAcnt.id != null);
            
            PageReference pageRef = Page.DealerObjVariancePage;
            Test.setCurrentPage(pageRef);

            DealerObjVariancePageCustController con = new DealerObjVariancePageCustController();
            List<Product_objective__c> prObjList = new  List<Product_objective__c>();
            Product_objective__c prod = new Product_objective__c();
            prod.account__c = u.id; //Negative scenario
            prObjList.add(prod);
            con.allobjectives = prObjList ;
            con.saveObjectives();
            con.submitObjectives();
            con.selectedregion = u.id;
            con.selectedTfsAreaNumber = '00';
            con.setValuesforExcelPDF();
            con.selectedRegion = 'All Region';
            con.getDssoList();
          
            Test.stopTest(); 
        }
    }
}