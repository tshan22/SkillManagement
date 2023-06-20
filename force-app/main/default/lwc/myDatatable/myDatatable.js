/* myDatatable.js */
import LightningDatatable from "lightning/datatable";
import deleteRow from "./deleteRow.html";
import inputNumberField from "./inputNumberField.html";
import stageNamePicklist from "./stageNamePicklist.html";
import productPicklist from "./productPicklist.html";

export default class MyDatatable extends LightningDatatable {
	static customTypes = {
		// 	inputNumberField: {
		// 		template: inputNumberField,
		// 		typeAttributes: ["recordId", "value", "fieldName", "maxLength"]
		// },
		// deleteRowButton: {
		// 		template: deleteRow,
		// 		// Provide template data here if needed
		// 		typeAttributes: ['attrA', 'attrB'],
		// },
		productPicklist: {
			template: productPicklist,
			typeAttributes: ["label", "options", "value", "recordId","fieldName"]
		},
		inputNumberField: {
			template: inputNumberField,
			typeAttributes: ["recordId", "value", "fieldName", "maxLength"]
		},
		stageNamePicklist: {
			template: stageNamePicklist, //main JSにtypeの名前
			typeAttributes: ["label", "options", "value", "recordId","fieldName"] //main jsに定義したもの
		}
	};

	//more custom types here
}
