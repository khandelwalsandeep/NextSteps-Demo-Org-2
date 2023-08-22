@JsonAccess(serializable='always')
public class NextStepsWrapper {

    private Contract contract;
    private Order order;
    private String matrixCacheKey;
    private List<Map<String, String>> matrixInput;
    private Map<String, Object> additionalData;

    /**
     * Constructor is made private to so this class can be initiallized only from the builder class
     */
    private NextStepsWrapper(NextStepsWrapper.Builder builder){
        this.contract = builder.contractRecord;
        this.order = builder.orderRecord;
        this.matrixInput = builder.matrixInput;
        this.additionalData = builder.additionalData;
        this.matrixCacheKey = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(JSON.serialize(builder.matrixInput))));
    }

    /**
     * @description: Inner class to Generate the instance of NextStepsWrapper class. This is class is created only to hide the object creation logic from the parent class
     */
    public class Builder{
        private Quote quote;
        private Contract contractRecord;
        private Order orderRecord;

        private String contractStatus;
        private String orderStatus;
        private List<Map<String, String>> matrixInput = new List<Map<String, String>>();
        private Map<String, Object> additionalData = new Map<String, Object>();

        /**
         * @description Constructor for this class
         * @param  qte    Quote record
         */
        public Builder(Quote qte){            
            this.quote =  qte;
        }

        /**
         * @description This creates and return the instance of NextStepsWrapper class. This is only public method in this class to be called from Helper class.
         * @return   return Instance of NextStepsWrapper class
         */
        public NextStepsWrapper build(){
            this.setRecords(); //Setting contract and order records
            this.generateMatrixInput(); //Set the each steps details
            this.setAdditionalData(); //Set the additional data needed
            return new NextStepsWrapper(this);
        }

        /**
         * @description This method sets the Contract and Order records
         */
        private void setRecords(){
            this.contractRecord = this.quote.vlocity_cmt__Contracts__r != null && !this.quote.vlocity_cmt__Contracts__r.isEmpty() ? this.quote.vlocity_cmt__Contracts__r.get(0) : null;
            this.orderRecord = this.quote.vlocity_cmt__Orders__r != null && !this.quote.vlocity_cmt__Orders__r.isEmpty() ? this.quote.vlocity_cmt__Orders__r.get(0) : null;
        }

        /**
         * @description This method sets the status of all Steps with are necessary in the Quote to Order journey in the following sequence.
         *              Contract
         *              Order
         */
        private void generateMatrixInput(){
            this.setContractStatus();
            this.setOrderStatus();

            this.matrixInput.add(createMatrixInputRow('Contract', this.contractStatus));
            this.matrixInput.add(createMatrixInputRow('Order', this.orderStatus));
        }

        /**
         * @description Set the status of the Contracting step
         */
        private void setContractStatus(){
            if(this.contractRecord != null){
                this.contractStatus = this.contractRecord.Status;
            }else{
                this.contractStatus = 'Not Created';
            }
        }

        /**
         * @description Set the Status for Ordering and Billing step
         */
        private void setOrderStatus(){
            if(this.orderRecord != null){
                this.orderStatus = this.orderRecord.Status;
            }else{
                this.orderStatus = 'Not Created';
            }
        }

        /**
         * @description Add additional info to the result. This will be primarially used to replace the dynamic values given in the calculation matrix. 
         * To replace dynamic values, Wrap the nodes added to additionData with double angular brackes in the calculation matrix.
         */
        private void setAdditionalData(){
            additionalData.put('cartId', this.quote.Id);
            if(this.contractRecord!=null){
                additionalData.put('contractId', this.contractRecord.Id);
                additionalData.put('ContractCreatedOn', getFormattedDateStr(this.contractRecord.CreatedDate));
            }

            if(this.orderRecord!=null){
                additionalData.put('OrderCreatedOn', getFormattedDateStr(this.orderRecord.CreatedDate));
            }
        }

        /**
         * @description Create a map of Step and Step's status. This will work as an input to the calculation matrix
         * @param  step   Name of the step
         * @param  status Status of the step
         * @return        return map containing step and status key and value
         */
        private Map<String, String> createMatrixInputRow(String step, String status){
            return new Map<String, String> {
                'step' => step,
                'status' => status
            };
        }

        /**
         * @description Convert the DateTime value to string in Month/Day/Year format
         * @param  dti DateTime value
         * @return     return formatted string
         */
        private String getFormattedDateStr(DateTime dti){
            return getFormattedDateStr(dti.date());
        } 

        /**
         * @description Convert the Date value to string in Month/Day/Year format
         * @param  dti Date value
         * @return     return formatted string
         */
        private String getFormattedDateStr(Date dt){
           return dt.month() + '/' + dt.day() + '/' + dt.year();
        }
    }
}