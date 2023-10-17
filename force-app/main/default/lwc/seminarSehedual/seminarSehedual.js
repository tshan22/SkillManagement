import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import { refreshApex } from '@salesforce/apex';
import {createRecord } from "lightning/uiRecordApi";

import SCHEDULEANAGEMENT_OBJECT from '@salesforce/schema/seminarScheduleManagement__c';
import FORM_FIELD from '@salesforce/schema/seminarScheduleManagement__c.form__c';
import VENUE_FIELD from '@salesforce/schema/seminarScheduleManagement__c.Venue__c';
import DATE_FIELD from '@salesforce/schema/seminarScheduleManagement__c.Date__c';
import TIMEFROM_FIELD from '@salesforce/schema/seminarScheduleManagement__c.TimeFrom__c';
import TIMEEND_FIELD from '@salesforce/schema/seminarScheduleManagement__c.TimeEnd__c';
import SEMINAR_FIELD from '@salesforce/schema/seminarScheduleManagement__c.seminar__c';



export default class SeminarSehedual extends LightningElement {
	@api recordId;
	scheduleObjId;

	formValue;
	venueValue;
	dateValue;
	timeFromValue;
	timeEndValue;

	objectApiName = SCHEDULEANAGEMENT_OBJECT;
	seminar = SEMINAR_FIELD
	form = FORM_FIELD;
	venue = VENUE_FIELD;
	date = DATE_FIELD;
	timeFrom = TIMEFROM_FIELD;
	timeEnd = TIMEEND_FIELD;                  

	handleChange1(event){
		this.formValue = event.detail.value
	}
	handleChange2(event){
		this.venueValue = event.detail.value	
	}
	handleChange3(event){
		this.dateValue = event.detail.value;
	}
	handleChange4(event){
		this.timeFromValue = event.detail.value;
	}
	handleChange5(event){
		this.timeEndValue = event.detail.value;
	}


	

	save() {
		const fields = {};
		fields[SEMINAR_FIELD.fieldApiName] = this.recordId;
    fields[FORM_FIELD.fieldApiName] =this.formValue;
    fields[VENUE_FIELD.fieldApiName] = this.venueValue;
    fields[DATE_FIELD.fieldApiName] = this.dateValue;
    fields[TIMEFROM_FIELD.fieldApiName] = this.timeFromValue;
    fields[TIMEEND_FIELD.fieldApiName] = this.timeEndValue;

		const recordInput = {apiName: SCHEDULEANAGEMENT_OBJECT.objectApiName,fields};
		createRecord(recordInput)
			.then((result) => {		
				console.log('created success');
        this.dispatchEvent(
					new ShowToastEvent({
							title: "Success",
							message: "Account created successfully!",
							variant: "success"
					})
				);
				this.Cancel();		
			})
			.catch((error) => {
				console.log(FORM_FIELD.value);
				this.dispatchEvent(
					new ShowToastEvent({
							title: "Error creating record",
							message: error.body.message,
							variant: "error"
					})
				);
			})
		}		

	

	Cancel(){
		const navigateFinishEvent = new FlowNavigationFinishEvent();
		this.dispatchEvent(navigateFinishEvent);
	}

	handleSuccess(event){
		this.scheduleObjId = event.detail.id;
	}


}