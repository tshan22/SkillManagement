

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
	{label:'受講履歴',fieldName:'seminarHistory'}
]


export default class skillManagement extends LightningElement {
	fieldValue;
	columns = col;
	data;	
	// resultPage = false;

	//data
	@wire(getinformation)
	wiredEmployeeInfos(result) {
		const seminarHistory = null;
		const all = null;
		if (result.data) {
			console.log('length:',result.data.length);
			 all =	result.data.map((item)=>{				
				let employeedata = item.employees__r;
				if(!employeedata == null){
					  seminarHistory = employeedata.map((sub_item)=>{
						sub_item.seminarName__r.Name + ':' +sub_item.ConcreteDateTime__c
					})
				}
			})
			this.data= toTable(all,this.columns);
		 	return {...item, seminarHistory: seminarHistory.join('')};
			
		}else {
			console.log('error');
		}
	
	}

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

}






