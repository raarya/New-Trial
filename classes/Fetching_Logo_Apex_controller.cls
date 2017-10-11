/********************************************************************************************
* Method Name: Fetching_Logo_Apex_controller
* Author: Deeksha Singhal (Deloitte)
* Date: [04/28/2017]
* Requirement Description: User story W-004396- Logo set for Toyota and Lexus users
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class Fetching_Logo_Apex_controller {
    @AuraEnabled
    // Set up method to fetch the Dealer Type
    public static String getUserName(){
        User usr = [SELECT id,accountId from user where id=:userinfo.getUserID()];
        Account acc = [SELECT id,Name,Type from Account WHERE ID = :usr.accountId];
       // list<Document> listDoc = [select id, name from document where name ='Lexus Logo' OR name='Toyota Logo'];
        
        
        return acc.Type;
        }
        
}