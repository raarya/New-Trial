/********************************************************************************************
* Class Name: DealerObjVariancePageCustController
* Author: (Deloitte)
* Date: [03/29/2017]
* Requirement Description:W-004133: 
* Date Modified                Modified By                  Description of the update
  30th May 2017              Bhargavaramu(Deloitte)         Bug fix and enhancement
  12th June 2017             Bhargavaramu(Deloitte)         Story: 5599
  19th June 2017             Bhargavaramu(Deloitte)         Story: 5895
***********************************************************************************************/
public class DealerObjVariancePageCustController{
    
    // key: region and value: DSSOSet
    public Map<String,Set<String>> regionsDSSOMap = new Map<String,Set<String>>();
    public List<CorporateWrapper> corporateList{get;set;} // it holds region objectives. Added by Bhargavaramu story:5599
    public List<RegionWrapper> regions{get;set;} //it holds DSSO objectives
    public List<TFSAreaWrapper> TFSAreas {get; set;} //it holds dealer objectives
    
    public List<TotalWrapper> summaryTotalWrapper {get;set;} //it holds variance info
    public List<String> productList {get;set;} // It holds active prodcuts
    public Map<String,string> productMap { get; set; } // It holds active products
    public Product_Objective__c dssoTfsMfd{get;set;} // It holds latest objective
    
    public List<Product_Objective__c> allObjectives {get;set;} //It holds all objectives based on filter selection
    
    //Filter variables
    public String selectedMonth {get;set;}
    public string selectedYear {get;set;}
    public string selectedCategory {get;set;}
    public String selectedregion{get;set;} 
    public String selectedDsso {get;set;}
    public String selectedTfsAreaNumber {get;set;}
    
    //Declaring variables
    public Boolean isRegionSum {get;set;} 
    public User usr { get; set; }
    public String category {get;set;} 
    public Boolean noAction {get;set;}
    public String pageTitle { get; set;} 
    private List<String> tfsAreaList{ get;set;}
    Set<String> SetTFSAreaNumber = new Set<String>();
    public Integer numberOfProducts { get; set; } 
    public Decimal colWidth { get; set; }    // Used in CSS file     
    private static String isActive = TFS_Utility.ACTIVE;
       
    public Set<String> tfsrelationshipSet;
    public Set<String> validRoles;
    
    //Fields added by Bhargavaramu for story: 5895
    public Boolean isVarBlock{get;set;}
    public Boolean isEditButtonDisplay{get;set;}
    public Boolean isSubmitButtonDisplay{get;set;}
    public string statusLabel{get;set;}
    public string objStatus{get;set;}
    
    public String RegionName {get;set;}
    
    public Boolean isEdit { get { 
        if (isEdit == null) {
            isEdit = false;
        }        
        return isEdit ;
    } private set; }     
    public Boolean isCalculate { get { 
        if (isCalculate == null) {
            isCalculate = false;
        }        
        return isCalculate ;
    } private set; }    
   
    public Boolean isRendered { get { 
        if (isRendered == null) {
            isRendered = false;
        }        
        return isRendered ;
    } private set; }    
    public Boolean isRenderSummary { get { 
        if (isRenderSummary == null) {
            isRenderSummary = false;
        }        
        return isRenderSummary ;
    } private set; }    
    public Boolean isSummary { get { 
        if (isSummary == null) {
            isSummary = false;
        }        
        return isSummary ;
    } private set; }    
    public Boolean hasVariance { get { 
        if (hasVariance == null) {
            hasVariance = false;
        }        
        return hasVariance ;
    } private set; }    
    public Boolean isComplete { get { 
        if (isComplete == null) {
            isComplete = false;
        }        
        return isComplete ;
    } private set; }    
    
    //Constructor 
    public DealerObjVariancePageCustController() {        
        //Set default values
        setDefaultValues();
        
        isVarBlock = false;
        isEditButtonDisplay = false;
        isSubmitButtonDisplay = false;
        statusLabel = TFS_Utility.STATUS;        
        noAction = false;
        
        //Intiation
        allObjectives = new  List<Product_Objective__c>();
        
        String isExport = ApexPages.currentPage().getParameters().get(TFS_Utility.ISEXPORT);
        // Check if Export/Print is invoked
        if( isExport != NULL 
              && isExport == TFS_Utility.TRUE_FLAG){
            
            //Get values from parameters
            selectedYear  = ApexPages.currentPage().getParameters().get(TFS_Utility.YEAR);
            selectedMonth = ApexPages.currentPage().getParameters().get(TFS_Utility.MONTH);
            selectedCategory =ApexPages.currentPage().getParameters().get(TFS_Utility.CATEGORY);
            category =ApexPages.currentPage().getParameters().get(TFS_Utility.CATEGORY);
            selectedregion=  ApexPages.currentPage().getParameters().get(TFS_Utility.REGION);
            selectedDsso=  ApexPages.currentPage().getParameters().get(TFS_Utility.DSSO);
            selectedTfsAreaNumber = ApexPages.currentPage().getParameters().get(TFS_Utility.TFSAREA);

            if(category != null){
               category = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               selectedCategory = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               category = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               selectedCategory = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               category = category.trim();
               selectedCategory = selectedCategory.trim();
            }
            else{
               category = TFS_Utility.INSURANCE;
               selectedCategory = TFS_Utility.INSURANCE;
            }
            
            //Get active products based on product dependent picklist
            productList = getActiveProducts();
            numberOfProducts = productList.size();
            colWidth = getColumnWidth(numberOfProducts);
            
            //set values for Excel and PDF
            //setValuesforExcelPDF();
            getTFSAreaNumberList();
            selectPicklistVal();

            List<Account> acList = [SELECT Id,Name FROM Account WHERE Id =:selectedregion];
            if(acList!= NULL && !acList.isEmpty()){
                RegionName = acList[0].Name;
            }else{
                RegionName = TFS_Utility.BLANK;
            }
        }
    }
    
    // Init method
    public void init() {
        try {
            selectedDsso = TFS_Utility.ZERO;
            selectedTfsAreaNumber = TFS_Utility.ZERO;
            if(category !=null){
                category = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
            }else{
                category = TFS_Utility.INSURANCE;
            }
            Integer currentYear = System.Today().year();
            pageTitle = TFS_Utility.TFS+TFS_Utility.BLANK_SPACE+ category.toUpperCase() +TFS_Utility.BLANK_SPACE+TFS_Utility.DEALER_OBJECTIVES+TFS_Utility.BLANK_SPACE+selectedYear ;            
            
            productList = getActiveProducts();        
            numberOfProducts = productList.size();
            colWidth = getColumnWidth(numberOfProducts);       
        } 
        catch (Exception e){
           PageMessageUtils.error(e);
        } 
    }
    
