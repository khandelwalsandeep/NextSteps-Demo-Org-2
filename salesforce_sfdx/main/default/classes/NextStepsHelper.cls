public without sharing class NextStepsHelper{

    /**
     * @description Method to get the Quote, Contract, Credit Check and Order details along with the input which has be passed to the vlocity calculation matrix to get the date which needs to be displayed on the UI.
     * @param  quoteId   quote id
     * @return  the instance of the NextStepsWrapper class
     */
    public static NextStepsWrapper getNextStepsData(String quoteId){
        Quote qte = fetchQuoteAndRelatedRecords(quoteId);
        if(qte == null){
            return null;
        }
        
        return new NextStepsWrapper.Builder(qte).build();
    }
    
    /**
     * @description This method updates the calculation matrix response by updating certain column values.
     *              Calculation matrix (refer to the class description for its name) currently contains some dynamic fields that need to be replaced with actual data.
     *              The fields which should be replaced must be encapsulated in the  double angular brackets (<<ValueToBeReplaced>>).
     *              These replacement values should to be present in the 'additionalData' node returned by the fetchNextStepsData method.
     * 
     * @param  matrixResult   Output of the calculation matrix
     * @param  additionalData  Value of the 'additionalData' node returned by the fetchNextStepsData method.
     * @return  Updated matrix result json string
     */
    public static Object updateMatrixResult(List<Map<String, Object>> matrixResult, Map<String, Object> additionalData){
        //As of now boolean fields are also stored as string in the calculation matrix rows. To retrun these fields as boolean in response, removing the double quote by replacing them.
        String matrixResultStr = JSON.serialize(matrixResult).replace('"true"','true').replace('"false"','false');
        
        //Replacing the dynamic fields
        for(String key : additionalData.keySet()){
            matrixResultStr = matrixResultStr.replace(createReplacementKey(key), getReplacementValue(additionalData, key)); 
        }        
        return JSON.deserializeUntyped(matrixResultStr);
    }
    
    /**
     * @description Wrapping the key with double angular brackets
     * @param  key the key present in additionalData node
     * @return     return key wrapped in double angular brackets
     */
    private static String createReplacementKey(String key){
        return '<<' + key + '>>';
    }
    
    /**
     * @description This method extracts the value from additionalData from key
     * @param  data Map of additionalData
     * @param  key  the key whose value is needed
     * @return      return the value of key
     */
    private static String getReplacementValue(Map<String, Object> data, String key){
        Object value = data.get(key);
        return value!=null ? String.valueOf(value) : '';
    }
    
    /**
     * @description Fetch the Quote and its related records details
     * @param  quoteId Id of Quote record
     * @return         return Quote and related records
     */
    private static Quote fetchQuoteAndRelatedRecords(String quoteId){
        List<Quote> quotes = [Select Id, AccountId, OpportunityId, Status, Opportunity.StageName,
                              (Select Id, ContractNumber, Status, CreatedDate From vlocity_cmt__Contracts__r Order By CreatedDate Desc Limit 1),
                              (Select Id, OrderNumber, Status, vlocity_cmt__OrderStatus__c, CreatedDate From vlocity_cmt__Orders__r Order By CreatedDate Desc Limit 1)
                              From Quote Where Id = :quoteId];
        return quotes!=null && !quotes.isEmpty() ? quotes.get(0) : null;
    }
}