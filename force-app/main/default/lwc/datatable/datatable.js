import LightningDatatable from "lightning/datatable";
import recordPage from "./recordPage.html";
import inputNumberField from "./inputNumberField.html";
import selectField from "./selectField.html";

export default class Datatable extends LightningDatatable {
    static customTypes = {
        /**
         * レコードページへのリンク
         * 例えば、[SELECT Id, Name, Opportunity.Id, Opportunity.Name, Opportunity.Account.Id, Opportunity.Account.Name FROM OpportunityLineItem]としている場合、
         * 商談商品へのリンクはfieldNameにId項目、typeAttributes.labelにName項目を指定する。
         *
         * ```
         * { type: "recordPage", fieldName: "Id", typeAttributes: { objectApiName: "OpportunityLineItem", label: { fieldName: "Name" } } }
         * ```
         *
         * 商談へのリンクは、fieldNameにOpportunityを指定する。typeAttributes.recordIdField, typeAttributes.labelFieldも指定できるが、それぞれデフォルトでId, Nameなので指定しなくても良い。
         *
         * ```
         * { type: "recordPage", fieldName: "Opportunity", typeAttributes: { objectApiName: "Opportunity" } }
         * ```
         *
         * 取引先へのリンクはこのように指定できる。ただし商談へのリンクとfieldNameがかぶるため、不都合があるならこのような指定はせず、クエリ結果を加工する。
         *
         * ```
         * { type: "recordPage", fieldName: "Opportunity", typeAttributes: { objectApiName: "Account", recordIdField: 'Account.Id', labelField: 'Account.Name' } }
         * ```
         *
         * ドット記法が使用できるのはtypeAttributes.recordIdField, typeAttributes.labelFieldのみ。fieldNameには使用できないので注意。
         */
        recordPage: {
            template: recordPage,
            standardCellLayout: true,
            typeAttributes: ["action", "label", "labelField", "recordIdField", "objectApiName"]
        },
        /**
         * 数値入力フィールド
         */
        inputNumberField: {
            template: inputNumberField,
            typeAttributes: ["recordId", "value", "fieldName", "maxLength"]
        },
        /**
         * 選択リストフィールド
         */
        selectField: {
            template: selectField,
            typeAttributes: [
                "recordId",
                "emptyLabel",
                "options",
                "optgroup",
                "disabled",
                "required",
                "multiple",
                "value",
                "fieldName"
            ]
        }
    };
}