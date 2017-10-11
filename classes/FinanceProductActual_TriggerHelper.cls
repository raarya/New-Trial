/********************************************************************************************
* Class Name: FinanceProductActual_TriggerHelper
* Author: Rajeev Arya (Deloitte)
* Date: [04/21/2017]
* Requirement Description: User story W-005091 - rollup sum of plan and stretch on actuals
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class FinanceProductActual_TriggerHelper {
    
    BypassTriggerLogicSettings__c customSetting = BypassTriggerLogicSettings__c.getInstance(UserInfo.getUserId());
    public Boolean bolExceptionFlag = false;
    public void populateTriggerPlanAndStretch(list<Finance_Product_Actual__c> lstFinProdAct){
        if(customSetting.Bypassed_Trigger_Methods__c == null || !customSetting.Bypassed_Trigger_Methods__c.contains('populateTriggerPlanAndStretch')){
               
            for(Finance_Product_Actual__c fpa : lstFinProdAct){
                if(fpa.Product_Objective__c != null){
                    fpa.Trigger_Plan__c = fpa.Plan__c;
                    fpa.Trigger_Stretch__c = fpa.Stretch__c;
                }
            }
        }     
    }
}