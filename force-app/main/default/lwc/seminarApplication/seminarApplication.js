

import { LightningElement,api,wire} from 'lwc';
import searchSeminar from "@salesforce/apex/recordController.searchSeminar";
import getSeminarSchedule from "@salesforce/apex/seminarController.getSeminarSchedule";
import LightningAlert from 'lightning/alert';



import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, createRecord } from "lightning/uiRecordApi";


export default class BookSearch extends LightningElement {
	 fieldValue;
	 data;
	 scheduleInfos;

	 seminarSelected
	 scheduleSelected;

	 searchStep = true;
	 buttonDisplay = true;
	 seminarDatatable = false;	 
	 dateSelect = false;



	handleChange(event){
		this.fieldValue = event.target.value;		
	}

	toSearchResultPage(){
		this.seminarDatatable = true;
		this.searchStep = false;
		this.buttonDisplay = false;

		searchSeminar({ inputKeyword: this.fieldValue})
		.then((result) => {
			console.log('result:',result);
			this.data = result;
			console.log('datadata:',this.data);
		})
		.catch((error) => {
			console.log(error);
		});
	}

	backToPreviousPage(event){
		console.log('22222');
		this.seminarDatatable = event.detail.seminarDatatable;
		this.dateSelect = event.detail.dateSelect;
		this.searchStep = event.detail.searchStep;
		this.buttonDisplay = event.detail.buttonDisplay;

		console.log('check:',this.seminarDatatable);

	}

	async toNextPage(event){
		if(event.detail.name == 'seminarDataTable'){
			this.seminarSelected = event.detail.seminarSelected;
			console.log('seminarSelectedddddd',this.seminarSelected);

			this.scheduleInfos = await getSeminarSchedule({selectedLists:this.seminarSelected });
			if(this.scheduleInfos.length == 0){
				await LightningAlert.open({
					message: "こちらのセミナは開催予定ござせん。。",
					theme: "error"
      	});
			}
			console.log('nullcheck:',this.scheduleInfos.length);
			console.log('qqqqq234323432432:',this.scheduleInfos);
		}
		this.dateSelect = event.detail.dateSelect;
		this.seminarDatatable = event.detail.seminarDatatable;
		this.searchStep = event.detail.searchStep;
		this.buttonDisplay = event.detail.buttonDisplay;
	}

	// toNextPage(event){
	// 	this.dateSelect = event.detail.dateSelect;
	// 	this.seminarDatatable = event.detail.seminarDatatable;
	// 	this.searchStep = event.detail.searchStep;
	// 	this.buttonDisplay = event.detail.buttonDisplay;

	// 	if(event.detail.name == 'seminarDataTable'){
	// 		this.seminarSelected = event.detail.seminarSelected;
	// 		console.log('seminarSelectedddddd',this.seminarSelected);

	// 		getSeminarSchedule({selectedLists:this.seminarSelected })
	// 			.then(result => {
	// 				if(result.length == 0){
	// 					alert('こちらのセミナは開催予定ござせん。')
	// 				}
	// 				// console.log(JSON.stringify(result));
	// 				console.log('thenResult:',result);
	// 				this.scheduleInfos = result;
	// 				console.log('scheduleInfos:',this.scheduleInfos);
	// 			}).catch(error=>{
	// 				console.log(error);
	// 			})
	// 	}
	// 	console.log("checkvalue:",this.seminarSelected);


	// }
}








	// toSearchResultPage(){
	// 	this.resultPage = true;	
	// 	this.template.querySelector('c-search-result-page').searchResult();
	// }






