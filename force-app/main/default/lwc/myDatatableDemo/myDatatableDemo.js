import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import selectPickList from "@salesforce/apex/OpportunityManagement.selectPickList";
import myPickList from "@salesforce/apex/OpportunityManagement.myPickList";
import getdata from "@salesforce/apex/OpportunityManagement.getdata";
import STAGENAME_FIELD from "@salesforce/schema/Opportunity.StageName";

export default class MyDatatableDemo extends LightningElement {
  @api recordId;

  columns;
  opps;

  machineLabel;
  quantityLabel;
  StageNameLabel;
  defaultRecordTypeId;

  // isShowSpinner = true;

  objectInfo = [];
  oppMachine;
  oppStageName = [];

  //	Opportunityの情報を取得する
  @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
  opportunityObjectInfo({ data, error }) {
    if (data) {
      this.objectInfo = data;
      this.getLabel(this.objectInfo);
    } else if (error) {
      console.log("getObjectInfo error:" + error);
    }
  }
  @wire(getdata, { opportunityId: "$recordId" }) getOpp({ data, error }) {
    if (data) {
      this.opps = data;
    }
  }
  //選択リストの値を取得する
  @wire(getPicklistValues, {
    recordTypeId: "$defaultRecordTypeId",
    fieldApiName: STAGENAME_FIELD
  })
  opportunityStageNamePicklist({ data, error }) {
    if (data) {
      this.oppStageName = data.values;
      // console.log("wire--------->" + JSON.stringify(this.oppStageName));
    } else if (error) {
      console.log("選択リストの値を取得するエラー");
    }
  }

  //Apexメッソドを呼び出して、machine__cの情報を取得する
  @wire(selectPickList)
  opportunityItems({ data, error }) {
    if (data) {
      this.oppMachine = data;
      this.getPicklist(this.oppStageName, this.oppMachine);
    } else if (error) {
      console.log("getObjectInfo error:" + error);
    }
  }

  //ラベルを取得
  getLabel(objectInfo) {
    this.machineLabel = objectInfo.fields.machine__c.label;
    this.StageNameLabel = objectInfo.fields.StageName.label;
    this.quantityLabel = objectInfo.fields.quantity__c.label;
    this.defaultRecordTypeId = objectInfo.defaultRecordTypeId;
  }

  //選択リストの値を所得する
  getPicklist(oppStageName, oppMachine) {
    let stageNameOptions = [];
    oppStageName.forEach((e) => {
      stageNameOptions.push({ label: e.label, value: e.value });
    });

    let machineOptions = [];
    oppMachine.forEach((picklist) => {
      machineOptions.push({
        label: picklist.Label,
        value: picklist.Value
      });
    });
    console.log(machineOptions);

    this.columns = [
      {
        label: this.machineLabel,
        type: "machinePicklist",
        wrapText: true,
        typeAttributes: {
          label: this.machineLabel,
          options: machineOptions,
          value: { fieldName: "machine__c" },
          recordId: { fieldName: "Id" }
        }
      },
      { label: "台数", type: "text", fieldName: "quantity__c" },
      {
        label: this.StageNameLabel,
        type: "stageNamePicklist",
        wrapText: true,
        typeAttributes: {
          label: this.StageNameLabel,
          options: stageNameOptions,
          value: { fieldName: "StageName" },
          recordId: { fieldName: "Id" }
        }
      }
    ];
  }
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
