

import { LightningElement,api,wire} from 'lwc';
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
	{label:'受講履歴',fieldName:'seminarHistory',format:(row) => row.employees__r}
]

export default class skillManagement extends LightningElement {
	fieldValue;
	columns = col;
	data;	
	// resultPage = false;

	//data
	@wire(getinformation)
	wiredEmployeeInfos(result) {
		if (result.data) {
			this.data = toTable(result.data,this.columns);
			console.log('data:',JSON.stringify(this.data));
		} else if (result.error) {
			console.log('error');
		}
	}
	// async connectedCallback(){
	// 	this.data =  await getinformation();
	// 	console.log('dataddada:',this.data);
	// }

	

	handleChange(event){
		this.fieldValue = event.target.value;		
		searchEmployee({ inputName: this.fieldValue})
		.then((result) => {
			console.log('result:',result);
			this.data = toTable(result,this.columns);
			console.log('datadata:',this.data);
		})
		.catch(() => {
			console.log('error');
		});
	}

	// toSearchResultPage(){
	// 	searchEmployee({ inputName: this.fieldValue})
	// 	.then((result) => {
	// 		console.log('result:',result);
	// 		this.data = toTable(result,this.columns);
	// 		console.log('datadata:',this.data);
	// 	})
	// 	.catch(() => {
	// 		console.log('error');
	// 	});

}








	// toSearchResultPage(){
	// 	this.resultPage = true;	
	// 	this.template.querySelector('c-search-result-page').searchResult();
	// }





