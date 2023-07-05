import { LightningElement,api } from 'lwc';

export default class StageNamePicklist extends LightningElement {
	@api fieldName;
	@api label;
	@api value;
	@api options;
	@api recordId;

	handleChange(event){
		this.value = event.target.value;

		const changeEvent = new CustomEvent("select",{
			bubbles: true,
      composed: true,
			cancelable: true,

			detail:{
				label:this.label,
				id:this.recordId,
				value:this.value,
				name:this.fieldName
			}
		});
		this.dispatchEvent(changeEvent);

	}

}