    // Method to preset default values based on selected Region. 
    //Method was modified for the story: 5895 and 5599
    public void selectPicklistVal(){
        isEdit = false;          
        isVarBlock = false;  
        isEditButtonDisplay = false; 
        isSubmitButtonDisplay = false;  
        isSummary = false;
        isRendered = false;
        isRegionSum = false;
                   
        if(selectedCategory != null){
               category = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               category = selectedCategory.replace(TFS_Utility.OBJECTIVE,TFS_Utility.BLANK);
               category = category.trim();
        }else{
            category = TFS_Utility.INSURANCE;
        }  
        
        productList = getActiveProducts();
        numberOfProducts = productList.size();
        colWidth = getColumnWidth(numberOfProducts);  
         
        pageTitle = TFS_Utility.TFS+TFS_Utility.BLANK_SPACE+ category.toUpperCase() + TFS_Utility.BLANK_SPACE+TFS_Utility.DEALER_OBJECTIVES+TFS_Utility.BLANK_SPACE+selectedYear ;        
        
        try {  
            if (!(new Set<String>{TFS_Utility.ZERO,TFS_Utility.ALL, TFS_Utility.SUMMARY}).contains(selectedDsso)){
                tfsAreaList  = new List<String>(SetTFSAreaNumber);
            }
            if(selectedRegion == TFS_Utility.CORPORATE_ALL){  
                selectedDsso = TFS_Utility.ALL;
                selectedTfsAreaNumber = TFS_Utility.ZERO;
                isRendered = true;                 
                isRegionSum = true;  
                
                loadDSSOObjectives();
                regions = retrieveRegions();  
                CorporateList = retrieveCorporateObjectives();
                
                statusLabel = TFS_Utility.CORPORATE+TFS_Utility.BLANK_SPACE+TFS_Utility.STATUS; 
            }  
            else if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                selectedDsso = TFS_Utility.ZERO;
                selectedTfsAreaNumber = TFS_Utility.ZERO;
                isRendered = true;
                isRegionSum = true;   
                isVarBlock = true;
                statusLabel = TFS_Utility.CORPORATE+TFS_Utility.BLANK_SPACE+TFS_Utility.STATUS;
                
                CorporateList = retrieveCorporateObjectives(); 
                if(!CorporateList.isEmpty()){
                    if(validRoles.contains(usr.TFS_SRM_Title__c)){
                        isEditButtonDisplay = true;
                        isSubmitButtonDisplay = true;
                    }              
                }
            }        
            else if(selectedDsso == TFS_Utility.ALL && selectedRegion != TFS_Utility.ALL_REGION){               
                selectedTfsAreaNumber = TFS_Utility.ZERO;
                isRendered = true;
                isRegionSum = true;                 
                statusLabel = TFS_Utility.REGION+TFS_Utility.BLANK_SPACE+TFS_Utility.STATUS; 
                
                loadDSSOObjectives();
                regions = retrieveRegionObjectives();
                if(regions != null && !regions.isEmpty()){
                    if(validRoles.contains(usr.TFS_SRM_Title__c)){
                        isEditButtonDisplay = true;
                        isSubmitButtonDisplay = true;
                    }      
                    isVarBlock = true;
                }      
            }
            else{              
              loadObjectives();              
              statusLabel = TFS_Utility.DSSO+TFS_Utility.BLANK_SPACE+TFS_Utility.STATUS;
            }
            
            //Get latest objective record
            setObjectiveStatus();
            
            if (selectedTfsAreaNumber == TFS_Utility.ZERO){
                //
            }
            else if (selectedTfsAreaNumber == TFS_Utility.SUMMARY) {
                isRendered = true;
                isRenderSummary = true;
                isSummary = true;   
            } 
            else {
                isRendered = true;
                isSummary = false;
            }          
        } catch (Exception err) {
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'DealerObjVariancePageCustController ', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex' , Log_Severity__c = 'HIGH') ; 
            insert errLog;
            PageMessageUtils.error(err);
        }
    } 
    
    //Setting default values. 
    //Create new method to store default values. story: 5599 and 5895
    public void setDefaultValues(){
        //Logged in user details
        usr =[select TFS_SRM_Title__c  from user where id =:userinfo.getuserid()];
        
        //Selected Year 
        if(System.today().month()>3){
            selectedYear = TFS_Utility.FY + String.valueOf(System.today().year()+1).right(2);
        }else{
            selectedYear = TFS_Utility.FY + String.valueOf(System.today().year()).right(2);
        }
        
        //Selected Month
        selectedMonth = datetime.now().format(TFS_Utility.MMM);
        
        //Selected Category
        category = TFS_Utility.INSURANCE;
        selectedCategory = TFS_Utility.INSURANCE;
        
        tfsrelationshipSet = new Set<String>();
        List<Schema.PicklistEntry> pValList = Account.TFS_Relationship__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry pv : pValList){
              if(pv.getValue().indexOf(TFS_Utility.INSURANCE) != -1){
                 tfsrelationshipSet.add(pv.getValue());
            }
        }
        validRoles = new Set<String>();
        validRoles.addAll(Label.Authorized_Titles_to_Edit_Objectives_InProgress.split(','));
    }
    
    // Set list of categories
    public List<SelectOption> categories{
        get {            
            List<SelectOption> options = new List<SelectOption>();
            List<Schema.PicklistEntry> pValList = Product__c.Type__c.getDescribe().getPicklistValues();
             for( Schema.PicklistEntry pv : pValList){
                   options.add(new SelectOption(pv.getValue()+TFS_Utility.BLANK_SPACE+TFS_Utility.OBJECTIVE,pv.getValue()+TFS_Utility.BLANK_SPACE+TFS_Utility.OBJECTIVE));
             }
            return options;
        } 
        set;
    }
    
    //Set column width
    public static Decimal getColumnWidth(Integer numberOfProducts) {
        // totalWidth = 100 - 9 (DSSO Name width) - 7 (DSSO Number width)
        Decimal totalWidth = 84;
        // colWidth = Total number of products x 2 (for Plan and Stretch) + 3 (Total Plan, Total Stretch, Total NVS columns)
        Decimal colWidth = totalWidth.divide(Decimal.valueOf((numberOfProducts*2)+3), 3);        
        return colWidth;
    } 

    // Method to load Dealer objectives
    //Method was modified for the story: 5599 and 5895
    public void loadObjectives() {
        try {
            loadDealerObjectives(); // Load dealer objectives
            tfsAreas = retrieveTFSAreas(); //Fetching tfs areas
            IF(selectedTfsAreaNumber != TFS_Utility.ZERO && selectedTfsAreaNumber != TFS_Utility.ALL 
                                                         && selectedTfsAreaNumber != TFS_Utility.SUMMARY 
                                                         && !tfsAreas.isEmpty()){
                if(validRoles.contains(usr.TFS_SRM_Title__c)){
                    isEditButtonDisplay = true;
                }
            } 
            else{
                isEditButtonDisplay = false;
            }
            
            if(validRoles.contains(usr.TFS_SRM_Title__c) && selectedTfsAreaNumber == TFS_Utility.ALL 
                                                         && !tfsAreas.isEmpty()){
                isSubmitButtonDisplay = true;
            }   
            else{
                isSubmitButtonDisplay = false;
            }      
        } catch (Exception err) {
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = 'DealerObjVariancePageCustController ', Log_Message__c = 'SFDC__LOG: '+err.getStackTraceString()+' Line: '+err.getLineNumber(), Log_Type__c = 'Apex' , Log_Severity__c = 'HIGH') ; 
            insert errLog;
            PageMessageUtils.error(err);
        }
    } 
    
    // Load DSSO Objectives
     public void loadDSSOObjectives() {
        Map<Id,Account> regionAccountMap = new Map<Id, Account>([SELECT Id,Name FROM Account WHERE Type =:TFS_Utility.REGION]);
        Set<Id> regionSelectedSet = new Set<Id>();
        
        if(selectedregion == TFS_Utility.CORPORATE_ALL || selectedregion == TFS_Utility.NATIONAL 
                                                       || selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
          regionSelectedSet.addAll(regionAccountMap.keySet());
        }
        else{
          regionSelectedSet.add(selectedregion);
        }
        
        //Preparing region DSSO Map
        for(Account ac :[SELECT Id,Name,parent.name, type, parent.type FROM Account where parent.type = :TFS_Utility.REGION AND type = :TFS_Utility.DSSO AND ParentId=: regionSelectedSet]){
            string parentAccName = ac.parent.name;
            if(regionsDSSOMap != NULL && regionsDSSOMap.containskey(parentAccName) 
                                      && regionsDSSOMap.get(parentAccName) != NULL){
              Set<String> temp = new Set<String>();
              temp = regionsDSSOMap.get(parentAccName);
              temp.add(ac.Name);
              regionsDSSOMap.put(parentAccName,temp);
            }
            else{
                Set<String> temp = new Set<String>();
                temp.add(ac.Name);
                regionsDSSOMap.put(parentAccName,temp);
            }
        }
    }
    
    // Load dealer objectives
    private void loadDealerObjectives() {
        Map<string,product_objective__c> dealMap = new Map<string,product_objective__c>(
                                                        [SELECT id,Name,Fiscal_Year__c,Month__c,Product__c,
                                                            Product_Objective__c FROM Product_Objective__c 
                                                            WHERE type__c = :TFS_Utility.DSSO 
                                                            AND account__r.name=:selectedDsso 
                                                            AND Month__c=:selectedMonth 
                                                            AND Fiscal_Year__c =:selectedYear 
                                                            And Name in :productList]); 
        set<string> dealIdSet = new set<String>();
        dealIdset.addAll(dealMap.keyset());              
        
        //Where clause to append objectives query  
        string whereClause = 'AND Product_Objective__c in :dealIdSet ' 
                             +'AND account__r.TFS_Area_Number__c != null ';
       
       String mainQuery =  getProdObjQuery();                              
       String dealerObjectiveQuery = commonWhereClause(mainQuery) + whereClause;
       
       if(selectedTfsAreaNumber != TFS_Utility.ALL && selectedTfsAreaNumber != TFS_Utility.SUMMARY){
          dealerObjectiveQuery = dealerObjectiveQuery+' AND account__r.TFS_Area_Number__c=:selectedTfsAreaNumber';
       }
       
       //All objectives
       allObjectives = Database.query(dealerObjectiveQuery+' ORDER BY Account__r.TFS_Area_Number__c, Account__r.Name');  
    }

    //Retrieve Corporate objectives for corporate summary. 
    //Method added for sprint 6 and story:5895
    public List<CorporateWrapper> retrieveCorporateObjectives(){
        Set<Id> allRegionSet = new Set<Id>();
        Map<Id,Account> CorpMap = new Map<Id, Account>([SELECT Id,Name FROM Account WHERE Type =:TFS_Utility.COMPANY Limit 1]);
        String selectedCorp = corpMap.size() > 0 ? corpMap.values()[0].id : null;
        Map<string,set<string>> corpRegionMap = new Map<string,set<string>>();
        //Preparing corporateRegion Map
        for(Account ac :[SELECT Id,Name,parent.name, type, parent.type FROM Account where type = :TFS_Utility.REGION AND parent.type = :TFS_Utility.COMPANY AND ParentId= :corpMap.keyset()]){
            allRegionSet.add(ac.Id);
            if(corpRegionMap != NULL && corpRegionMap.containskey(ac.ParentId)){
              corpRegionMap.get(ac.parentId).add(ac.id);
            }
            else{
                corpRegionMap.put(ac.parentId,new set<string>{ac.id});
            }
        }
        
        Map<String,Id> corpObjUniqueMap = new Map<String,Id>(); // key: combination of fy,month and prod objecitve name
        //Fetching corporate objectives to prepare corpObjUniqueMap
        List<Product_Objective__c> productObjList =[SELECT id,Name,stretch__c,plan__c,Product_Objective__c,Fiscal_Year__c,
                                                        Month__c FROM Product_Objective__c 
                                                        WHERE type__c = :TFS_Utility.CORPORATE AND account__c in :corpMap.keyset() 
                                                        AND Month__c=:selectedMonth AND Fiscal_Year__c =:selectedYear 
                                                        And Name in :productList];
        Set<Id> corpObjIdSet = new Set<Id>();
        //Preparing corpObjectiveUnique Map 
        for(Product_Objective__c po : productObjList){
            corpObjIdSet.add(po.id);
            string key = po.Fiscal_Year__c+'_'+po.Month__c+'_'+po.Name;
            
            corpObjUniqueMap.put(key,po.id);   
        }  
        
        if (!isCalculate) { 
            allObjectives.clear();  
            //Where clause to append objectives query
            String whereClause = 'AND Account__r.RecordType.DeveloperName = \''+TFS_Utility.LOCATION+'\' '
                                    +'And Type__c = \''+TFS_Utility.REGION+'\' '
                                    +'And Product_objective__c IN :corpObjIdSet '
                                    +'AND account__r.Name != \''+TFS_Utility.PURETO_RICO+'\' '
                                    +'ORDER BY Account__r.Name,product__r.name';
              
            String mainQuery =  getProdObjQuery();                              
            String allObjectivesQuery = commonWhereClause(mainQuery) + whereClause;
            allObjectives = Database.query(allObjectivesQuery);
        }
        
        Map<String, Map<String, ObjectiveWrapper>> regionObjMap = new Map<String, Map<String, ObjectiveWrapper>>();
        Map<String, ObjectiveWrapper> objWrapperMap = new Map<String, ObjectiveWrapper>();// key = product name
        
        Decimal totalPlan = 0;
        Decimal totalStretch = 0;
        
        // key - product name, value - running total
        Map<String, Decimal> perProductPlanTotal = new Map<String, Decimal>();
        Map<String, Decimal> perProductStretchTotal = new Map<String, Decimal>();
        
        List<String> products = new List<String>(productList);
        
        products.add(TFS_Utility.TOTAL);
        
        //set 0's for all product totals
        for (String p : products) {
            perProductPlanTotal.put(p, 0);
            perProductStretchTotal.put(p, 0);    
        }   
        
        //Preparing wrapper class for custom sort on allObjectives
        List<ProductObjectiveWrapper> powList = new List<ProductObjectiveWrapper>();
        for(product_objective__c po : allObjectives){
            ProductObjectiveWrapper pow = new ProductObjectiveWrapper(po);
            powList.add(pow);
        } 
        powList.sort();
        
        //Temp variable to store objectives with 0's which are not there in database
        List<Product_Objective__c> allObjectivesTemp = new List<Product_Objective__c>();
        
        //Preparing objective wrapper class
        for (Integer i=0; i < powList.size(); i++) {
            Product_Objective__c  obj = powList[i].obj;
            ObjectiveWrapper objWrapper = new ObjectiveWrapper(obj.Id, obj.name, obj.Plan__c, 
                                                               obj.Stretch__c, obj);
               
            String p = obj.name;    
            objWrapperMap.put(p, objWrapper);                    
            
            String currRegionId = obj.Account__c;
                           
            if (obj.Plan__c != null) {
                totalPlan = totalPlan + obj.Plan__c;
            }
                    
            if (obj.Stretch__c != null){
                totalStretch = totalStretch + obj.Stretch__c;
            }         
            
            //Resetting variables for the new region
            integer powListsizeMOne = powList.size()-1;
            if (i == powListsizeMOne || (i != powListsizeMOne && currRegionId != powList[i+1].obj.Account__c) ) {  
                for(string prod : productList){
                    if(!objWrapperMap.containskey(prod)){
                        string key = selectedyear+'_'+selectedMonth+'_'+prod;
                        string corpObjKey = corpObjUniqueMap.containskey(key) ? corpObjUniqueMap.get(key) : null;
                        
                        Product_Objective__c objTemp = createRegionObjective(prod,currRegionId,corpObjKey);
                         
                        ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                           objTemp.Stretch__c, objTemp);
                        objWrapperMap.put(prod, objWrapperTemp);   
                        
                        allObjectivesTemp.add(objTemp); 
                    }
                }
                
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, totalPlan, totalStretch, obj);
                
                objWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
                
                //Key-Dsso : Value-Objectives
                regionObjMap.put(currRegionId, objWrapperMap);

                totalPlan = 0;
                totalStretch = 0;
                
                objWrapperMap = new Map<String, ObjectiveWrapper>(); 
            }    
        } 
        
        //fetching region Objectives
        List<Account> allRegionList = [SELECT Id,Name,ParentId,parent.name,type,parent.type,AccountNumber 
                                                      FROM Account where parent.type = :TFS_Utility.COMPANY 
                                                      AND type= :TFS_Utility.REGION
                                                      AND ParentId in :corpMap.keyset() 
                                                      AND Name != :TFS_Utility.PURETO_RICO];  
                                                      
        List<regWrapper> regionWrapperList = new List<regWrapper>();
        
        for(Account reg : allRegionList){
            objWrapperMap = new Map<String, ObjectiveWrapper>();
            if(regionObjMap.containskey(reg.Id)){
                regionWrapperList.add(new regWrapper(reg.Parent.Name, reg.Id, reg.Name,regionObjMap.get(reg.Id)));
            }
            else{
                for(string prod : productList){
                    string key = selectedyear+'_'+selectedMonth+'_'+prod;
                    string corpObjKey = corpObjUniqueMap.containskey(key) ? corpObjUniqueMap.get(key) : null;
                    
                    Product_Objective__c objTemp = createRegionObjective(prod,reg.Id,corpObjKey);
                     
                    ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                       objTemp.Stretch__c, objTemp);
                    objWrapperMap.put(prod, objWrapperTemp); 
                    allObjectivesTemp.add(objTemp);   
                } 
                Product_Objective__c objTotal = new Product_Objective__c();
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, 0, 0, objTotal);
                
                objWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
                
                regionWrapperList.add(new regWrapper(reg.Parent.Name, reg.Id, reg.Name, objWrapperMap));   
            }    
        } 
        allObjectives.addAll(allObjectivesTemp);
        
        string regName = corpMap.size() > 0 && selectedCorp != null ? corpMap.get(selectedCorp).Name : null;
        
        //preparing corp wrapper list
        if(regionWrapperList != null && regionWrapperList.size() > 0){
            Map<string,ObjectiveWrapper> objWrapMap = calculateTotalRegion(regionWrapperList);    
            //calculate variance
            calculateVariance(TFS_Utility.CORPORATE_OBJECTIVES,objWrapMap,productObjList);
            regionWrapperList.add( new regWrapper(TFS_Utility.REGION+TFS_Utility.BLANK_SPACE+TFS_Utility.TOTAL , TFS_Utility.BLANK , TFS_Utility.REGION+TFS_Utility.BLANK_SPACE+TFS_Utility.TOTAL,objWrapMap));     
            corporateWrapper corpWrapper = new corporateWrapper(selectedCorp, TFS_Utility.REGION, regionWrapperList);
        
            List<corporateWrapper> corpWrapperList = new List<corporateWrapper>();
            corpWrapperList.add(corpWrapper);
            
            return corpWrapperList;
        } 
        else{
            summaryTotalWrapper = new List<TotalWrapper>();
            isVarBlock = false;
        }
        
        return null; 
    }
    
    //Retrieve Region objectives for 'DSSO All'. 
    //Method added for sprint 6 and story:5895
    public List<RegionWrapper> retrieveRegionObjectives(){
        Map<String,Id> regionObjUniqueMap = new Map<String,Id>();
        List<Product_Objective__c> productObjList =[SELECT id,Name,stretch__c,plan__c,Product_Objective__c,Fiscal_Year__c,
                                                        Month__c FROM Product_Objective__c 
                                                        WHERE type__c = :TFS_Utility.REGION AND account__c = :selectedRegion 
                                                        AND Month__c=:selectedMonth AND Fiscal_Year__c =:selectedYear 
                                                        And Name in :productList];
        Set<Id> regObjIdSet = new Set<Id>();
        for(Product_Objective__c po : productObjList){
            regObjIdSet.add(po.id);
            regionObjUniqueMap.put(po.Fiscal_Year__c+'_'+po.Month__c+'_'+po.Name,po.Id); 
        }  
        
        if (!isCalculate) {
            allObjectives.clear();
            //Where clause to append with objecitves query
            String whereClause = 'AND Account__r.RecordType.DeveloperName = \''+TFS_Utility.LOCATION+'\' '
                                   +'And Type__c = \''+TFS_Utility.DSSO+'\' '
                                   +'And Product_objective__c IN: regObjIdSet '
                                   +'ORDER BY Account__r.Name,product__r.name';            
            
            String mainQuery =  getProdObjQuery();                              
            String allObjectivesQuery = commonWhereClause(mainQuery) + whereClause;
            allObjectives = Database.query(allObjectivesQuery);
        } 
        
        // Map of List of Objectives with corresponding Dsso Id
        Map<String, List<ObjectiveWrapper>> dssoObjListMap = new Map<String, List<ObjectiveWrapper>>();
        Map<String, Map<String, ObjectiveWrapper>> dssoObjMap = new Map<String, Map<String, ObjectiveWrapper>>();
        Map<String, ObjectiveWrapper> objWrapperMap = new Map<String, ObjectiveWrapper>();// key = product name
        
        Decimal totalPlan = 0;
        Decimal totalStretch = 0;
        Boolean hasPlanTotal = false;
        Boolean hasStretchTotal = false;
        
        // key - product name, value - running total
        Map<String, Decimal> perProductPlanTotal = new Map<String, Decimal>();
        Map<String, Decimal> perProductStretchTotal = new Map<String, Decimal>();
        
        List<String> products = new List<String>(productList);
        
        products.add('Total');
        //Setting 0's for product totals
        for (String p : products) {
            perProductPlanTotal.put(p, 0);
            perProductStretchTotal.put(p, 0);  
        }   
        
        //wrapper class to do custom sort
        List<ProductObjectiveWrapper> powList = new List<ProductObjectiveWrapper>();
        for(product_objective__c po : allObjectives){
            ProductObjectiveWrapper pow = new ProductObjectiveWrapper(po);
            powList.add(pow);
        } 
        powList.sort();
        
        List<Product_Objective__c> allObjectivesTemp = new List<Product_Objective__c>();
        
        //Preparing objective wrapper
        for (Integer i=0; i < powList.size(); i++) {
            Product_Objective__c  obj = powList[i].obj;
            ObjectiveWrapper objWrapper = new ObjectiveWrapper(obj.Id, obj.name, obj.Plan__c, 
                                                               obj.Stretch__c, obj);
               
            String p = obj.name;    
            objWrapperMap.put(p, objWrapper);                    
            
            String currDssoId = obj.Account__c;
                           
            if (obj.Plan__c != null) {
                totalPlan = totalPlan + obj.Plan__c;
                hasPlanTotal = true;
            }
                    
            if (obj.Stretch__c != null){
                totalStretch = totalStretch + obj.Stretch__c;
                hasStretchTotal = true;
            }         
            
            //To reset the variables for next dsso
            if (i == (powList.size()-1) || (i != (powList.size()-1) && currDssoId != powList[i+1].obj.Account__c) ) {  
                for(string prod : productList){
                    if(!objWrapperMap.containskey(prod)){
                        string key = selectedyear+'_'+selectedMonth+'_'+prod;
                        string regionObjKey = regionObjUniqueMap.containskey(key) ? regionObjUniqueMap.get(key) : null;
                        Product_Objective__c objTemp = createDSSOObjective(prod,currDssoId,regionObjKey);
                         
                        ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                           objTemp.Stretch__c, objTemp);
                        objWrapperMap.put(prod, objWrapperTemp);   
                        
                        allObjectivesTemp.add(objTemp); 
                    }
                }
                
                //ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, 'Total', hasPlanTotal? totalPlan:null, hasStretchTotal? totalStretch:null, obj);
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, 'Total', totalPlan, totalStretch, obj);
                
                objWrapperMap.put('Total', objTotalWrapper);
                
                //Key Dsso : Value Objectives
                dssoObjMap.put(currDssoId, objWrapperMap);
                  
                hasPlanTotal = false;
                hasStretchTotal = false;
                
                totalPlan = 0;
                totalStretch = 0;
                
                objWrapperMap = new Map<String, ObjectiveWrapper>(); 
            }    
        } 
        
        //Fetching all DSSO objectives
        List<Account> allDSSOList = [SELECT Id,Name,ParentId,parent.name,type,parent.type,AccountNumber 
                                                      FROM Account where parent.type = :TFS_Utility.REGION 
                                                      AND type= :TFS_Utility.DSSO 
                                                      AND ParentId = :selectedRegion];  
                                                      
        List<DssoWrapper> dssoWrapperList = new List<DssoWrapper>();
        
        for(Account dsso : allDSSOList){
            objWrapperMap = new Map<String, ObjectiveWrapper>();
            if(dssoObjMap.containskey(dsso.Id)){
                dssoWrapperList.add(new DssoWrapper(dsso.Parent.Name, dsso.Id, dsso.Name, dsso.AccountNumber, dssoObjMap.get(dsso.Id).values(),dssoObjMap.get(dsso.Id)));
            }
            else{
                for(string prod : productList){
                    string key = selectedyear+'_'+selectedMonth+'_'+prod;
                    string regionObjKey = regionObjUniqueMap.containskey(key) ? regionObjUniqueMap.get(key) : null;
                    Product_Objective__c objTemp = createDSSOObjective(prod,dsso.Id,regionObjKey);
                     
                    ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                       objTemp.Stretch__c, objTemp);
                    objWrapperMap.put(prod, objWrapperTemp); 
                    allObjectivesTemp.add(objTemp);   
                } 
                Product_Objective__c objTotal = new Product_Objective__c();
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, 0, 0, objTotal);
                
                objWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
                
                dssoWrapperList.add(new DssoWrapper(dsso.Parent.Name, dsso.Id, dsso.Name, dsso.AccountNumber, objWrapperMap.values(),objWrapperMap));   
            }    
        } 
        allObjectives.addAll(allObjectivesTemp);
        
        Map<id,account> regMap = new Map<id,account>([select id,name from account where id = :selectedRegion]);
        string regName = regMap.containskey(selectedregion) ?  regMap.get(selectedregion).Name : null;
        
        //Preparing regionwrapper list
        if(dssoWrapperList != null && dssoWrapperList.size() > 0){
            Map<string,ObjectiveWrapper> objWrapMap = calculateTotalDSSO(dssoWrapperList);    
            //calculating variance
            calculateVariance(TFS_Utility.REGION_OBJECTIVES,objWrapMap,productObjList);
            dssoWrapperList.add( new DssoWrapper (regName+TFS_Utility.BLANK_SPACE+TFS_Utility.TOTAL , TFS_Utility.BLANK , regName+TFS_Utility.BLANK_SPACE+TFS_Utility.TOTAL, TFS_Utility.BLANK,objWrapMap.values(),objWrapMap));     
            RegionWrapper regionWrapper = new RegionWrapper(selectedRegion, regName, dssoWrapperList, null);
        
            List<RegionWrapper> regionWrapperList = new List<RegionWrapper>();
            regionWrapperList.add(regionWrapper);
            
            return regionWrapperList;
        } 
        else{
            summaryTotalWrapper = new List<TotalWrapper>();
            isVarBlock = false;
        }
        
        return null;
    }
    
    //Calculating variance
    //Method added for story : 5599 and 5895
    public void calculateVariance(String objectiveName,Map<string,ObjectiveWrapper> allocatedObjWrapperMap,List<product_objective__c> pObjList){
        summaryTotalWrapper = new List<TotalWrapper>(); 
        Map<String, ObjectiveWrapper> regObjWrapperMap = new Map<String, ObjectiveWrapper>(); 
        Decimal totalPlan = 0;
        Decimal totalStretch = 0;
        //preparing region Objecitve wrapper
        for(product_objective__c pObj : pObjList){
            ObjectiveWrapper objWrapper = new ObjectiveWrapper(pObj.name, pObj.Plan__c,pObj.Stretch__c);
                 
            regObjWrapperMap.put(pObj.Name, objWrapper);                    
                
            if (pObj.Plan__c != null) {
                totalPlan = totalPlan + pObj.Plan__c;
            }
                    
            if (pObj.Stretch__c != null){
                totalStretch = totalStretch + pObj.Stretch__c;
            }         
        } 
        
        //Inserting dummy data to the wrapper for products which do not have objectives
        for(string prod : productList){
            if(!regObjWrapperMap.containskey(prod)){              
                Product_Objective__c objTemp = new Product_Objective__c(name=prod,plan__c = 0,stretch__c = 0);
                 
                ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.name, objTemp.Plan__c,objTemp.Stretch__c);
                regObjWrapperMap.put(prod, objWrapperTemp);   
            }
        }
                
        //ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, 'Total', hasPlanTotal? totalPlan:null, hasStretchTotal? totalStretch:null, obj);
        ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(TFS_Utility.TOTAL, totalPlan, totalStretch);
        
        regObjWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
        
        //Calcualting variance Objective warapper
        Map<String, ObjectiveWrapper> varObjWrapperMap = new Map<String, ObjectiveWrapper>(); 
        for(string prod : productList){
            ObjectiveWrapper objWrapper;
            if(regObjWrapperMap.containskey(prod) && allocatedObjWrapperMap.containskey(prod)){
                decimal varPlan = regObjWrapperMap.get(prod).planAmt - allocatedObjWrapperMap.get(prod).planAmt;
                decimal varStretch = regObjWrapperMap.get(prod).stretchAmt - allocatedObjWrapperMap.get(prod).stretchAmt;
                objWrapper = new ObjectiveWrapper(prod, varPlan, varStretch);
            }
            else{
                objWrapper = new ObjectiveWrapper(prod, 0, 0);
            }
       
            varObjWrapperMap.put(prod, objWrapper);
        }  
        
        ObjectiveWrapper objWrapper;
        if(regObjWrapperMap.containskey(TFS_Utility.TOTAL) && allocatedObjWrapperMap.containskey(TFS_Utility.TOTAL)){
            decimal varPlan = regObjWrapperMap.get(TFS_Utility.TOTAL).planAmt - allocatedObjWrapperMap.get(TFS_Utility.TOTAL).planAmt;
            decimal varStretch = regObjWrapperMap.get(TFS_Utility.TOTAL).stretchAmt - allocatedObjWrapperMap.get(TFS_Utility.TOTAL).stretchAmt;
            objWrapper = new ObjectiveWrapper(TFS_Utility.TOTAL, varPlan, varStretch);
        }
        else{
            objWrapper = new ObjectiveWrapper(TFS_Utility.TOTAL, 0, 0);
        }
        varObjWrapperMap.put(TFS_Utility.TOTAL, objWrapper);
        
        //Set the value to summary wrapper total
        summaryTotalWrapper.add(new TotalWrapper(objectiveName,regObjWrapperMap.values(),regObjWrapperMap));
        summaryTotalWrapper.add(new TotalWrapper(TFS_Utility.ALLOCATED ,allocatedObjWrapperMap.values(),allocatedObjWrapperMap));
        summaryTotalWrapper.add(new TotalWrapper(TFS_Utility.VARIANCE ,varObjWrapperMap.values(),varObjWrapperMap)); 
    }
    
    
    // Fetch Region related Objectives
    //This method was modified for story : 5599 and 5895
    private List<RegionWrapper> retrieveRegions() {
        // Retrieve all DSSO MFD
        String allDssosQuery = 'SELECT Id,Name,parent.name, type, parent.type,Region_Name__c,AccountNumber FROM Account where parent.type =\''+TFS_Utility.REGION+'\' AND type=\''+TFS_Utility.DSSO+'\'';
        if (selectedregion != TFS_Utility.ALL &&  selectedregion != TFS_Utility.CORPORATE_ALL 
                                              && selectedregion != TFS_Utility.CORPORATE_SUMMARY 
                                              && selectedregion != TFS_Utility.NATIONAL){
            allDssosQuery = allDssosQuery + ' AND Parent.Id = :selectedregion '; 
        } 
        
        List<Account> allDssos = Database.query(allDssosQuery);
        Set<Id> allDssosSet = new Set<Id>();
        for(Account ac : allDssos){
          allDssosSet.add(ac.Id);
        }
        
        //Fetching product objectives
        Map<String,Id> regionObjUniqueMap = new Map<String,Id>();
        List<Product_Objective__c> productObjList =[SELECT id,Name,Product_Objective__c,Fiscal_Year__c,Month__c FROM Product_Objective__c 
                                                    WHERE type__c = :TFS_Utility.REGION AND account__c = :selectedRegion 
                                                    AND Month__c=:selectedMonth AND Fiscal_Year__c =:selectedYear 
                                                    And Name in :productList];
        Set<Id> regObjIdSet = new Set<Id>();
        for(Product_Objective__c po : productObjList){
            regObjIdSet.add(po.id);
            regionObjUniqueMap.put(po.Fiscal_Year__c+'_'+po.Month__c+'_'+po.Name,po.Id); 
        }        
        
        if (!isCalculate) {
            allObjectives.clear();
            //Where clause to append with objective query
            String whereClause = 'AND Account__r.RecordType.DeveloperName = \''+TFS_Utility.LOCATION+'\' '
                                  +'And Type__c = \''+TFS_Utility.DSSO+'\' and Account__c IN: allDssosSet '
                                  +'ORDER BY  Account__r.Name,product__r.name';
            
            
            String mainQuery =  getProdObjQuery();                              
            String allObjectivesQuery = commonWhereClause(mainQuery) + whereClause;
            allObjectives = Database.query(allObjectivesQuery);
        }
        
        // Map of List of Objectives with corresponding Dsso Id
        Map<String, List<ObjectiveWrapper>> dssoObjListMap = new Map<String, List<ObjectiveWrapper>>();
        Map<String, Map<String, ObjectiveWrapper>> dssoObjMap = new Map<String, Map<String, ObjectiveWrapper>>();
        List<ObjectiveWrapper> objWrapperList = new List<ObjectiveWrapper>(); 
        Map<String, ObjectiveWrapper> objWrapperMap = new Map<String, ObjectiveWrapper>();// key = product name
        
        Decimal totalPlan = 0;
        Decimal totalStretch = 0;
        Boolean hasPlanTotal = false;
        Boolean hasStretchTotal = false;
        
        // key - product name, value - running total
        Map<String, Decimal> perProductPlanTotal = new Map<String, Decimal>();
        Map<String, Decimal> perProductStretchTotal = new Map<String, Decimal>();
        
        List<String> products = new List<String>(productList);
        
        products.add('Total');
        //Setting 0's for all product totals
        for (String p : products) {
            perProductPlanTotal.put(p, 0);
            perProductStretchTotal.put(p, 0);  
        }   
        
        //wrapper class to do custom sort
        List<ProductObjectiveWrapper> powList = new List<ProductObjectiveWrapper>();
        for(product_objective__c po : allObjectives){
            ProductObjectiveWrapper pow = new ProductObjectiveWrapper(po);
            powList.add(pow);
        } 
        powList.sort();
        
        List<Product_Objective__c> allObjectivesTemp = new List<Product_Objective__c>();
        
        //Preparing objective wrapper class
        for (Integer i=0; i < powList.size(); i++) {
            Product_Objective__c  obj = powList[i].obj;
            ObjectiveWrapper objWrapper = new ObjectiveWrapper(obj.Id, obj.name, obj.Plan__c, 
                                                               obj.Stretch__c, obj);
               
            String p = obj.name;    
            objWrapperMap.put(p, objWrapper);                    
            objWrapperList.add(objWrapper); 
            
            String currDssoId = obj.Account__c;
                           
            if (obj.Plan__c != null) {
                totalPlan = totalPlan + obj.Plan__c;
                hasPlanTotal = true;
            }
                    
            if (obj.Stretch__c != null){
                totalStretch = totalStretch + obj.Stretch__c;
                hasStretchTotal = true;
            }         
            
            if (i == (powList.size()-1) || (i != (powList.size()-1) && currDssoId != powList[i+1].obj.Account__c) ) {  
                for(string prod : productList){
                    if(!objWrapperMap.containskey(prod)){
                        Product_Objective__c objTemp = createDSSOObjective(prod,currDssoId,null);
                         
                        ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                           objTemp.Stretch__c, objTemp);
                        objWrapperMap.put(prod, objWrapperTemp);   
                        
                        allObjectivesTemp.add(objTemp); 
                    }
                }
                
                //ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, 'Total', hasPlanTotal? totalPlan:null, hasStretchTotal? totalStretch:null, obj);
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, 'Total', totalPlan, totalStretch, obj);
                
                objWrapperMap.put('Total', objTotalWrapper);
                objWrapperList.add(objTotalWrapper);
                
                //Key Dsso : Value Objectives
                dssoObjListMap.put(currDssoId, objWrapperList);
                dssoObjMap.put(currDssoId, objWrapperMap);
                  
                hasPlanTotal = false;
                hasStretchTotal = false;
                
                totalPlan = 0;
                totalStretch = 0;
                
                objWrapperList = new List<ObjectiveWrapper>();
                objWrapperMap = new Map<String, ObjectiveWrapper>(); 
            } 
            
        }   
        
        // Create DssoWrapper AND assign to corresponding Region
        List<DssoWrapper> dssoWrapperList = new List<DssoWrapper>();
        Map<String, List<DssoWrapper>> regionDssoMap = new Map<String, List<DssoWrapper>>();
        Map<String, TotalWrapper> regionDssoTotalMap = new Map<String, TotalWrapper>();
          
        // Create Region Objectives Map
         String allRegionObjectivesQuery ='SELECT Name,Account__c,Account__r.Name,Account__r.Parent.Name,Product_Objective__c , Product__c,Product__r.name , Stretch__c,Plan__c FROM Product_Objective__c where '+
                                         'Account__r.RecordType.DeveloperName = \''+TFS_Utility.LOCATION+'\' and Type__c = \''+TFS_Utility.DSSO +'\'  and Account__c IN: allDssosSet AND Month__c=:selectedMonth and'+
                                         ' Fiscal_Year__c =:selectedYear and product__r.Type__c=:category '+
                                         'and name in :productList';
        
        if (selectedRegion != TFS_Utility.ALL &&  selectedregion != TFS_Utility.CORPORATE_ALL 
                                              && selectedregion != TFS_Utility.CORPORATE_SUMMARY 
                                              && selectedregion != TFS_Utility.NATIONAL){
            allRegionObjectivesQuery = allRegionObjectivesQuery + ' AND Account__r.Parent.Id= :selectedregion';
        }
            
        List<Product_Objective__c> allRegionObjectives = Database.query(allRegionObjectivesQuery);
        
        // key = RegioId + Product
        Map<String, Product_Objective__c> regionObjMap= new Map<String, Product_Objective__c>();   
             
        for (Product_Objective__c  regionObj : allRegionObjectives ) {
            regionObjMap.put(regionObj.Account__r.Name + regionObj.Name, regionObj );
        }
        if (selectedregion != TFS_Utility.ALL && selectedregion != TFS_Utility.ZERO){     
            dssoWrapperList.clear();
        }
        for (Integer i=0; i < allDssos.size(); i++) {
            Account dsso = allDssos.get(i);
            String currRegionId = dsso.Name;
            
            objWrapperMap = new Map<String, ObjectiveWrapper>();
            if(dssoObjMap.containskey(dsso.Id)){
                dssoWrapperList.add(new DssoWrapper(dsso.Parent.Name, dsso.Id, dsso.Name, dsso.AccountNumber, dssoObjListMap.get(dsso.Id),dssoObjMap.get(dsso.Id)));
            }
            else{
                for(string prod : productList){
                    Product_Objective__c objTemp = createDSSOObjective(prod,dsso.Id,null);
                     
                    ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                       objTemp.Stretch__c, objTemp);
                    objWrapperMap.put(prod, objWrapperTemp); 
                    allObjectivesTemp.add(objTemp);   
                } 
                Product_Objective__c objTotal = new Product_Objective__c();
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, 0, 0, objTotal);
                
                objWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
                
                dssoWrapperList.add(new DssoWrapper(dsso.Parent.Name, dsso.Id, dsso.Name, dsso.AccountNumber, objWrapperMap.values(),objWrapperMap));   
            }
            for (String p : products) {
                if (dssoObjMap.containskey(dsso.Id) && dssoObjMap.get(dsso.Id).containskey(p) && dssoObjMap.get(dsso.Id).get(p).planAmt != null)
                    perProductPlanTotal.put(p, perProductPlanTotal.get(p) + dssoObjMap.get(dsso.Id).get(p).planAmt);
                    
                if (dssoObjMap.get(dsso.Id) != NULL && dssoObjMap.get(dsso.Id).get(p)!= NULL && dssoObjMap.get(dsso.Id).get(p).stretchAmt != null)    
                    perProductStretchTotal.put(p, perProductStretchTotal.get(p) + dssoObjMap.get(dsso.Id).get(p).stretchAmt);
            }

           if (i == (allDssos.size()-1) || (i != (allDssos.size()-1) && currRegionId != allDssos.get(i+1).Region_Name__c) ) {             
                regionDssoMap.put(currRegionId, dssoWrapperList);
                
                dssoWrapperList = new List<DssoWrapper>(); 
                                
                perProductPlanTotal = new Map<String, Decimal>();
                perProductStretchTotal = new Map<String, Decimal>();                
                for (String p : products) {
                    perProductPlanTotal.put(p, 0);
                    perProductStretchTotal.put(p, 0);
                }
            }            
        }
        allObjectives.addAll(allObjectivesTemp);
        
        // Create RegionWrapper
        List<Account> allRegions = new List<Account>();
        if (selectedRegion == TFS_Utility.ALL || selectedregion == TFS_Utility.CORPORATE_ALL 
                                              || selectedregion == TFS_Utility.CORPORATE_SUMMARY) {
            allRegions = [SELECT Id,Name,parent.name, type, parent.type FROM Account where type = :TFS_Utility.REGION ORDER BY Region_Sorting__c ASC];
            isRenderSummary = true;            
        } else {
            allRegions = [SELECT Id,Name,parent.name, type, parent.type FROM Account where type = :TFS_Utility.REGION AND Id=: selectedregion ORDER BY Region_Sorting__c ASC ];
            isRenderSummary = false;
        }            
        List<RegionWrapper> regionWrapperList = new List<RegionWrapper>();
 
        for (Account r: allRegions) {
            List<DssoWrapper> dssos = new List<DssoWrapper>(); 
            TotalWrapper totalWrapper;
            if(regionsDSSOMap.containskey(r.Name) && regionsDSSOMap.get(r.Name) != null){
                for(String str:regionsDSSOMap.get(r.Name)){
                    if(regionDssoMap.get(str) != NULL){
                        for(DssoWrapper temp :regionDssoMap.get(str)){
                           dssos.add(temp);
                        } 
                    }         
                }                    
            }
            Map<string,ObjectiveWrapper> objWrapMap = calculateTotalDSSO(dssos);
            dssos.add( new DssoWrapper ( r.Name +' '+TFS_Utility.TOTAL , TFS_Utility.BLANK , r.Name +' '+TFS_Utility.TOTAL, TFS_Utility.BLANK,objWrapMap.values(),objWrapMap));
            RegionWrapper regionWrapper = new RegionWrapper(r.Id, r.name, dssos, totalWrapper );
            regionWrapperList.add(regionWrapper);
        }
        List<RegionWrapper>  allRegionWrapperList = new List<RegionWrapper>();
        if(selectedregion == TFS_Utility.CORPORATE_ALL){
             TotalWrapper totalWrapper;
             allRegionWrapperList = createCorporateWrapper(regionWrapperList);   
        }
        else{
          allRegionWrapperList.addAll(regionWrapperList);
        }
        // Return Region Wrapper
        return regionWrapperList;
    }
    
    // Retrieve TFS Area Level Objectives 
    //This method was modified for story : 5736
    private List<TFSAreaWrapper> retrieveTFSAreas() {
        noAction = false;
        Map<String,Id> dssoUniqueMap = new Map<String,Id>();
        List<Product_Objective__c> productObjList =[SELECT id,Name,Product_Objective__c,Fiscal_Year__c,Month__c FROM Product_Objective__c 
                                                    WHERE type__c = :TFS_Utility.DSSO AND account__r.name=:selectedDsso 
                                                    AND Month__c=:selectedMonth AND Fiscal_Year__c =:selectedYear 
                                                    And Name in :productList];
        Set<Id> dealId = new Set<Id>();
        for(Product_Objective__c po : productObjList){
            dealId.add(po.id);
            dssoUniqueMap.put(po.Fiscal_Year__c+'_'+po.Month__c+'_'+po.Name,po.Id); 
        }     

        //retrieve all the values of the dsso related product objective (id and account)        
        List<Product_Objective__c> allprodObjectives = new  List<Product_Objective__c>();
        List<Account> allDealer = new List<Account>();
        if (selectedTfsAreaNumber != TFS_Utility.ALL && selectedTfsAreaNumber != TFS_Utility.SUMMARY){
            allDealer = [select id,name,AccountNumber,tfs_area_number__c from account 
                                                                where DSSO_Name__c = :selectedDsso  
                                                                AND TFS_Relationship__c IN :tfsrelationshipSet 
                                                                AND TFS_Area_Number__c!=null 
                                                                AND TFS_Area_Number__c=:selectedTfsAreaNumber 
                                                                ORDER BY TFS_Area_Number__c];
        }                             
        else{
             allDealer = [select id,name,AccountNumber,tfs_area_number__c from account 
                                                                where DSSO_Name__c = :selectedDsso  
                                                                AND TFS_Relationship__c IN :tfsrelationshipSet 
                                                                AND TFS_Area_Number__c!=null  
                                                                AND status__c = :isActive
                                                                ORDER BY TFS_Area_Number__c];
        }

        if (!isCalculate) { 
            //where clause to append with objecitves query
            string whereClause = TFS_Utility.BLANK;           
            if (selectedTfsAreaNumber != TFS_Utility.ALL && selectedTfsAreaNumber != TFS_Utility.SUMMARY){
                whereClause = 'AND Product_Objective__c in:dealId '
                                     +'And account__r.TFS_Area_Number__c!=null '
                                     +'And account__r.TFS_Area_Number__c=:selectedTfsAreaNumber '
                                     +'ORDER BY  Account__r.Name,product__r.name';
            }                   
            else{
                whereClause = 'AND Product_Objective__c in:dealId '
                                     +'And account__r.TFS_Area_Number__c!=null '
                                     +'ORDER BY  Account__r.Name,product__r.name';
            } 
            
            String mainQuery =  getProdObjQuery();                              
            String allObjectivesQuery = commonWhereClause(mainQuery) + whereClause;
            allObjectives = Database.query(allObjectivesQuery);  
        }
        
        // Map of List of Objectives with corresponding Dsso Id
        Map<String, List<ObjectiveWrapper>> dealerObjListMap = new Map<String, List<ObjectiveWrapper>>();
        Map<String, Map<String, ObjectiveWrapper>> dealerObjMap = new Map<String, Map<String, ObjectiveWrapper>>();
        
        List<ObjectiveWrapper> objWrapperList = new List<ObjectiveWrapper>(); // key = product name
        Map<String, ObjectiveWrapper> objWrapperMap = new Map<String, ObjectiveWrapper>(); // key = product name
        Decimal totalPlan = 0;
        Decimal totalStretch = 0;
        Boolean hasPlanTotal = false;
        Boolean hasStretchTotal = false;
        String prevDealerId;
        
        // key - product name, value - running total
        Map<String, Decimal> perProductPlanTotal = new Map<String, Decimal>();
        Map<String, Decimal> perProductStretchTotal = new Map<String, Decimal>();
        
        Map<String, Decimal> allocatedPlanTotalMap = new Map<String, Decimal>();
        Map<String, Decimal> allocatedStretchTotalMap = new Map<String, Decimal>();
        
        List<String> products = new List<String>(productList);        
        products.add(TFS_Utility.TOTAL);
        
        //looping all the values of the product
        for (String p : products) {
            perProductPlanTotal.put(p, 0);
            perProductStretchTotal.put(p, 0);
            allocatedPlanTotalMap.put(p, 0);
            allocatedStretchTotalMap.put(p, 0);
        }
        
        List<ProductObjectiveWrapper> powList = new List<ProductObjectiveWrapper>();
        for(product_objective__c po : allObjectives){
            ProductObjectiveWrapper pow = new ProductObjectiveWrapper(po);
            powList.add(pow);
        } 
        powList.sort();
        
        List<Product_Objective__c> allObjectivesTemp = new List<Product_Objective__c>();
        //looping through the values of objectives
        for (Integer i=0; i < powList.size(); i++) {            
            Product_Objective__c obj = powList[i].obj;            

            // ObjectiveWrapper (String objectiveId, String productName, Decimal planAmt, Decimal stretchAmt)
            ObjectiveWrapper objWrapper = new ObjectiveWrapper(obj.Id, obj.Product__r.name, obj.Plan__c, obj.Stretch__c, obj);            
            
            // prevDealerId = i!=0? allObjectives.get(i-1).TFS_Monthly_Financial_Data__r.Dealer__c : null;
            String currDealerId = obj.Account__c;
            String p = obj.Name;
            
            objWrapperMap.put(p, objWrapper);                    
            objWrapperList.add(objWrapper);
                       
            if (obj.Plan__c != null){       
                totalPlan = totalPlan + obj.Plan__c;
                if(allocatedPlanTotalMap.containskey(p)){
                    allocatedPlanTotalMap.put(p, allocatedPlanTotalMap.get(p) + obj.Plan__c);
                }
                else{
                    allocatedPlanTotalMap.put(p,obj.Plan__c);
                }
                hasPlanTotal = true;
                
            }
            
            if (obj.Stretch__c != null){
                totalStretch = totalStretch + obj.Stretch__c;
                if(allocatedStretchTotalMap.containskey(p)){
                    allocatedStretchTotalMap.put(p, allocatedStretchTotalMap.get(p) + obj.stretch__c);
                }
                else{
                    allocatedStretchTotalMap.put(p, obj.stretch__c);
                }
                hasStretchTotal = true;
            }
            
            if (i == (powList.size()-1) || (i != (powList.size()-1) && currDealerId != powList[i+1].obj.account__c)) {
                for(string prod : productList){
                    if(!objWrapperMap.containskey(prod)){
                        string key = selectedyear+'_'+selectedMonth+'_'+prod;
                        string dssoObjKey = dssoUniqueMap.containskey(key) ? dssoUniqueMap.get(key) : null;
                        Product_Objective__c objTemp = createDealerObjective(prod,currDealerId,dssoObjKey);
                                         
                        ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                           objTemp.Stretch__c, objTemp);
                        objWrapperMap.put(prod, objWrapperTemp);  
                        allObjectivesTemp.add(objTemp);  
                    }
                }
                
                Product_Objective__c objTotal = new Product_Objective__c();
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, totalPlan, totalStretch, objtotal);
        
                objWrapperMap.put('Total', objTotalWrapper);
                objWrapperList.add(objTotalWrapper);
        
                dealerObjListMap.put(currDealerId, objWrapperList);
                dealerObjMap.put(currDealerId, objWrapperMap);
           
                hasPlanTotal = false;
                hasStretchTotal = false;
                
                totalPlan = 0;
                totalStretch = 0;   
                
                objWrapperList = new List<ObjectiveWrapper>();
                objWrapperMap = new Map<String, ObjectiveWrapper>(); 
            } 
        }
        
        // Create DealerWrapper AND assign to corresponding Region
        List<DealerWrapper> dealerWrapperList = new List<DealerWrapper>();
        Map<String, List<DealerWrapper>> tfsAreaDealerMap = new Map<String, List<DealerWrapper>>();
        Map<String, TotalWrapper> tfsAreaDealerTotalMap = new Map<String, TotalWrapper>();
         
        Set<Id> alreadyadded=new Set<Id>();
        String prevRegionId;
        Integer allDealerSize = allDealer.size();
        for (Integer i=0; i < allDealerSize; i++) {
            Account dealer = allDealer.get(i);
            String currTfsArea = dealer.TFS_Area_Number__c;
            objWrapperMap = new Map<String, ObjectiveWrapper>();
            if(dealerObjMap.containskey(dealer.Id)){
                dealerWrapperList.add(new DealerWrapper(dealer.TFS_Area_Number__c, dealer.Id, dealer.Name, dealer.AccountNumber, dealerObjListMap.get(dealer.Id),dealerObjMap.get(dealer.Id)));
            }
            else{
                for(string prod : productList){
                    string key = selectedyear+'_'+selectedMonth+'_'+prod;
                    string dssoObjKey = dssoUniqueMap.containskey(key) ? dssoUniqueMap.get(key) : null;
                    Product_Objective__c objTemp = createDealerObjective(prod,dealer.Id,dssoObjKey);
                                     
                    ObjectiveWrapper objWrapperTemp = new ObjectiveWrapper(objTemp.Id, objTemp.name, objTemp.Plan__c, 
                                                                       objTemp.Stretch__c, objTemp);
                    objWrapperMap.put(prod, objWrapperTemp);  
                    allObjectivesTemp.add(objTemp);   
                }
                
                Product_Objective__c objTotal = new Product_Objective__c();
                ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(null, TFS_Utility.TOTAL, totalPlan, totalStretch, objtotal);
        
                objWrapperMap.put(TFS_Utility.TOTAL, objTotalWrapper);
            
                dealerWrapperList.add(new DealerWrapper(dealer.TFS_Area_Number__c, dealer.Id, dealer.Name, dealer.AccountNumber, objWrapperMap.values(),objWrapperMap));
            }
            for (String p : products) {
                if(dealerObjMap!=null){                    
                    if(dealerObjMap.containskey(dealer.id) && dealerObjMap.get(dealer.id).containskey(p)
                                                           && dealerObjMap.get(dealer.id).get(p) !=null){
                        if (dealerObjMap.get(dealer.id).get(p).planAmt != null){
                            perProductPlanTotal.put(p, perProductPlanTotal.get(p) + dealerObjMap.get(dealer.id).get(p).planAmt);
                        }
                        if (dealerObjMap.get(dealer.id).get(p).stretchAmt != null){    
                            perProductStretchTotal.put(p, perProductStretchTotal.get(p) + dealerObjMap.get(dealer.id).get(p).stretchAmt);
                        }
                    }
                }
            }
            
            integer allDealerMOne = allDealerSize - 1;
            if (i == allDealerMOne || (i != allDealerMOne && currTfsArea != allDealer.get(i+1).TFS_Area_Number__c) ) {                
                Map<string,ObjectiveWrapper> perProductTotalsMap = new Map<string,ObjectiveWrapper>(); 
                for (String p : products) {
                    Product_Objective__c tfsAreaObj = new Product_Objective__c();                    
                    ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(tfsAreaObj.Id, p, perProductPlanTotal.get(p), perProductStretchTotal.get(p), tfsAreaObj);                    
                    perProductTotalsMAp.put(p,objTotalWrapper);
                }
                TotalWrapper totalWrapper = new TotalWrapper(TFS_Utility.TFS_AREA+' '+currTfsArea+' '+TFS_Utility.TOTAL, perProductTotalsMap.values(),perProductTotalsMap); 
                dealerWrapperList.add(new DealerWrapper(TFS_Utility.BLANK, dealer.Id, TFS_Utility.TFS_AREA+' '+currTfsArea+' '+TFS_Utility.TOTAL, TFS_Utility.BLANK, perProductTotalsMap.values(),perProductTotalsMap));                            
                tfsAreaDealerTotalMap.put(currTfsArea , totalWrapper);

                if(currTfsArea!= NULL && currTfsArea!= ''){                   
                    if(tfsAreaDealerMap.containsKey(currTfsArea) && tfsAreaDealerMap.containsKey(currTfsArea) != NULL){
                         List<DealerWrapper> dealerWraptempList = tfsAreaDealerMap.get(currTfsArea);
                         dealerWraptempList.addAll(dealerWrapperList);
                         tfsAreaDealerMap.put(currTfsArea, dealerWraptempList);
                    }
                    else{
                        tfsAreaDealerMap.put(currTfsArea, dealerWrapperList);
                    }
                }
  
                dealerWrapperList = new List<DealerWrapper>();                 
                
                perProductPlanTotal = new Map<String, Decimal>();
                perProductStretchTotal = new Map<String, Decimal>();
              
                for (String p : products) {
                    perProductPlanTotal.put(p, 0);
                    perProductStretchTotal.put(p, 0);
                }                
            }               
        }
        allObjectives.addAll(allObjectivesTemp);
        // Create TFSAreaWrapper
        if (selectedTfsAreaNumber != TFS_Utility.ALL){
            isRenderSummary = false;
        }
        else{
            isRenderSummary = true;
        }
        List<String> allTfsAreas = new List<String>();
        if (selectedTfsAreaNumber != TFS_Utility.ALL && selectedTfsAreaNumber != TFS_Utility.SUMMARY && selectedTfsAreaNumber != TFS_Utility.ZERO)
            allTfsAreas.add(selectedTfsAreaNumber);    
        else{
            tfsAreaList  = new List<String>(SetTFSAreaNumber);
            allTfsAreas = new List<String>(tfsAreaList);
        } 
              
        List<TFSAreaWrapper> tfsAreaWrapperList = new List<TFSAreaWrapper>();
        summaryTotalWrapper = new List<TotalWrapper>();
        for (String a: allTfsAreas) {
            if(tfsAreaDealerMap.containskey(a) && tfsAreaDealerMap.get(a) != null 
                                               && tfsAreaDealerMap.get(a).size() > 0){
                TFSAreaWrapper tfsAreaWrapper = new TFSAreaWrapper(a, tfsAreaDealerMap.get(a), tfsAreaDealerTotalMap.get(a) );
                tfsAreaWrapperList.add(tfsAreaWrapper);    
            }
            
            if(selectedTfsAreaNumber != TFS_Utility.ZERO && selectedTfsAreaNumber != TFS_Utility.ALL 
                                                         && selectedTfsAreaNumber != TFS_Utility.SUMMARY 
                                                         && !noAction 
                                                         && (tfsAreaDealerMap.get(a) == NULL 
                                                                 || tfsAreaDealerMap.get(a).isEmpty())){
               noAction = true;
            }
                 
                  
            if (selectedTfsAreaNumber == TFS_Utility.SUMMARY)
                summaryTotalWrapper.add(tfsAreaDealerTotalMap.get(a)); 
       } 
            
        // Create wrapper for DSSO Objectives       
        List<Product_Objective__c> dssoMfds = [SELECT Id,Account__c,LastModifiedDate ,Date_Submitted__c,Product_Objective__c,LastModifiedById, LastModifiedBy.Name,
                                               Fiscal_Year__c,Month__c,Name,Plan__c,Product__r.name,Status__c,Stretch__c,Type__c 
                                               FROM Product_Objective__c
                                               WHERE Fiscal_Year__c =:selectedYear AND Month__c =:selectedMonth 
                                               and Name in :productList  and product__r.Type__c=:category 
                                               and  type__c= :TFS_Utility.DSSO and account__r.name=:selectedDsso];
       
        Map<String, Product_Objective__c> dssoObjectivesMap = new Map<String, Product_Objective__c>();        
        if (!dssoMfds.isEmpty()){                 
            //selected list of user having the  dsso
            if(dssoMfds[0].Status__c!=null){
                if (dssoMfds[0].Status__c == TFS_Utility.COMPLETE)
                    isComplete = true;
                else
                    isComplete = false;
            }
            for(Product_Objective__c dssoObj : dssoMfds) {
                dssoObjectivesMap.put(dssoObj.name, dssoObj );
            }            
        }
        else{
            if (selectedDsso != TFS_Utility.ZERO) {
                isComplete = false;                
            }
        }
        List<ObjectiveWrapper> dssoObjectiveWrappers = new List<ObjectiveWrapper>();
        Map<String,ObjectiveWrapper> dssoObjectiveWrappersMap = new Map<String,ObjectiveWrapper>();
        Decimal dssoObjPlanTotal = 0;
        Decimal dssoObjStretchTotal = 0;
        
        // Create wrapper for grAND total summary
        List<ObjectiveWrapper> grandTotals = new List<ObjectiveWrapper>();
        Map<String,ObjectiveWrapper> grandTotalsMap = new Map<String,ObjectiveWrapper>();
        Decimal grandPlanTotal = 0;
        Decimal grandStretchTotal = 0;
        
        // Create wrapper for variance
        List<ObjectiveWrapper> variances = new List<ObjectiveWrapper>(); 
        Map<String,ObjectiveWrapper> variancesMap = new Map<String,ObjectiveWrapper>();          
        //products.remove(products.size()-1);
                
        for (String p : products){          
            // Create DSSO Objectives row
            Decimal dssoObjPlan = 0;
            Decimal dssoObjStretch = 0;
            ObjectiveWrapper dssoObjWrapper;            
            if (dssoObjectivesMap.containsKey(p)) {
                Decimal objPlan = dssoObjectivesMap.get(p).Plan__c;
                Decimal objStretch = dssoObjectivesMap.get(p).Stretch__c;               
                dssoObjPlan = objPlan != null? objPlan : 0;
                dssoObjStretch = objStretch != null? objStretch : 0;               
                dssoObjWrapper = new ObjectiveWrapper(p, dssoObjPlan, dssoObjStretch);                
            } else {
                dssoObjWrapper = new ObjectiveWrapper(p, 0, 0);
            }            
            dssoObjPlanTotal = dssoObjPlanTotal + dssoObjPlan;
            dssoObjStretchTotal = dssoObjStretchTotal + dssoObjStretch;
            dssoObjectiveWrappers.add(dssoObjWrapper);
            dssoObjectiveWrappersMap.put(p,dssoObjWrapper);
            // Create Allocated row
            ObjectiveWrapper objTotalWrapper = new ObjectiveWrapper(p, allocatedPlanTotalMap.get(p), allocatedStretchTotalMap.get(p));
            grandPlanTotal = grandPlanTotal + allocatedPlanTotalMap.get(p);
            grandStretchTotal = grandStretchTotal + allocatedStretchTotalMap.get(p);
            grandTotals.add(objTotalWrapper);
            grandTotalsMap.put(p,objTotalWrapper);
            // Create Variance row
            Decimal planVariance = allocatedPlanTotalMap.get(p) - dssoObjPlan;
            Decimal stretchVariance = allocatedStretchTotalMap.get(p) - dssoObjStretch;
                       
            variances.add( new ObjectiveWrapper(p, planVariance, stretchVariance ) );
            variancesMap.put(p,new ObjectiveWrapper(p, planVariance, stretchVariance ));
        }
        
        ObjectiveWrapper dssoWrap = new ObjectiveWrapper(TFS_Utility.DSSO, dssoObjPlanTotal, dssoObjStretchTotal);
        dssoObjectiveWrappers.add(dssoWrap);
        dssoObjectiveWrappersMap.put(TFS_Utility.TOTAL,dssoWrap);
        summaryTotalWrapper.add(new TotalWrapper(TFS_Utility.DSSO_OBJECTIVES, dssoObjectiveWrappers , dssoObjectiveWrappersMap)); 
        ObjectiveWrapper totalWrap = new ObjectiveWrapper(TFS_Utility.TOTAL, grandPlanTotal, grandStretchTotal);
        grandTotals.add(totalWrap);
        grandTotalsMap.put(TFS_Utility.TOTAL,totalWrap);
        summaryTotalWrapper.add(new TotalWrapper(TFS_Utility.ALLOCATED, grandTotals, grandTotalsMap));    
        ObjectiveWrapper variancesWrap = new ObjectiveWrapper(TFS_Utility.TOTAL, grandPlanTotal - dssoObjPlanTotal , grandStretchTotal - dssoObjStretchTotal);     
        variances.add(variancesWrap);
        variancesMap.put(TFS_Utility.TOTAL,variancesWrap);
        summaryTotalWrapper.add(new TotalWrapper(TFS_Utility.VARIANCE, variances, variancesMap) );
        
        // Return Region Wrapper
        return tfsAreaWrapperList;
    }
    
    
    // Edit Objectives 
    //This method was modified for story : 5599 and 5895 
    public void editObjectives() {
        if(objStatus != TFS_Utility.COMPLETE && validRoles.contains(usr.TFS_SRM_Title__c)){      
            if(!isRegionSum){
                tfsAreas = retrieveTFSAreas();              
            }
            else{
                if(isVarBlock){
                    if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                        corporateList = retrieveCorporateObjectives();
                    }  
                    else{
                        regions = retrieveRegionObjectives();
                    }  
                }
                else{            
                    regions = retrieveRegions(); 
                }  
            }   
            isEdit = true; 
            isEditButtonDisplay = false; 
            isSubmitButtonDisplay = false; 
        }else if(objStatus == TFS_Utility.COMPLETE && usr.TFS_SRM_Title__c.equals(Label.Authorized_Titles_to_Edit_Completed_Objectives)){
            if(!isRegionSum){
                tfsAreas = retrieveTFSAreas();              
            }
            else{
                if(isVarBlock){
                    if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                        corporateList = retrieveCorporateObjectives();
                    }  
                    else{
                        regions = retrieveRegionObjectives();
                    }
                }
                else{            
                    regions = retrieveRegions(); 
                } 
            }   
            isEdit = true; 
            isEditButtonDisplay = false; 
            isSubmitButtonDisplay = false; 
        }else if(objStatus == TFS_Utility.COMPLETE && !usr.TFS_SRM_Title__c.equals(Label.Authorized_Titles_to_Edit_Completed_Objectives)){
            PageMessageUtils.NoPermissionavailableForCompletedObjectives(usr.TFS_SRM_Title__c);
        }    
        else{
            PageMessageUtils.NoPermissionavailable(usr.TFS_SRM_Title__c);      
        }         
    }
    
    // Calculate Objectives
    //This method was modified for story : 5599 and 5895
    public void calculate() {        
        if(validRoles.contains(usr.TFS_SRM_Title__c)){ 
            isCalculate = true;
            try {
                    if(!isRegionSum){
                        tfsAreas = retrieveTFSAreas();
                    }  
                    else{
                        if(isVarBlock){
                            if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                                corporateList = retrieveCorporateObjectives();
                            }  
                            else{
                                regions = retrieveRegionObjectives();
                            }    
                        }
                        else{            
                            regions = retrieveRegions(); 
                        }
                    }
            } catch (Exception err) {
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.DEALER_OBJ_VARIANCE_PAGE_CUST_CONTROLLER+' ', Log_Message__c = TFS_Utility.SFDC_LOG +' '+err.getStackTraceString()+' '+TFS_Utility.LINE +' '+err.getLineNumber(), Log_Type__c = TFS_Utility.APEX , Log_Severity__c = TFS_Utility.HIGH) ; 
                insert errLog;
                PageMessageUtils.error(err);
            }             
            isCalculate = false;
        }else{
            PageMessageUtils.NoPermissionavailable(usr.TFS_SRM_Title__c);            
        }  
    }    
    
    // Save updated Objectives
    //This method was modified for story : 5599 and 5895
    public void saveObjectives(){
        try { 
            //upsert only the objectives which are having parent objectives
            List<Product_objective__c> updateList = new List<Product_objective__c>();
            for(Product_objective__c po: allObjectives){
                if(po.Product_objective__c != null){
                    po.status__c = TFS_Utility.IN_PROGRESS;
                    updateList.add(po);
                }
            } 
            if(updateList != null && updateList.size() > 0){
                upsert updateList;
            }        
            if(!isRegionSum){
                tfsAreas = retrieveTFSAreas();          
            }
            else{
                if(isVarBlock){
                    if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                        corporateList = retrieveCorporateObjectives();
                    }  
                    else{
                        regions = retrieveRegionObjectives();
                    }    
                }
                else{            
                    regions = retrieveRegions(); 
                } 
            } 
            if(objStatus == 'Complete'){
                //update all objectives with status field for the selected level(Dealer,Dsso and Region)
                switchObjectives(TFS_Utility.IN_PROGRESS,updateList); 
                setObjectiveStatus();
            } 
            if(validRoles.contains(usr.TFS_SRM_Title__c)){
                isEditButtonDisplay = true;
            }
            if(validRoles.contains(usr.TFS_SRM_Title__c) && (selectedRegion == TFS_Utility.CORPORATE_SUMMARY 
                                        || (selectedRegion != TFS_Utility.CORPORATE_ALL && selectedDSSO == TFS_Utility.ALL))){
                isSubmitButtonDisplay = true;
            } 
            isEdit = false;        
       } catch (Exception err) {
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.DEALER_OBJ_VARIANCE_PAGE_CUST_CONTROLLER+' ', Log_Message__c = TFS_Utility.SFDC_LOG+' '+err.getStackTraceString()+' '+TFS_Utility.LINE+' '+err.getLineNumber(), Log_Type__c = TFS_Utility.APEX , Log_Severity__c = TFS_Utility.HIGH) ; 
            insert errLog;
            PageMessageUtils.error(err);
        }
    }
    
    // Submit updated Objectives
    //This method was modified for story : 5599 and 5895
    public void submitObjectives() {      
            try {
                checkVariancesToSubmit();
                if (!hasVariance && allObjectives != NULL && !allObjectives.isEmpty()){
                    //saveObjectives();
                    isComplete = true;
                    //upsert only the objectives which are having parent objectives
                    List<Product_objective__c> updateList = new List<Product_objective__c>();
                    for(Product_objective__c po: allObjectives){
                        if(po.Product_objective__c != null){
                            po.Status__c = TFS_Utility.COMPLETE;
                            po.Date_Submitted__c = System.today();
                            updateList.add(po);
                        }  
                    }
                   
                    if(updateList != null && updateList.size() > 0){
                        upsert updateList;
                    } 

                    if(!isRegionSum){
                        tfsAreas = retrieveTFSAreas();     
                        PageMessageUtils.submitSuccess(TFS_Utility.DEALER);   
                    }
                    else{
                        if(isVarBlock){
                            if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                                corporateList = retrieveCorporateObjectives();
                                PageMessageUtils.submitSuccess(TFS_Utility.REGION);
                            }  
                            else{
                                regions = retrieveRegionObjectives();
                                PageMessageUtils.submitSuccess(TFS_Utility.DSSO);
                            }    
                        }
                        else{            
                            regions = retrieveRegions();   
                        }       
                    } 
                    
                    //Get latest objective status
                    setObjectiveStatus();
                    
                    if(isEditButtonDisplay){
                        if(validRoles.contains(usr.TFS_SRM_Title__c)){
                            isEditButtonDisplay = true;
                        }
                        else{
                            isEditButtonDisplay = false; 
                        }
                    }
                    isSubmitButtonDisplay = false;             
                }else{ 
                        hasVariance = false;
                }                        
            } catch (Exception err) {
                Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.DEALER_OBJ_VARIANCE_PAGE_CUST_CONTROLLER+' ', Log_Message__c = TFS_Utility.SFDC_LOG+' '+err.getStackTraceString()+' '+TFS_Utility.LINE+' '+err.getLineNumber(), Log_Type__c = TFS_Utility.APEX , Log_Severity__c = TFS_Utility.HIGH) ; 
                insert errLog;
                PageMessageUtils.error(err);
            }
    }
    
    //This method will capture the latest objective status
    //This method added for story : 5599 and 5895
    public void setObjectiveStatus(){
        Boolean cflag = false;
        for(Product_objective__c po: allObjectives){
            if(po.Product_objective__c != null && po.Status__c != NULL && po.Status__c.equals(TFS_Utility.COMPLETE)){
               objStatus = TFS_Utility.COMPLETE;
               dssoTfsMfd = po;
               cflag = true;
            }
            else if(po.Product_objective__c != null && po.Status__c != NULL && po.Status__c.equals(TFS_Utility.IN_PROGRESS)){
                objStatus = TFS_Utility.IN_PROGRESS;
                dssoTfsMfd = po;
                cflag = true;
            }
            if(cFlag){
                break;
            }
        }    
    }
    
    //This method will check variance to submit the objectives.
    //This method added for story : 5599 and 5895
    public void checkVariancesToSubmit(){
        String allocatedType;
        if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
            allocatedType = TFS_Utility.REGION;    
        }
        if(selectedDSSO == TFS_Utility.ALL){
            allocatedType = TFS_Utility.DSSO;    
        }
        if(selectedTfsAreaNumber == TFS_Utility.ALL){
            allocatedType = TFS_Utility.DEALER;
        }
        if(summaryTotalWrapper != null && summaryTotalWrapper.size() > 0){
            if(summaryTotalWrapper.size() >= 3 && summaryTotalWrapper[2].totalMap != null){
                for(string p: summaryTotalWrapper[2].totalMap.keyset()){
                    if(p != TFS_Utility.TOTAL){
                        if(!(summaryTotalWrapper[2].totalMap.get(p).planAmt == 0)){
                            hasVariance = true;
                            PageMessageUtils.varianceError(allocatedType, TFS_Utility.PLAN, p, 
                                                                            summaryTotalWrapper[1].totalMap.get(p).planAmt, 
                                                                            summaryTotalWrapper[0].totalMap.get(p).planAmt, 
                                                                            summaryTotalWrapper[2].totalMap.get(p).planAmt);
                        }
                        if(!(summaryTotalWrapper[2].totalMap.get(p).stretchAmt == 0)){
                            hasVariance = true;
                            PageMessageUtils.varianceError(allocatedType, TFS_Utility.STRETCH, p, 
                                                                            summaryTotalWrapper[1].totalMap.get(p).stretchAmt, 
                                                                            summaryTotalWrapper[0].totalMap.get(p).stretchAmt, 
                                                                            summaryTotalWrapper[2].totalMap.get(p).stretchAmt);
                        }
                    }
                }
            } 
        }
    }
    
    //This method will update teh status filed with in-progress to all DSSO level objectis at org and region level objectives
    //This method added for the story : 5599 and 5895
    public void switchObjectives(string status,List<Product_objective__c> pObjList){
        List<Account> accList = new List<Account>();
        List<Product_Objective__c> updatePObjList;
        if(selectedDSSO == TFS_Utility.ALL && selectedRegion != TFS_Utility.CORPORATE_ALL 
                                           && selectedRegion != TFS_Utility.ALL){
            updatePObjList = [SELECT Id,Status__c FROM Product_Objective__c 
                                                                        WHERE Fiscal_Year__c =:selectedYear
                                                                        AND Month__c =:selectedMonth 
                                                                        AND type__c = :TFS_Utility.DSSO 
                                                                        AND product_objective__c != null 
                                                                        AND Name IN :productList 
                                                                        AND id not in :pObjList];
        }
        else if(selectedTfsAreaNumber != '0' && selectedTfsAreaNumber != null){
            accList = [select id,Name from account where DSSO_Name__c = :selectedDsso];
            updatePObjList = [SELECT Id,Status__c FROM Product_Objective__c 
                                                                        WHERE Fiscal_Year__c =:selectedYear
                                                                        AND Month__c =:selectedMonth 
                                                                        AND Name IN :productList
                                                                        AND account__c in :accList 
                                                                        AND product_objective__c != null 
                                                                        AND id not in :pObjList];
        }

        if(updatePObjList != null && updatePObjList.size() > 0){
            for(Product_Objective__c po : updatePObjList){
                po.status__c = status;
            }
            
            update updatePObjList;  
        }          
    }
    
    // Cancel action
    //This method was modified for the story : 5599 and 5895
    public void cancel() {
        isEdit = false;
        try {
            if(!isRegionSum){               
                tfsAreas = retrieveTFSAreas();          
            }
            else{   
                if(isVarBlock){
                    if(selectedRegion == TFS_Utility.CORPORATE_SUMMARY){
                        corporateList = retrieveCorporateObjectives();
                    }  
                    else{
                        regions = retrieveRegionObjectives();
                    }    
                }
                else{            
                    regions = retrieveRegions(); 
                }
            }   
            if(validRoles.contains(usr.TFS_SRM_Title__c)){
                isEditButtonDisplay = true;
            } 
            if(validRoles.contains(usr.TFS_SRM_Title__c) && (selectedRegion == TFS_Utility.CORPORATE_SUMMARY || 
                            (selectedRegion != TFS_Utility.CORPORATE_ALL && selectedDSSO == TFS_Utility.ALL))){
                isSubmitButtonDisplay = true;
            }        
         } catch (Exception err) {
            Error_Log__c errLog = new Error_Log__c(Log_Name__c = TFS_Utility.DEALER_OBJ_VARIANCE_PAGE_CUST_CONTROLLER+' ', Log_Message__c = TFS_Utility.SFDC_LOG+' '+err.getStackTraceString()+' '+TFS_Utility.LINE+' '+err.getLineNumber(), Log_Type__c = TFS_Utility.APEX , Log_Severity__c = TFS_Utility.HIGH) ; 
            insert errLog;
            PageMessageUtils.error(err);
        }
    }
  
    // Method to calculate the total paln and stretch per product
    //This method added for the story : 5599 and 5895
    public Map<string,ObjectiveWrapper> calculateTotalRegion(List<regWrapper> regWrapList){
        if(regWrapList == null){
            return null;
        }
        Map<String, Decimal> prodPlanTotal = new Map<String,Decimal>();
        Map<String, Decimal> prodStretchTotal = new Map<String,Decimal>();
        for(regWrapper oDswrp : regWrapList){
            Decimal totalplan1 = 0;
            Decimal totalstretch1 = 0; 
            if(oDswrp.objWrapperMap.values() != NULL){   
                for(ObjectiveWrapper obj1 : oDswrp.objWrapperMap.values()){
                    if(prodPlanTotal != NULL && prodPlanTotal.containskey(obj1.productName) 
                                             &&  prodPlanTotal.get(obj1.productName)!= NULL){//
                       if(obj1.productName != TFS_Utility.TOTAL){ 
                           Decimal p = obj1.objective.Plan__c != null ? obj1.objective.Plan__c : 0; 
                           totalplan1 =  prodPlanTotal.get(obj1.productName) + p; 
                       }
                       if(obj1.productName== TFS_Utility.TOTAL){
                           Decimal p = obj1.planAmt != null ? obj1.planAmt : 0;
                           totalplan1 =  prodPlanTotal.get(obj1.productName) + p; 
                       }    
                       prodPlanTotal.put(obj1.productName,totalplan1);
                    }else{
                        if(obj1.productName!= TFS_Utility.TOTAL){   
                            prodPlanTotal.put(obj1.productName,obj1.objective.Plan__c);
                        }
                        if(obj1.productName== TFS_Utility.TOTAL){
                            prodPlanTotal.put(obj1.productName,obj1.planAmt); 
                        }     
                    }
                    if(prodStretchTotal!= NULL && prodStretchTotal.containskey(obj1.productName)  
                                               && prodStretchTotal.get(obj1.productName) != NULL){ //
                        if(obj1.productName!= TFS_Utility.TOTAL){ 
                            Decimal s = obj1.objective.Stretch__c != null ? obj1.objective.Stretch__c : 0;
                            totalstretch1 =  prodStretchTotal.get(obj1.productName) + s; 
                        }
                        if(obj1.productName== TFS_Utility.TOTAL){
                            Decimal s = obj1.stretchAmt != null ? obj1.stretchAmt : 0;
                            totalstretch1 =  prodStretchTotal.get(obj1.productName) + s; 
                        }   
                        prodStretchTotal.put(obj1.productName,totalstretch1);
                    }else{
                          if(obj1.productName!= TFS_Utility.TOTAL){   
                            prodStretchTotal.put(obj1.productName,obj1.objective.Stretch__c);
                          }
                          if(obj1.productName== TFS_Utility.TOTAL){
                            prodStretchTotal.put(obj1.productName,obj1.stretchAmt); 
                          }
                    }
                }
            }
        }
        Map<string,ObjectiveWrapper> objWrapMap = new Map<string,ObjectiveWrapper>();
        List<String> products = new List<String>(productList);
        products.add(TFS_Utility.TOTAL);
        for (String p : products) {
            objWrapMap.put(p,new ObjectiveWrapper (p, prodPlanTotal.get(p), prodStretchTotal.get(p)));
        }
        return objWrapMap;
    }
    
    // Method to calculate the total DSSO
    public Map<string,ObjectiveWrapper> calculateTotalDSSO(List<DssoWrapper> dssos){
        if(dssos == null){
            return null;
        }
        
        Map<String, Decimal> prodPlanTotal = new Map<String,Decimal>();
        Map<String, Decimal> prodStretchTotal = new Map<String,Decimal>();
        for(DssoWrapper oDswrp : dssos){
            Decimal totalplan1 = 0;
            Decimal totalstretch1 = 0; 
            if(oDswrp.objWrapperList!= NULL){   
                for(ObjectiveWrapper obj1 :oDswrp.objWrapperList){
                    if(prodPlanTotal != NULL && prodPlanTotal.containskey(obj1.productName) 
                                             &&  prodPlanTotal.get(obj1.productName)!= NULL){//
                       if(obj1.productName != TFS_Utility.TOTAL){  
                           Decimal p = obj1.objective.Plan__c != null ? obj1.objective.Plan__c : 0;
                           totalplan1 =  prodPlanTotal.get(obj1.productName) + p; 
                       }
                       if(obj1.productName == TFS_Utility.TOTAL){
                           Decimal p = obj1.planAmt != null ? obj1.planAmt : 0;
                           totalplan1 =  prodPlanTotal.get(obj1.productName) + p; 
                       }    
                       prodPlanTotal.put(obj1.productName,totalplan1);
                    }else{
                          if(obj1.productName!= TFS_Utility.TOTAL){   
                            prodPlanTotal.put(obj1.productName,obj1.objective.Plan__c);
                          }
                          if(obj1.productName== TFS_Utility.TOTAL){
                            prodPlanTotal.put(obj1.productName,obj1.planAmt); 
                          }     
                    }
                    if(prodStretchTotal!= NULL && prodStretchTotal.containskey(obj1.productName)  
                                               && prodStretchTotal.get(obj1.productName) != NULL){ //
                        if(obj1.productName!= TFS_Utility.TOTAL){
                            Decimal s = obj1.objective.Stretch__c != null ? obj1.objective.Stretch__c : 0; 
                            totalstretch1 =  prodStretchTotal.get(obj1.productName) + s; 
                        }
                        if(obj1.productName== TFS_Utility.TOTAL){
                            Decimal s = obj1.stretchAmt != null ? obj1.stretchAmt : 0;
                            totalstretch1 =  prodStretchTotal.get(obj1.productName) + s; 
                        }   
                        prodStretchTotal.put(obj1.productName,totalstretch1);
                    }else{
                          if(obj1.productName!= TFS_Utility.TOTAL){   
                            prodStretchTotal.put(obj1.productName,obj1.objective.Stretch__c);
                          }
                          if(obj1.productName== TFS_Utility.TOTAL){
                            prodStretchTotal.put(obj1.productName,obj1.stretchAmt); 
                          }
                    }
                }
            }
        }
        Map<string,ObjectiveWrapper> objWrapMap = new Map<string,ObjectiveWrapper>();
        List<String> products = new List<String>(productList);
        products.add('Total');
        for (String p : products) {
            objWrapMap.put(p,new ObjectiveWrapper (p, prodPlanTotal.get(p), prodStretchTotal.get(p)));
        }
        return objWrapMap;
    }
    
    // Method to create Corporate wrapper
    public List<RegionWrapper> createCorporateWrapper(List<RegionWrapper> regionWrapperList){
        Map<String, Decimal> prodPlanTotal = new Map<String,Decimal>();
        Map<String, Decimal> prodStretchTotal = new Map<String,Decimal>();
        List<DssoWrapper> nationalDssoList = new List<DssoWrapper>();
        TotalWrapper totalWrappertemp; 
        for(RegionWrapper rWrap: regionWrapperList){
            for(DssoWrapper dsWrap: rWrap.dssos){
                if(dsWrap.dssoName != NULL && dsWrap.dssoName.contains('Total')){
                 Decimal totalplan1 = 0;
                 Decimal totalstretch1 = 0; 
                  for(ObjectiveWrapper objWrap :dsWrap.objWrapperList){
                    if(prodPlanTotal!= NULL && !prodPlanTotal.isEmpty() && prodPlanTotal.get(objWrap.productName) != NULL){//
                       if(objWrap.planAmt!= NULL){
                        totalplan1 =  prodPlanTotal.get(objWrap.productName) + objWrap.planAmt; 
                        prodPlanTotal.put(objWrap.productName,totalplan1);                     
                       }
                        
                     }else{
                          if(objWrap.planAmt!= NULL){  
                            prodPlanTotal.put(objWrap.productName,objWrap.planAmt); 
                         }  
                         else{
                             prodPlanTotal.put(objWrap.productName,0); 
                         }     
                     }                    
                     if(prodStretchTotal!= NULL && !prodStretchTotal.isEmpty() && prodStretchTotal.get(objWrap.productName) != NULL){ //
                          if(objWrap.stretchAmt!= NULL){
                            totalstretch1 =  prodStretchTotal.get(objWrap.productName) + objWrap.stretchAmt; 
                             prodStretchTotal.put(objWrap.productName,totalstretch1);
                          }  
                           
                     }else{
                           if(objWrap.stretchAmt != NULL){
                               prodStretchTotal.put(objWrap.productName,objWrap.stretchAmt); 
                           }  
                           else{
                               prodStretchTotal.put(objWrap.productName,0);
                           }  
                     }
                 }              
               }
            }
        }
        Map<string,ObjectiveWrapper> nationalObjWrapMap = new Map<string,ObjectiveWrapper>();
        List<String> products = new List<String>(productList);
        products.add('Total');
        for (String p : products) {
            nationalObjWrapMap.put(p, new ObjectiveWrapper (p, prodPlanTotal.get(p), prodStretchTotal.get(p)));
        }
        nationalDssoList.add( new DssoWrapper (TFS_Utility.CORPORATE , TFS_Utility.BLANK , TFS_Utility.CORPORATE +' '+TFS_Utility.TOTAL, TFS_Utility.BLANK, nationalObjWrapMap.values(),nationalObjWrapMap));
        RegionWrapper regionWrapper = new RegionWrapper(TFS_Utility.BLANK, TFS_Utility.CORPORATE, nationalDssoList, totalWrappertemp);
        regionWrapperList.add(regionWrapper);
        return regionWrapperList;
     }
     
    
    // Get the DSSO List
    public list<SelectOption> getDssoList() {
        list<SelectOption> options = new list<SelectOption>();
        List<Account > dssos = new List<Account>();
        if(selectedregion != TFS_Utility.ALL_REGION)
            dssos = [SELECT Id,Name,parent.name, type, parent.type FROM Account where parent.type = :TFS_Utility.REGION AND Parent.Id=: selectedregion AND type= :TFS_Utility.DSSO];
        else
            dssos = [SELECT Id,Name,parent.name, type, parent.type FROM Account where parent.type = :TFS_Utility.REGION AND type = :TFS_Utility.DSSO];
        options.add(new selectoption(TFS_Utility.ZERO, TFS_Utility.NONE));
        dssos.sort();
        for (Account Acc : dssos ) {
            options.add(new selectoption(Acc.Name, Acc.Name) );
        }

        if(selectedregion!= NULL && selectedregion!= TFS_Utility.ZERO){
            options.add(new selectoption(TFS_Utility.ALL, TFS_Utility.ALL) );
        }        
        if(selectedregion == TFS_Utility.ALL_REGION){
            for(integer i=0;i<options.Size();i++){
                   if(options[i].getValue() == TFS_Utility.ALL)
                           options.remove(i);
            }
        }       
        return options;
    }
    
    // Get Region List
    public list<SelectOption> getRegionList() {
        list<SelectOption> options = new list<SelectOption>();
        List<Account > dssos = [SELECT Id,Name FROM Account where type = :TFS_Utility.REGION ORDER BY Region_Sorting__c ASC];        
        options.add(new selectoption(TFS_Utility.ZERO, TFS_Utility.NONE));
        for (Account Acc : dssos ) {
            options.add(new selectoption(Acc.id, Acc.Name ) );
        }
        options.add(new selectoption(TFS_Utility.ALL_REGION, TFS_Utility.ALL_REGION) );
        options.add(new selectoption(TFS_Utility.CORPORATE_ALL, TFS_Utility.CORPORATE_ALL));
        options.add(new selectoption(TFS_Utility.CORPORATE_SUMMARY, TFS_Utility.CORPORATE_SUMMARY));      
        return options;
    }
    
    //Fetch TFS areas numbers
    public list<SelectOption> getAreaNumberList() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new selectoption(TFS_Utility.ZERO, TFS_Utility.NONE));
        List<Account > tfsArea= [SELECT TFS_Area_Number__c FROM Account where Area_ID__c !=null limit 10];
        for (Account a : tfsArea) {
            options.add(new selectoption(a.TFS_Area_Number__c , a.TFS_Area_Number__c ) );
            
        }
       return options;
    }
    
    //  Create list of months
    public list<SelectOption> getMonthList() {
        list<SelectOption> options = new list<SelectOption>();

        for (String monthname: TFS_Utility.monthMap.keySet()){
            options.add(new selectoption(monthname,monthname) );
        } 
        return options;
    }
    // Method call for Export Excel
    public PageReference excelButton() {
        //setValuesforExcelPDF();
        PageReference pr = page.DealerObjectiveToExcelPage;
        return setParametersTopage(pr);
    }
    
    // Method call for PDF
    public PageReference pdfButton() {
        //setValuesforExcelPDF();
        PageReference pr = page.DealerObjectiveToPDFPage;
        return setParametersTopage(pr);
    }
    
    public Pagereference setParametersTopage(Pagereference pr){
        pr.getParameters().put(TFS_Utility.YEAR, selectedYear  );
        pr.getParameters().put(TFS_Utility.MONTH, selectedMonth );
        pr.getParameters().put(TFS_Utility.CATEGORY,selectedCategory );
        pr.getParameters().put(TFS_Utility.REGION, selectedregion);
        pr.getParameters().put(TFS_Utility.DSSO, selectedDsso);
        pr.getParameters().put(TFS_Utility.TFSAREA,selectedTfsAreaNumber );
        pr.getParameters().put(TFS_Utility.ISEXPORT,TFS_Utility.TRUE_FLAG);
        pr.setRedirect(true);
        
        return pr;
    }

    // Method call to set values for PDF action
    public void setValuesforExcelPDF(){
        if(!selectedregion.startswith(TFS_Utility.CORPORATE)){             
            if (selectedTfsAreaNumber == TFS_Utility.ZERO){      
                isRendered = false;
            }                         
            else if (selectedTfsAreaNumber == TFS_Utility.SUMMARY) {      
                isRendered = true;      
                isRenderSummary = true;     
                isSummary = true;                     
            } 
            else {        
                isRendered = true;      
                isSummary = false;      
            }             
        
            List<String> allTfsAreas = new List<String>();
            list<Account> listTFSAreaNumber = [select TFS_Area_Number__c from account where DSSO_Name__c=: selectedDsso AND TFS_Area_Number__c!=null]; 
            listTFSAreaNumber.sort();
            SetTFSAreaNumber.clear();       
            for (Account TFSAreaNumber : listTFSAreaNumber) {       
                SetTFSAreaNumber.add(TFSAreaNumber.TFS_Area_Number__c);     
            }
            if (selectedTfsAreaNumber != TFS_Utility.ALL && selectedTfsAreaNumber != TFS_Utility.SUMMARY 
                                                         && selectedTfsAreaNumber != TFS_Utility.ZERO ){
                allTfsAreas.add(selectedTfsAreaNumber);  
            }  
            else{
                allTfsAreas = new List<String>(SetTFSAreaNumber);
            }
            loadObjectives();  
      }
      if(selectedregion.startswith(TFS_Utility.CORPORATE) || (selectedDsso == TFS_Utility.ALL && selectedTfsAreaNumber == TFS_Utility.BLANK)){
            if(selectedDsso == TFS_Utility.ALL){
               selectedTfsAreaNumber = TFS_Utility.BLANK;
               isRendered = true;
               isSummary = false;
               loadDSSOObjectives();
               regions = retrieveRegions();  
               isRegionSum = true;            
            }
       }
    }
    // Method to fetch TFS Area Number values
    public list<SelectOption> getTFSAreaNumberList() {

        SetTFSAreaNumber.clear();
        list<SelectOption> options = new list<SelectOption>();        
        options.add(new selectoption(TFS_Utility.ZERO, TFS_Utility.NONE)); 
       
        if (selectedDsso != TFS_Utility.ZERO && selectedDsso != TFS_Utility.ALL) {
            list<Account> listTFSAreaNumber = [select TFS_Area_Number__c from account 
                                                                         where DSSO_Name__c=: selectedDsso 
                                                                         AND TFS_Area_Number__c!=null  
                                                                         AND TFS_Relationship__c IN :tfsrelationshipSet 
                                                                         AND status__c = :isActive];
            listTFSAreaNumber.sort();
            for (Account TFSAreaNumber : listTFSAreaNumber) {
                SetTFSAreaNumber.add(TFSAreaNumber.TFS_Area_Number__c);
            }

            for(String TFSAreaNumber : SetTFSAreaNumber){
                options.add(new selectoption(TFSAreaNumber, TFSAreaNumber) );
            }
        }        
        options.add(new selectoption(TFS_Utility.ALL, TFS_Utility.DSSO_ALL) );
        options.add(new selectoption(TFS_Utility.SUMMARY, TFS_Utility.DSSO_SUMMARY) );
        
        return options;
    }
    
    // Method to fetch the List of years
    public List<SelectOption> years {
        get {            
            List<SelectOption> options = new List<SelectOption>();
            Map <string, FinancialYear__c> finYrs = FinancialYear__c.getall();   // returns a map            
            // remove the inactive years.
            List <FinancialYear__c> activeYears = new List <FinancialYear__c> ();
            for (FinancialYear__c yr: finYrs.values()) {
                if (yr.Active__c == true) {
                    activeYears.add(yr);
                }
            }            
            for (FinancialYear__c y: activeYears ) {
                options.add(new SelectOption(y.Name,y.Name));
            }
            // Lists always sort ascending
            options.sort();
            List<SelectOption> optionsDesc = new List<SelectOption>();
            for(Integer i = options.size()-1; i>=0;i--) 
                optionsDesc.add(options.get(i));
            return optionsDesc;
            
        } 
        set;
    }
    
    //Fetch active products for selected year and month
    //This method was added for story : 5599 and 5895
    public List<String> getActiveProducts(){
        List<Product__c> pList = new List<Product__c>(); 
        //Fetching year value from SelectedYear(ex: FY18, result:18)
        integer sFYear = integer.valueof(selectedYear.substring(2));
        integer sMonth = TFS_Utility.monthMap.get(selectedMonth);
        integer sYear;
        
        integer yearFromLabel = label.year != null ? integer.valueOf(label.year) : 2000;
        if(sMonth > 3){
            sYear = yearFromLabel + sFYear-1;
        }else{
            sYear = yearFromLabel + sFyear;
        }  
        
        for(Product__c prd : [SELECT id,Name,Start_Date__c,End_Date__c,Type__c FROM Product__c 
                                                                              Where Type__c=:category 
                                                                              Order By Name]){
            integer sdYear = prd.start_date__c.year();
            integer sdMonth = prd.start_date__c.month();
            if(prd.end_date__c == null){
                if(sdYear < sYear || (sdYear == sYear && sdMonth <= sMonth)){
                    pList.add(prd);
                }
            }    
            else{
                integer edYear = prd.end_date__c.year();
                integer edMonth = prd.end_date__c.month();
                if(sdYear == sYear && sdMonth == sMonth){
                    pList.add(prd);
                }
                else if(sdYear == sYear && sdMonth < sMonth && edYear == sYear && edMonth >= sMonth){
                    pList.add(prd);
                }
                else if(sdYear == sYear && sdMonth < sMonth && edYear > sYear){
                    pList.add(prd);
                }
                else if(sdyear < syear && ((edYear == sYear && edMonth >= sMonth) || edYear > sYear)){
                    pList.add(prd);
                }
            }    
        }

        return getAllProducts(pList);
    }
    
    //Get dependent values from Object_Name__C picklist based on active product
    public List<string> getAllProducts(List<Product__c> pList){
        productMap = new Map<string,string>();
        List<String> pAllList = new List<String>();
        
        Map<String,List<String>> dependentValues = getDependentOptionsImpl('Product__c', 'Product_Name__c', 'Objective_Name__c'); 
        if(dependentValues != NULL && !dependentValues.isEmpty()){
            for(Product__c productRecord : pList){
                if(dependentValues.get(productRecord.Name)!= NULL && !dependentValues.get(productRecord.Name).isEmpty()){
                    //pAllList.addAll(dependentValues.get(productRecord.Name));
                    for(String pName : dependentValues.get(productRecord.Name)){
                        productMap.put(pName+ TFS_Utility.BLANK_TOTAL,productRecord.id);  
                        pAllList.add(pName+ TFS_Utility.BLANK_TOTAL);  
                    }
                }               
            }           
        }
        pAllList.sort();
        return pAllList;
    }
    
    // Create Dealer Level Objectives   
    public Product_Objective__c createDealerObjective(string prod,String dealerId,string dssoObjKey) {
        Product_Objective__c obj = new Product_Objective__c();
        obj.name = prod;
        obj.product__c = ProductMap.containskey(prod) ? ProductMap.get(prod) : null;
        obj.plan__c = 0;
        obj.stretch__c = 0;
        obj.Fiscal_Year__c = selectedYear;
        obj.month__c = selectedMonth; 
        obj.Status__c = TFS_Utility.IN_PROGRESS;        
        obj.account__c = dealerId;
        obj.Type__c = TFS_Utility.DEALER;
        obj.product_objective__c = dssoObjkey;
        
        return obj;      
    }
    
     // Create DSSO Objectives
    public Product_Objective__c createDSSOObjective(string prod,String dssoId,string regionObjKey) {
        Product_Objective__c obj = new Product_Objective__c();
        obj.name = prod;
        obj.product__c = ProductMap.containskey(prod) ? ProductMap.get(prod) : null;
        obj.plan__c = 0;
        obj.stretch__c = 0;
        obj.Fiscal_Year__c = selectedYear;
        obj.month__c = selectedMonth; 
        obj.Status__c = TFS_Utility.IN_PROGRESS;
        obj.account__c = dssoId;
        obj.Type__c = TFS_Utility.DSSO;
        obj.product_objective__c = regionObjKey;
         
        return obj;      
    } 
    
     // Create DSSO Objectives
    public Product_Objective__c createRegionObjective(string prod,String regionId,string corpObjKey) {
        Product_Objective__c obj = new Product_Objective__c();
        obj.name = prod;
        obj.product__c = ProductMap.containskey(prod) ? ProductMap.get(prod) : null;
        obj.plan__c = 0;
        obj.stretch__c = 0;
        obj.Fiscal_Year__c = selectedYear;
        obj.month__c = selectedMonth; 
        obj.Status__c = TFS_Utility.IN_PROGRESS;
        obj.account__c = regionId;
        obj.Type__c = TFS_Utility.REGION;
        obj.product_objective__c = corpObjKey;
         
        return obj;      
    } 
    
    
    // Wrapper Class that contains the list of Dealers per TFS Area
    public class TFSAreaWrapper {
        public String tfsAreaNumber {get; set;}
        public String tfsASM {get;set;}
        public List<DealerWrapper> dealers {get; set;}
        public TotalWrapper totalWrapper {get; set;}
        public Boolean hasASM{get;set;}
        
        public TFSAreaWrapper (String tfsAreaNumber, List<DealerWrapper> dealers, TotalWrapper totalWrapper){
            this.tfsAreaNumber = tfsAreaNumber;
            this.dealers = dealers;
            this.totalWrapper = totalWrapper;
            if(this.dealers != NULL && !this.dealers.isEmpty() && this.dealers[0].objWrapperList != NULL &&         
              !this.dealers[0].objWrapperList.isEmpty() && this.dealers[0].objWrapperList[0].objective != NULL &&       
              this.dealers[0].objWrapperList[0].objective.Account__r != NULL && this.dealers[0].objWrapperList[0].objective.Account__r.ASM__c != NULL ){        
                this.tfsASM = dealers[0].objWrapperList[0].objective.Account__r.ASM__c;     
                hasASM = true;      
              }else{        
                 this.tfsASM = '';//dealers[0].objWrapperList[0].objective.Account__r.ASM__c;       
                 this.hasASM = false;       
              }
        } 
    }
    
    // Wrapper Class that contains the list of Objectives per Dealer
    public class DealerWrapper{
        public String tfsAreaNumber {get; set;}
        public String dealerId {get; set;}
        public String dealerName {get; set;}
        public String dealerNumber {get; set;}
        public List<ObjectiveWrapper> objWrapperList {get; set;} 
        public Map<string,ObjectiveWrapper> objWrapperMap{get;set;}
        
        public DealerWrapper (String tfsAreaNumber, String dealerId ,  String dealerName, String dealerNumber,List<ObjectiveWrapper> objWrapperList,Map<string,ObjectiveWrapper> objWrapperMap){
            this.tfsAreaNumber = tfsAreaNumber;
            this.dealerId = dealerId;
            this.dealerName = dealerName;
            this.dealerNumber = dealerNumber;
            this.objWrapperList = objWrapperList;
            this.objWrapperMap = objWrapperMap;
        } 
    }
    
    // Wrapper class for Total wrapper
    public class TotalWrapper {
        public String rowName {get; set;} // TODO - change name
        public List<ObjectiveWrapper> totalList {get; set;}
        public Map<String,ObjectiveWrapper> totalMap {get; set;}
        //public String totalNvs {get; set;} 
        
        public TotalWrapper (String rowName , List<ObjectiveWrapper> totalList, Map<String,ObjectiveWrapper> totalMap){
            this.rowName = rowName ;
            this.totalList = totalList;
            this.totalMap = totalMap;
            //this.totalNvs = totalNvs;
        } 
        
    }   
    
    // Wrapper class for Objective Wrapper
    public class ObjectiveWrapper {
        public String objectiveId {get; set;}
        public String productName {get; set;} 
        public Decimal planAmt {get; set;} 
        public Decimal stretchAmt {get; set;} 
        public Product_Objective__c objective {get; set;}
        
        public ObjectiveWrapper (String productName, Decimal planAmt, Decimal stretchAmt){
            this.productName = productName;
            this.planAmt = planAmt;
            this.stretchAmt = stretchAmt;
        } 
        
        public ObjectiveWrapper (String objectiveId, String productName, Decimal planAmt, Decimal stretchAmt, Product_Objective__c objective){
            this.objectiveId = objectiveId;
            this.productName = productName;
            this.planAmt = planAmt;
            this.stretchAmt = stretchAmt;
            this.objective = objective;
        } 
    }
    
    // Wrapper Class that contains the list of Dssos per Region
    public class CorporateWrapper {
        public String corporateId {get; set;}
        public String corporateName {get; set;}
        public List<regWrapper> regionList{get; set;}
        public CorporateWrapper(String corpId, String corpName, List<regWrapper> regList){
            this.corporateId = corpId;
            this.corporateName = corpName;
            this.regionList = regList;
        } 
    }
    
    // Wrapper Class that contains the list of Objectives per Dsso
    public class regWrapper {
        public String corporateName {get; set;}
        public String regionId {get; set;}
        public String regionName {get; set;}
        public Map<string,ObjectiveWrapper> objWrapperMap {get; set;} 

        public regWrapper(String corpName,String regId,String regName,Map<string,ObjectiveWrapper> objWrapperMap){
            this.corporateName = corpName;
            this.regionId = regId ;
            this.regionName = regName;
            this.objWrapperMap = objWrapperMap;
        } 
    }
    
    // Wrapper Class that contains the list of Dssos per Region
    public class RegionWrapper {
        public String regionId {get; set;}
        public String regionName {get; set;}
        public List<DssoWrapper> dssos {get; set;}
        public TotalWrapper totalWrapper {get; set;}
        public RegionWrapper (String regionId, String regionName, List<DssoWrapper> dssos, TotalWrapper totalWrapper){
            this.regionId = regionId;
            this.regionName = regionName;
            this.dssos = dssos;
            this.totalWrapper = totalWrapper;
        } 
    }
    // Wrapper Class that contains the list of Objectives per Dsso
    public class DssoWrapper {
        public String regionName {get; set;}
        public String dssoId {get; set;}
        public String dssoName {get; set;}
        public String dssoNumber {get; set;}
        //public String nvsObjective {get; set;}
        public List<ObjectiveWrapper> objWrapperList {get; set;} 
        public Map<string,ObjectiveWrapper> objWrapperMap {get; set;} 

        public DssoWrapper (String regionName , String dssoId ,  String dssoName, String dssoNumber, List<ObjectiveWrapper> objWrapperList,Map<string,ObjectiveWrapper> objWrapperMap){
            this.regionName = regionName ;
            this.dssoId = dssoId ;
            this.dssoName = dssoName;
            this.dssoNumber = dssoNumber;
            //this.nvsObjective = nvsObjective;
            this.objWrapperList = objWrapperList;
            this.objWrapperMap = objWrapperMap;
        } 
    }
    
    //Custom sort
    //This wrapper class added for story : 5599 and 5895
    public class ProductObjectiveWrapper implements Comparable {

        public Product_Objective__c obj;
        
        // Constructor
        public ProductObjectiveWrapper(Product_Objective__c obj) {
            this.obj = obj;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ProductObjectiveWrapper compareToObj = (ProductObjectiveWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (obj.Account__c > compareToObj.obj.account__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (obj.Account__c < compareToObj.obj.Account__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    //wrapper class
    //This wrapper class added for story : 5599 and 5895
    public class PicklistEntryWrapper{
    
        public PicklistEntryWrapper(){            
        }
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }
    
    //Get Dependent picklist values
    //This method added for story : 5599 and 5895
    public Map<String,List<String>> getDependentOptionsImpl(String objName, String contrfieldName, String depfieldName){
        
        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();        
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(objectName)){
            return null;
        }
        
        Schema.SObjectType objType = objGlobalMap.get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        integer depEntriesSize = depEntries.size();
        for(Integer dependentIndex=0; dependentIndex < depEntriesSize; dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor == null || objJson.validFor == TFS_Utility.BLANK){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        return objResults;
    }
    
    //Get product objective query
    public string getProdObjQuery(){
        string query = 'SELECT Id,Name,Account__c, Account__r.Name,Account__r.Parent.name,Account__r.ASM__c,'
                       +'Product__c,Product__r.name , Stretch__c,Plan__c,Product_objective__c,Status__c,'
                       +'LastModifiedById, LastModifiedBy.Name,lastmodifieddate FROM Product_Objective__c ';
                       
        return query;
    }  
    
    //Get product objective query
    public string commonWhereClause(string query){
        String finalQuery = query + 'Where Fiscal_Year__c =:selectedYear AND Month__c=:selectedMonth '
                             +'AND Product__c != null AND product__r.Type__c=:category '
                             +'And Name in :productList ';                 
        return finalQuery;
    } 
}