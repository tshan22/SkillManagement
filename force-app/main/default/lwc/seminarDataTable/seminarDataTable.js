

import { LightningElement,api,wire} from 'lwc';
import getSeminarSchedule from "@salesforce/apex/seminarController.getSeminarSchedule";

import NAME_FIELD from "@salesforce/schema/seminar__c.Name";
import SEMINARNAME_FIELD from "@salesforce/schema/seminar__c.SeminaName__c";
import PRICE_FIELD from "@salesforce/schema/seminar__c.Price__c";



import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, createRecord } from "lightning/uiRecordApi";



	//columns
	const cols = [
		{label : 'セミナ名',fieldName: NAME_FIELD.fieldApiName},
		{label: '価格',fieldName:PRICE_FIELD.fieldApiName}
	]

export default class BookSearch extends LightningElement {
	@api seminarInfos;
	@api columns = cols;

	selectedRows = [];

	seminarSelected;

	// scheduleInfos;
	// dateSelect = false;



	back(){
		console.log('1111111111');

		const backEvent = new CustomEvent("backstep",{
			detail:{
				seminarDatatable : false,
				searchStep : true,
				buttonDisplay : true,
				dateSelect : false,
			}
		})
		this.dispatchEvent(backEvent);
		console.log('finish');

	}

	handleRowSelection(event) {
		const rows = event.detail.selectedRows;
		this.seminarSelected = rows;
		for(let i = 0;i<rows.length;i++){
			this.selectedRows.push(rows[i].Id);
		}
		console.log('rows:',rows);
		console.log('selectedRows:',this.selectedRows[0]);
		console.log("seminarSelected:",this.seminarSelected);
		
	}




	next(){
			const nextEvent = new CustomEvent("nextstep",{
			detail:{
				name:'seminarDataTable',
				dateSelect : true,
				seminarDatatable : false,
				searchStep : false,
				buttonDisplay : false,
				seminarSelected:this.seminarSelected

			}
		})
		this.dispatchEvent(nextEvent);
		console.log('nextfinish');


		// this.scheduleInfos = getSeminarSchedule(this.selectedRows);

	}
}














