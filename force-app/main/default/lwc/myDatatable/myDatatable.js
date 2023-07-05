/* myDatatable.js */
import LightningDatatable from "lightning/datatable";
import inputNumberField from "./inputNumberField.html";
import stageNamePicklist from "./stageNamePicklist.html";
import productPicklist from "./productPicklist.html";

export default class MyDatatable extends LightningDatatable {
	static customTypes = {
		productPicklist: {
			template: productPicklist,
			typeAttributes: ["fieldName","label", "value", "recordId","options" ]
		},
		inputNumberField: {
			template: inputNumberField,
			typeAttributes: [ "fieldName", "value", "recordId","maxLength"]
		},
		stageNamePicklist: {
			template: stageNamePicklist, //main JSにtypeの名前
			typeAttributes: ["label", "options", "value", "recordId","fieldName"] //main jsに定義したもの
		}
	};
}