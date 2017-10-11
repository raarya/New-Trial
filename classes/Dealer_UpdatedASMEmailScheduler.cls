/********************************************************************************************************
* @author         Deloitte
* @description    Dealer_UpdatedASMEmailScheduler Apex class used to schedule UpdateASMDealerEmailBatch batch Class
* @date           2017-02-10
*********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
                                                                        Initial version
*/
global class Dealer_UpdatedASMEmailScheduler implements schedulable{
    
    /********************************************************************************************************
    * @author        Deloitte
    * @date          2017-02-10
    * @description   Execute method used to schedule UpdateASMDealerEmailBatch batch class
    * @Paramters     schedulablecontext sc
    * @return        none
    *********************************************************************************************************/
    global void execute(schedulablecontext sc)
    {
        Dealer_UpdatedASMEmailBatch ABatch = new Dealer_UpdatedASMEmailBatch();
        database.executebatch(ABatch);
    }
}