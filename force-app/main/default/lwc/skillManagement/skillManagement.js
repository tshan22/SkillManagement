

import { LightningElement,api,wire,track} from 'lwc';
import getinformation from "@salesforce/apex/recordController.getinformation";
import searchEmployee from "@salesforce/apex/recordController.searchEmployee";

import NAME_FIELD from "@salesforce/schema/employee__c.Name";
import POSITION_FIELD from "@salesforce/schema/employee__c.Position__c";
import CERTIFICATION_FIELD from "@salesforce/schema/employee__c.OwnedCertification__c";
import EMPLOYEENAME_FIELD from "@salesforce/schema/employee__c.employeeName__c";
import {toTable} from "c/util";




const col = [
	{label : '従業員名',fieldName: 'employeeName',format: (row) => row.employeeName__r.Name},
	{label: '役割',fieldName:POSITION_FIELD.fieldApiName},
	{label : '保有資格',fieldName: CERTIFICATION_FIELD.fieldApiName},
	{label:'受講履歴',fieldName:'seminarHistory'}
]


export default class skillManagement extends LightningElement {
	fieldValue;
	columns = col;
	data;	
	// resultPage = false;
	@track seminarHistory;
	@track all;

	//data
	async connectedCallback(){
		const employeeInfo = await getinformation();
		console.log('data',employeeInfo);
		this.all = employeeInfo.map((item)=>{
				const employeedata = item.employees__r;
				console.log('emdata:',employeedata);
				if(employeedata){	
					  this.seminarHistory =  employeedata.map(element => {
						return element.seminarName__r.Name + ':' +element.ConcreteDateTime__c	;							
					});
					// console.log(JSON.stringify(this.seminarHistory));					
				}else if(!employeedata){
					console.log('33333');
					this.seminarHistory = '';
					console.log(this.seminarHistory.length);				
				}
				if(this.seminarHistory.length >0){
					console.log('seminarHistory:',this.seminarHistory.join('\n'));
					return {...item, seminarHistory: this.seminarHistory.join('\n')};

				}else if(this.seminarHistory.length == 0){
					console.log('seminarHistory:',this.seminarHistory);
					return {...item, seminarHistory: this.seminarHistory};

				}
									// return {...item, seminarHistory: this.seminarHistory.join('\n')};
		})
		console.log('all:',JSON.stringify(this.all));
		this.data = toTable(this.all,this.columns);
		// console.log('all:',all);
	}

	handleChange(event){
		this.fieldValue = event.target.value;		
		searchEmployee({ inputName: this.fieldValue})
		.then((result) => {
			console.log('result:',result);
			this.data = toTable(result,this.columns);
			console.log('datadata:',this.data);
		})
		.catch((error) => {
			console.log(error);
		});
	}

}






