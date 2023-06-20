import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


import { NavigationMixin } from 'lightning/navigation';

import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";
import OPPORTUNITY_ITEM_OBJECT from "@salesforce/schema/OpportunityItem__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

import STAGENAME_FIELD from "@salesforce/schema/Opportunity.StageName";

import getdata from "@salesforce/apex/OpportunityManagement.getdata";
import getLabel from "@salesforce/apex/OpportunityManagement.getLabel";
import getPickList from "@salesforce/apex/OpportunityManagement.getPickList";
// import { formatMessage } from "../util/util";

// import getOpportunityInfo from "@salesforce/apex/OpportunityManagement.getOpportunityInfo";

export default class MyDatatableDemo extends LightningElement {
	@api recordId;

	
	columns;
	opps;

	productLabel;
	unitCountsLabel;
	stageNameLabel;

	dataLength;

	objectInfo;
	// oppMachine;
	// oppStageName;

 //	Opportunityの情報を取得する
 @wire(getObjectInfo, { objectApiName: OPPORTUNITY_ITEM_OBJECT})
 opportunityObjectInfo({ data, error }) {
	 if (data) {
		 this.objectInfo = data;
		 console.log('111111111111111111111');
		 console.log(this.objectInfo);
	 } else if (error) {
		 console.log("getObjectInfo error:" + error);
	 }
 }



	async connectedCallback(){
		try{
			console.log('qqqqqqqqqqqqqqqqq');
			//列のラベル名を取得する
			this.productLabel= await getLabel({fieldName:'Product2__c'});
			this.unitCountsLabel = await getLabel({fieldName:'UnitCounts__c'});
			this.stageNameLabel = await getLabel({fieldName:'StageName__c'});

			console.log('2222222222222--------------------------------------------------');
			console.log(this.productLabel);
			console.log(this.unitCountsLabel);
			console.log(this.stageNameLabel)

			//選択リストの選択肢を取得する		
			const productPicklist = await getPickList({picklistName:'Product2__c'});
			const stageNamePicklist = await getPickList({picklistName:'StageName__c'});

			console.log('3333333333333333----------------------------------');
			console.log('機種選択肢');
			console.log(productPicklist);
			console.log('フェーズ選択肢');
			console.log(stageNamePicklist);


			//columns
			this.setColumns(productPicklist,stageNamePicklist);

			//data
			const opportunityItems = await getdata({opportunityId: this.recordId});
			console.log('4444444444444---------------------------');
			console.log(opportunityItems);
			this.opps = opportunityItems;
			console.log(this.opps);
			console.log('**********************');
			console.log(this.opps.length);//2
			this.dataLength = this.opps.length;
		}catch(error){
			console.log('error is ocurred');
			console.error(error.message);
		}
	}

	//dataを取得する
	// @wire(getdata, { opportunityId: "$recordId" }) 
	// getOpp({ data, error }) {
	// 	if (data) {
	// 		this.opps = data;
	// 		// console.log('data---------->' + data);
	// 		// console.log('000000000');
	// 		// console.log(this.opps);
	// 	}
	// }



	//選択リストの値を取得する
  setColumns(productPicklist,stageNamePicklist) {	

		//Product２__c選択肢を取得
		let productOptions = [];
		productPicklist.forEach((e) => {
			productOptions.push({
				label: e.label,
				value: e.value
			});
		});	

		//StageName選択肢を取得
		let stageNameOptions = [];
		stageNamePicklist.forEach((e) => {
			stageNameOptions.push({
				label: e.label,
				value: e.value
			});
		});
    


		//colmnsを定義する
    this.columns = [
			{
				label: this.productLabel,
				type: "productPicklist",
				wrapText: true,
				typeAttributes: {
					options: productOptions,
					value: { fieldName: "Product2__c" },
					fieldName:"Product2__c",
					recordId: { fieldName: "Id" }
				}
			},
			{ label: this.unitCountsLabel,
				fieldName:  "UnitCounts__c",
				type: "inputNumberField", 
				wrapText: true,
				typeAttributes: {
					value: { fieldName:  "UnitCounts__c" },
					recordId: { fieldName: "Id" },
					fieldName:  "UnitCounts__c",
					maxLength: "2"
				}
			},
 
			{
				label: this.stageNameLabel,
				type: "stageNamePicklist",
				wrapText: true,
				typeAttributes: {
					options: stageNameOptions,
					value: { fieldName: "StageName__c" },
					fieldName:"StageName__c",
					recordId: { fieldName: "Id" }
				}
			},
			{
				type: "button-icon",
				fixedWidth: 40,
				typeAttributes: {
						iconName: "utility:delete",
						name: "deleteRow",
						disabled: { fieldName: "DisableDelete" }
				}
			}
    ];
  }

