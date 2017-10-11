public with sharing class DealerConnect_LastDataLoads {
    @AuraEnabled
    public static List<Insurance_Actual__c> getInsuranceDates() {
        User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
        return [SELECT Id, Last_Data_Load__c
                       from Insurance_Actual__c where Last_Data_Load__c!=null and Account__c = :usr.accountId
                order by Last_Data_Load__c desc  LIMIT 1
                       
                ];
    }
    @AuraEnabled
     public static List<Finance_Actual__c> getFinanceDates() {
        User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
        return [SELECT Id, Last_Data_Load__c
                       from Finance_Actual__c where Last_Data_Load__c!=null and Account__c = :usr.accountId
                order by Last_Data_Load__c desc  LIMIT 1        
                ];
    }
   @AuraEnabled
     public static List<Held_Offering__c> getHeldOfferingDates() {
        User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
        return [SELECT Id, CreatedDate
                       from Held_Offering__c where Account__c = :usr.accountId
                order by CreatedDate desc LIMIT 1        
                ];
    }

}