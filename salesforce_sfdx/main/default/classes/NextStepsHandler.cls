global without sharing class NextStepsHandler implements vlocity_cmt.VlocityOpenInterface2 {
    private static final String CONST_VAR_CARTID = 'cartId';
    private static final String CONST_VAR_DATA = 'data';
    private static final String CONST_VAR_RESULT = 'result';
    private static final String CONST_VAR_MATRIX_RESULT = 'matrixResult';
    
    private static final String METHOD_NAME_FETCHNEXTSTEPS_DATA = 'fetchNextStepsData';
    private static final String METHOD_NAME_REPLACE_UPDATE_MATRIX_RESULT = 'updateMatrixResult';
    
    /**
     * @description This is a generic method used by Integration Procedure 
     * @param  methodName Name of method to be called
     * @param  inputMap   Input parameters for the method
     * @param  outputMap  Output parameters returned by the the method
     * @param  optionsMap Any options to be passed 
     * @return            return true/false
     */
    global Boolean invokeMethod(String methodName,
                                Map<String, Object> inputMap,
                                Map<String, Object> outputMap,
                                Map<String, Object> optionsMap){
        if(methodName.equals(METHOD_NAME_FETCHNEXTSTEPS_DATA)){
            fetchNextStepsData(inputMap, outputMap, optionsMap);
        }else if(methodName.equals(METHOD_NAME_REPLACE_UPDATE_MATRIX_RESULT)){
            updateMatrixResult(inputMap, outputMap, optionsMap);
        }  
        return true;
    }
    

    /**
     * @description Method to get the Quote, Contract, and Order details
     * @param  inputMap   Input parameters for the method.
     * @param  outputMap  Output parameters returned by the the method
     * @param  optionsMap Any options to be passed 
     */
    private void fetchNextStepsData(Map<String, Object> inputMap,
                                    Map<String, Object> outputMap,
                                    Map<String, Object> optionsMap){
        String quoteId = String.valueOf(inputMap.get(CONST_VAR_CARTID)); //Id of Quote for which data is being queried
        outputMap.put(CONST_VAR_RESULT, NextStepsHelper.getNextStepsData(quoteId));
    }

    /**
     * @description This method updates the calculation matrix response by updating certain column values.
     *              Calculation matrix (refer to the class description for its name) currently contains some dynamic fields that need to be replaced with actual data.
     *              The fields which should be replaced must be encapsulated in the  double angular brackets (<<ValueToBeReplaced>>).
     *              These replacement values should to be present in the 'additionalData' node returned by the fetchNextStepsData method.
     * 
     * @param  inputMap   Input parameters for the method.
     * @param  outputMap  Output parameters returned by the the method
     * @param  optionsMap Any options to be passed 
     */
    private void updateMatrixResult(Map<String, Object> inputMap,
                                    Map<String, Object> outputMap,
                                    Map<String, Object> optionsMap){
        List<Map<String, Object>> matrixResult = (List<Map<String, Object>>) inputMap.get(CONST_VAR_MATRIX_RESULT); //Output of the calculation matrix                                        
        Map<String, Object> additionalData = (Map<String, Object>) inputMap.get(CONST_VAR_DATA); //Value of the 'additionalData' node returned by the fetchNextStepsData method.
        outputMap.put(CONST_VAR_RESULT, NextStepsHelper.updateMatrixResult(matrixResult, additionalData));                             
    }
}