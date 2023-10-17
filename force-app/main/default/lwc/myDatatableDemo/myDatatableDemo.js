import { LightningElement, api, wire } from "lwc";
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { deleteRecord } from "lightning/uiRecordApi";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";
import OPPORTUNITY_ITEM_OBJECT from "@salesforce/schema/OpportunityItem__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import STAGENAME_FIELD from "@salesforce/schema/Opportunity.StageName";

import getData from "@salesforce/apex/OpportunityManagement.getData";
import getLabel from "@salesforce/apex/OpportunityManagement.getLabel";
import getStageNamePickList from "@salesforce/apex/OpportunityManagement.getStageNamePickList";
import getProductPickList from "@salesforce/apex/OpportunityManagement.getProductPickList";
import updateItem from "@salesforce/apex/OpportunityManagement.updateItem";



const toastInfo = {
	success: { title: "sucess", message: "更新しました", variant: "success" },
	error: { title: "error", message: "エラー発生しました", variant: "error" }
};



export default class MyDatatableDemo extends LightningElement {

	@api recordId;
	columns;
	opportunityItems;

	//ラベル名
	productLabel;
	unitCountsLabel;
	stageNameLabel;

	//選択肢
	productOptions = [];
	stageNameOptions = [];

	//datatable更新のため
	resultOpportunityItems = [];
	//削除された行
	deleteOpportunityItems = [];
	//追加する行のIDのため
	count = 1;



	async connectedCallback() {
		try {
			//列のラベル名を取得する
			this.productLabel = await getLabel({ fieldName: "Product2__c" });
			this.unitCountsLabel = await getLabel({ fieldName: "UnitCounts__c" });
			this.stageNameLabel = await getLabel({ fieldName: "StageName__c" });

			// console.log('2222222222222--------------------------------------------------');
			// console.log(this.productLabel);
			// console.log(this.unitCountsLabel);
			// console.log(this.stageNameLabel)

			//選択リストの選択肢を取得する
			const productPicklist = await getProductPickList();
			const stageNamePicklist = await getStageNamePickList();

			// console.log('mae:',this.productOptions);
			// console.log('3333333333333333----------------------------------');
			// console.log('機種選択肢');
			// console.log(productPicklist);
			// console.log('フェーズ選択肢');
			// console.log(stageNamePicklist);

			//optionsをセットする
			this.setOptions(productPicklist, stageNamePicklist);

			//Cloumns
			this.setColumns();


			//data
			// const opportunityItems = await getData({ opportunityId: this.recordId });
			// this.opps = opportunityItems;
			// console.log(',,,,,,,,,,,,,,,,,,,,,');
			// console.log(JSON.stringify(this.opps));
			// console.log('before delete',this.opps.length);
		} catch (error) {
			console.error(error.message);
		}
	}
	//data
	@wire(getData, { 'opportunityId': '$recordId' })
	wiredOpportunityItems(result) {
		this.resultOpportunityItems = result;
		if (result.data) {
			this.opportunityItems = result.data;
		} else if (result.error) {
			console.log('error');
		}
	}


	//選択リストの値を取得する
	setOptions(productPicklist, stageNamePicklist) {
		//Product２__c選択肢を取得
		productPicklist.forEach((e) => {
			this.productOptions.push({
				label: e.Name,
				value: e.Id
			});
		});
		//StageName選択肢を取得
		stageNamePicklist.forEach((e) => {
			this.stageNameOptions.push({
				label: e.label,
				value: e.value
			});
		})
	}



	//colmnsを定義する
	setColumns() {
		this.columns = [
			{
				label: this.productLabel,
				type: "productPicklist",
				wrapText: true,
				typeAttributes: {
					options: this.productOptions,
					value: { fieldName: "Product2__c" },
					fieldName: "Product2__c",
					recordId: { fieldName: "Id" }
				}
			},
			{
				label: this.unitCountsLabel,
				fieldName: "UnitCounts__c",
				type: "inputNumberField",
				wrapText: true,
				typeAttributes: {
					value: { fieldName: "UnitCounts__c" },
					recordId: { fieldName: "Id" },
					fieldName: "UnitCounts__c",
					maxLength: "2"
				}
			},
			{
				label: this.stageNameLabel,
				type: "stageNamePicklist",
				wrapText: true,
				typeAttributes: {
					options: this.stageNameOptions,
					value: { fieldName: "StageName__c" },
					fieldName: "StageName__c",
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
		]
	}

	//datatableの行を追加する
	addRow() {
		const newOpportunityItem = {
			Opportunity__c: this.recordId,
			Product2__c: "",
			UnitCounts__c: "",
			StageName__c: "",
			Id: this.recordId + "NEW" + this.count
		};
		this.opportunityItems = [...this.opportunityItems, newOpportunityItem];
		this.count++;
	}

	//行を削除する
	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		if (actionName === "deleteRow") {
			this.deleteRow(row);
		}
	}
	deleteRow(row) {
		const deleteRows = this.opportunityItems.filter((e) => e.Id === row.Id);
		const remainRows = this.opportunityItems.filter((e) => e.Id !== row.Id);
		// console.log(deleteRows.length);
		if (deleteRows.length > 0) {
			this.opportunityItems = remainRows;
			// console.log(remainRows);
			// console.log('AND');
			console.log('delete rows:', deleteRows[0]);
			this.deleteOpportunityItems.push(deleteRows[0]);
		}

		// console.log('after delete');
		// console.log(this.opps);
		// console.log('opps length:',this.opps.length);
		// console.log('delete length:',this.deleteOpportunityItems.length);
		// console.log(this.deleteOpportunityItems[0]);
	}

	//値を変更
	handleChange(event) {
		// const value = event.detail.value;
		// const recordId = event.detail.id;
		// const fieldName = event.detail.name;

		let data = this.opportunityItems.map((item) => {
			return { ...item };
		});

		// const updateRows = data.filter((e) => e.Id === recordId);	
		const { value, id, name } = event.detail;

		this.opportunityItems = data.map((record) => {
			if (record.Id === id) {
				record[name] = value;
			}
			return { ...record };
		});
	}


	//保存ボタン押す
	save() {
		//upsert
		this.opportunityItems.map((record) => {
			if (record.Id.includes("NEW")) {
				record.Id = null;
			}
			return record;
		});

		updateItem({ items: this.opportunityItems, deleteOpportunityItems: this.deleteOpportunityItems })
			.then(() => {
				refreshApex(this.resultOpportunityItems);

				this.startToast(toastInfo.success);
				this.close();
			})
			.catch(() => {
				this.startToast(toastInfo.error);
			});

	}
	startToast(info) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: info.title,
				message: info.message,
				variant: info.variant
			})
		)
	};


	//キャンセル、フローが終わり
	close() {
		const navigateFinishEvent = new FlowNavigationFinishEvent();
		this.dispatchEvent(navigateFinishEvent);
	}
}