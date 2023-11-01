import { LightningElement,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import {toTable} from "c/util";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FIELD from "@salesforce/schema/seminarScheduleManagement__c.form__c";
import VENUE_FIELD from "@salesforce/schema/seminarScheduleManagement__c.Venue__c";
import DATETIME_FIELD from "@salesforce/schema/seminarScheduleManagement__c.DateTime__c";
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
		this.data = await toTable(this.scheduleInfos,this.columns);
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
		// console.log("rselected:",this.scheduleSelected.length);		
	}

	async apply(){
		// console.log('scheduleSelected',this.scheduleSelected);
		if(this.scheduleSelected.length != 0){
			this.infoConfirm = true;	
			this.seminarDetermine = true;
		
			this.applicationInfo = await getAppliInfo({selectedLists:this.scheduleSelected});			

			for(let i =0;i<this.applicationInfo.length;i++){
				this.totalAmount += this.applicationInfo[i].seminar__r.Price__c;
			}

		}else if(this.scheduleSelected === undefined || this.scheduleSelected.length == 0 ){
			// console.log('initail:',this.scheduleSelected);
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
		this.totalAmount = 0;
	}

	async determine(){
		await createAttendanceHistory({appliInfo:this.applicationInfo})
		.then(() => {		
			this.dispatchEvent(
				new ShowToastEvent({
					title: '成功',
					message: "申込成功しました",
					variant: "success"
				})
			);		
		})
		.catch((error) => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: '失敗',
					message: error.body.message,
					variant: "error"
				})
			);
			console.log('error:',error);
		});
		this.infoConfirm = false;
		this.totalAmount = 0;
	}




}