	currentId = 0;
	get nextId() {
			this.currentId += 1;
			return `xxx-${this.currentId}`;
	}

	addRow(){
		const newOpportunityItem = {
			// Id: this.nextId,
			Opportunity__c: this.recordId,
			Product2__c: "",
			UnitCounts__c: "",
			StageName__c: "",
			DisableDelete: false
		};
		this.opps = [...this.opps, newOpportunityItem];
		console.log(this.nextId);
	}

	

	// deleteOpportunityItems=[];

	//行を削除する
	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		const rowId = row.Id;
		console.log(rowId);
		if (actionName === "deleteRow") {
				this.deleteRow(row);
		}
	}

	deleteRow(row) {
			const deleteRows = this.opps.filter((e) => e.Id === row.Id);
			const remainRows = this.opps.filter((e) => e.Id !== row.Id);
			console.log(JSON.stringify(remainRows));
			console.log(row.id);
			if (deleteRows.length > 0) {
					this.opps = remainRows;
					// this.deleteOpportunityItems.push(deleteRows[0]);
			}
	}

	//値を変更


	handleChange(event) {
		const value = event.detail.value;
		const recordId = event.detail.name;
		const fieldName = event.detail.context;
	}
	

// save(){
// 	const fields = {};
// 	if(this.opps.length>this.datalength){


// 	}
// }




  


  //キャンセル、フローが終わり
	close() {
		const navigateFinishEvent = new FlowNavigationFinishEvent();
		this.dispatchEvent(navigateFinishEvent);
}

	// handleChange(event){ 
	// 	const value = event.details.value;
	// 	const id = event.details.name;


	// }
}

// connectedCallback(){

// }

// 	async connectedCallback(){
// 		// 項目の表示ラベルを取得
// 		const opportunityInfo = await this.getObjectInfo(OPPORTUNITY_OBJECT);
// 		this.setOpportunityObjectInfo(opportunityInfo);
// 		console.log(opportunityInfo);

// 		// 商談のStageNameno選択リストを取得
// 		const stageNamePicklist = await this.getPicklistValues(opportunityItemInfo.defaultRecordTypeId, STAGENAME_FIELD);
// 		//現在開いている商談のmachine_cの選択リストを取得
// 		const opportunityItems = await selectPickList({ opportunityId: this.recordId });
// 		this.createDataTableColumns(stageNamePicklist.values, opportunityItems);

// 		this.getData(opportunityItems);

// 	}

// 		setOpportunityObjectInfo(objectInfo) {
// 			this.machineLabel = objectInfo.fields.machine__c.label;
// 			this.StageNameLabel = objectInfo.fields.StageName.label;
// 			this.quantityLabel = objectInfo.fields.quantity__c.label;
// 			this.defaultRecordTypeId = objectInfo.defaultRecordTypeId;
// 	}

// 	createDataTableColumns(stageNamePicklist,opportunityItems){
// 		let stageNameOptions = [];
// 		stageNamePicklist.forEach((e)=>{
// 			stageNameOptions.push({label:e.label,value:e.value})
// 		});

// 		let machineOptions = [];
// 		opportunityItems.forEach((e)=>{
// 			machineOptions.push({label:e.machine__c.label,value:e.machine__c.value})
// 		})

// 		this.columns=[
// 				{
// 						label: this.machineLabel,
// 						fieldName: "machine__c",
// 						type:"machinePicklist",
// 						wrapText: true,
// 						typeAttributes: {
// 							label: this.machineLabel,
// 							options:machineOptions,
// 							value: { fieldName: "machine__c" },
// 							recordId: { fieldName: "Id" },
// 							fieldName: "machine__c",
// 							emptyLabel: ""
// 						}
// 					},
// 					{
// 						label: this.quantityLabel,
// 						fieldName: "machine__c",
// 						type: "inputNumberField",
// 						typeAttributes: {
// 								recordId: { fieldName: "Id" },
// 								value: { fieldName: "machine__c" },
// 								fieldName: "machine__c",
// 								maxLength: "2"
// 						}
// 				},
// 					{
// 						label:this.StageNameLabel,
// 						fieldName: 'StageName',
// 						type: "stageNamePicklist",
// 						wrapText: true,
// 						typeAttributes: {
// 							label:this.StageNameLabel,
// 							options:stageNameOptions,
// 							value: { fieldName: "StageName" },
// 							recordId: { fieldName: "Id" },
// 							fieldName: "StageName",
// 						}
// 					},
// 					{
// 						type: "button-icon",
// 						fixedWidth: 40,
// 						typeAttributes: {
// 								iconName: "utility:delete",
// 								name: "deleteRow",
// 								disabled: { fieldName: "DisableDelete" }
// 						}
// 				}
// 			]
// 	}
// 		getData(opportunityItems){
// 			let oppsItem = [];
// 			opportunityItems.forEach((item)=> {
// 				item.DisableDelete = !this.label.deletebaleStageName.includes(items.StageName);
// 				oppsItem.push(item);
// 			})
// 			this.opps = oppsItem;

