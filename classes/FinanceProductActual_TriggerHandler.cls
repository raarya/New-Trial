/********************************************************************************************
* Class Name: FinanceProductActual_TriggerHandler
* Author: Rajeev Arya (Deloitte)
* Date: [04/21/2017]
* Requirement Description: User story W-005091 - rollup sum of plan and stretch on actuals
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public class FinanceProductActual_TriggerHandler {
    
  FinanceProductActual_TriggerHelper helper = new FinanceProductActual_TriggerHelper();
  /**
  * onInsert
  * This method is called during the insert of Finance Product Actual
  */
  public void onBeforeInsert(list<Finance_Product_Actual__c> lstFinProdAct)
  {
    helper.populateTriggerPlanAndStretch (lstFinProdAct);  
  }
  
   /**
  * onUpdate
  * This method is called during the update of Finance Product Actual
  */
  public void onBeforeUpdate(list<Finance_Product_Actual__c> lstFinProdAct)
  {
    helper.populateTriggerPlanAndStretch (lstFinProdAct);  
  }
}