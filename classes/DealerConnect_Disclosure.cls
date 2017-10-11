public with sharing class DealerConnect_Disclosure {
@AuraEnabled public List<Finance_Actual__c> getFinanceDates{get;set;}
@AuraEnabled public List<Insurance_Actual__c> getInsuranceDates{get;set;}
@auraEnabled public List<Held_Offering__c> getHeldOfferingDates{get;set;}

@AuraEnabled
public static DealerConnect_Disclosure initClass(){
        DealerConnect_Disclosure obj = new DealerConnect_Disclosure();
        User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
        obj.getInsuranceDates = [SELECT Id, Last_Data_Load__c
                       from Insurance_Actual__c where Last_Data_Load__c!=null and Account__c = :usr.accountId
                order by Last_Data_Load__c desc  LIMIT 1
                ];
        obj.getFinanceDates = [SELECT Id, Last_Data_Load__c
                       from Finance_Actual__c where Last_Data_Load__c!=null and Account__c = :usr.accountId
                order by Last_Data_Load__c desc  LIMIT 1]; 
        obj.getHeldOfferingDates = [SELECT Id, As_Date__c,As_Of_Date__c
                       from Held_Offering__c where As_Date__c!=null and Account__c = :usr.accountId
                order by As_Date__c desc LIMIT 1        
                ] ;       
        return obj ;
    }
}