// 		}

// 		valueChanged(event) {
// 			const value = event.detail.value;
// 			const recordId = event.detail.name;
// 			const fieldName = event.detail.context;

// 			this.updateDataValues({ Id: recordId, [fieldName]: value });
// 	}
// 	updateDataValues(updateItem) {
// 		const index = this.data.findIndex((e) => e.Id === updateItem.Id);
// 		this.data = [...this.data];
// 		this.data[index] = Object.assign({}, this.data[index], updateItem);
// }

// 		fetchOpportunity(){
// 			selectPickList()
// 						.then((result) => {
// 								let options =[];
// 								for(var key in this.oppStageName){
// 									options.push({label:this.oppStageName[key].label,value:this.oppStageName[key].value});
// 								}
// 								this.opps=result.map((record) => {
// 										return {
// 											...record,
// 											'stageNameOptions':options,
// 										}
// 								});
// 								this.error = undefined;
// 						})
// 						.catch((error) => {
// 							this.error = error;
// 							this.opps = undefined;
// 						});
// 					}

// }

// @wire(selectPickList,{recordId})
// listOfOpportunities({data,error}){
// 	if(data){
// 		this.opps = data;
// 		this.error=undefined;
// 	}else if(error){
// 		this.opps = undefined;
// 		this.error = error;
// 	}
// }

// inputValue;
// @api recordId;
// columns;
// data =[];

// opportunityStageName=[];

// @wire(getObjectInfo, { objectApiName:OPPORTUNITY_OBJECT ,fields: [ OPPORTUNITY_STAGENAME_FIELD, OPPORTUNITY_MACHINE_FIELD,OPPORTUNITY_QUANTITY_FIELD]})
// 	opportunityObjectInfo({ data, error }) {
// 		if(data){
// 				this.objectInfo = data;
// 				this.getLabel();
// 		} else if (error) {
// 				console.log('getObjectInfo error:' + error);
// 		}
// 	}

// }

// 	async getLabel(){
// 		const OPPORTUNITY_MACHINE_FIELD = this.objectInfo.fields.machine__c.label;
// 		const OPPORTUNITY_STAGENAME_FIELD = this.objectInfo.fields.StageName.label;
// 		const OPPORTUNITY_QUANTITY_FIELD = this.objectInfo.fields.quantity__c.label;

// 		this.machineLabel = OPPORTUNITY_MACHINE_FIELD ;
// 		this.quantityLabel = OPPORTUNITY_QUANTITY_FIELD;
// 		this.StageNameLabel = OPPORTUNITY_STAGENAME_FIELD;

// 	}

// @wire(getPicklistValuesByRecordType, { objectApiName: OPPORTUNITY_OBJECT, recordTypeId: this.objectInfo.defaultRecordTypeId })
// wiredWorkPlanObjectInfo({ data, error }) {
// 		if(data){
// 				this.pickListInfo = data.picklistFieldValues;
// 				this.createMessage();
// 		} else if (error) {
// 				console.log('getPicklistValuesByRecordType error:' + error);
// 		}
// }
// 	async getPickListLabel(fieldApiName, fieldVal){
// 		//選択リスト値のラベルを取得
// 		if(this.pickListInfo[fieldApiName]){
// 				return this.pickListInfo[fieldApiName].values.find(data => data.value === fieldVal).label;
// 		}
// }

// 		// {
// 		// 	type: "button-icon",
// 		// 	fixedWidth: 40,
// 		// 	typeAttributes: {
// 		// 			iconName: "utility:delete",
// 		// 			name: "deleteRow",
// 		// 			disabled: { fieldName: "DisableDelete" }
// 		// 	}
// 		// }
// 		{
//       label: 'Delete',
//       type: 'deleteRowButton',
//       fieldName: 'id',
//       fixedWidth: 70,
//       typeAttributes: {
//         attrA: { fieldName: 'attrA' },
//         attrB: { fieldName: 'attrB' },
//       },
//   	},

// 	]

// @track data = [
//   {
//     id: '1',
//     name: 'Name1',
//     attrA: 'A1',
//     attrB: 'B1',
//   },
//   {
//     id: '2',
//     name: 'Name2',
//     attrA: 'A2',
//     attrB: 'B2',
//   }
// ];
// @track columns = columns;

// deleteRow(event) {
// 		const { rowId } = event.detail;
// 		window.console.log(rowId, event);
// 		// Remove the row
// }
// valueChange(event){
// 	this.inputValue = event.detail.value;
// }
