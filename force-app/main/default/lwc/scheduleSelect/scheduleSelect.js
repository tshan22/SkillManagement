import { LightningElement,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import {toTable} from "c/util";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELD from "@salesforce/schema/seminarScheduleManagement__c.Name";
import FORM_FIELD from "@salesforce/schema/seminarScheduleManagement__c.form__c";
import VENUE_FIELD from "@salesforce/schema/seminarScheduleManagement__c.Venue__c";
import DATETIME_FIELD from "@salesforce/schema/seminarScheduleManagement__c.DateTime__c";
import SEMINAR_FIELD from "@salesforce/schema/seminarScheduleManagement__c.seminar__c";

import getinformation from "@salesforce/apex/recordController.getinformation";
import searchEmployee from "@salesforce/apex/recordController.searchEmployee";
import searchSeminar from "@salesforce/apex/recordController.searchSeminar";
import getSeminarSchedule from "@salesforce/apex/recordController.getSeminarSchedule";
import getAppliInfo from "@salesforce/apex/recordController.getAppliInfo";
import createAttendanceHistory from "@salesforce/apex/recordController.createAttendanceHistory";




const cols = [
	{label : 'セミナ名',fieldName: 'seminarName',format: (row) => row.seminar__r.Name},
	{label : '形態',fieldName: FORM_FIELD.fieldApiName},
	{label: '開催地',fieldName:VENUE_FIELD.fieldApiName},
	{label: '開催日時',fieldName:DATETIME_FIELD.fieldApiName}
]

export default class ScheduleSelect extends LightningElement {
	@api scheduleInfos;
	columns = cols;
	data;


	selectedRows = [];
	scheduleSelected;

	infoConfirm = false;
	seminarDetermine = false;
	applicationInfo;
	totalAmount = 0;


	//data
	async connectedCallback(){
		console.log('dsdsdsfddgdfgd:',JSON.stringify(this.scheduleInfos));
		this.data = await toTable(this.scheduleInfos,this.columns);
		console.log('datadataaaaaaa',JSON.stringify(this.data));
	}

	back(){
			const backEvent = new CustomEvent("backstep",{
			detail:{
				seminarDatatable : true,
				dateSelect: false,
				searchStep : false,
				buttonDisplay : false
			}
		})
		this.dispatchEvent(backEvent);
	}


	handleRowSelection(event) {
		const rows = event.detail.selectedRows;
		this.scheduleSelected = rows;

		// for(let i = 0;i<rows.length;i++){
		// 	this.selectedRows.push(rows[i].Id);
		// }
		// console.log('rows:',rows);
		// console.log('cjeckRpws:',this.selectedRows.length);

		console.log("rselected:",this.scheduleSelected.length);
		
		
	}
	async apply(){
		console.log('scheduleSelected',this.scheduleSelected);
		console.log('length:',this.scheduleSelected.length);
		if(this.scheduleSelected.length != 0){
			this.infoConfirm = true;	
			this.seminarDetermine = true;
		
			this.applicationInfo = await getAppliInfo({selectedLists:this.scheduleSelected});			
			console.log('lisudknfdk:',this.applicationInfo);

			for(let i =0;i<this.applicationInfo.length;i++){
				this.totalAmount += this.applicationInfo[i].seminar__r.Price__c;
			}

		}else if(this.scheduleSelected === undefined || this.scheduleSelected.length == 0 ){
			console.log('hello');
			console.log('initail:',this.scheduleSelected);
			await LightningAlert.open({
        message: "日時を選択してください。",
        theme: "error",
        label: "申込できません"
      });
		}		
	}

	close(){
		this.infoConfirm = false;	
		this.seminarDetermine = false;

		// this.scheduleSelected = null;
		// this.applicationInfo = null;
		this.totalAmount = 0;
	}

	async determine(){
		await createAttendanceHistory({appliInfo:this.applicationInfo})
		.then(() => {		
			this.dispatchEvent(
				new ShowToastEvent({
					title: "申込成功しました",
					variant: "success"
				})
			);		
		})
		.catch((error) => {
			this.dispatchEvent(
				new ShowToastEvent({
					message: error.body.message,
					variant: "error"
				})
			);
			console.log('error:',error);
		});
		console.log('create history');
		this.infoConfirm = false;
		this.totalAmount = 0;
	}




}





