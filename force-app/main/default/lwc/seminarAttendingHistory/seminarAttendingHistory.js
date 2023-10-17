

import { LightningElement,api,wire} from 'lwc';
import getinformation from "@salesforce/apex/recordController.getinformation";
import getSeminarHistoryInfo from "@salesforce/apex/recordController.getSeminarHistoryInfo";

import NAME_FIELD from "@salesforce/schema/employee__c.Name";
import POSITION_FIELD from "@salesforce/schema/employee__c.Position__c";
import CERTIFICATION_FIELD from "@salesforce/schema/employee__c.OwnedCertification__c";
import EMPLOYEENAME_FIELD from "@salesforce/schema/employee__c.employeeName__c";
import {toTable} from "c/util";




const col = [
	{label:'受講履歴',fieldName:'seminarHistory',format:(row) => row.employees__r}
]

export default class skillManagement extends LightningElement {
	@api fieldValue;
	columns = col;
	data;	

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













