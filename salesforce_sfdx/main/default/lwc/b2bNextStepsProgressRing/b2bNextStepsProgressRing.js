import { LightningElement, api } from 'lwc';

export default class B2bNextStepsProgressRing extends LightningElement {
    @api set record(val) {
        this._record = val;
        this.setProgressValue(this._record.stepStatus);
     }
 
     get record() {
         return this._record;
     }

     setProgressValue(stepStatus) {
        if(stepStatus == 'Completed') {
            this.fill = 100;
            this.variant = 'base-autocomplete';
        } else if(stepStatus == 'Not Completed') {
            this.fill = 0;
            this.variant = 'base';
            this.showSequence = true;
        } else if(stepStatus == 'In Progress') {
            this.fill = 25;
            this.variant = 'base';
            this.showSequence = true;
        } else if(stepStatus == 'Warning') {
            this.fill = 25;
            this.variant = 'warning';
        }        
     }
}