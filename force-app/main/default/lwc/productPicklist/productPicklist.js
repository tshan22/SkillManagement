import { LightningElement,api} from 'lwc';

export default class ProductPicklist extends LightningElement {
	@api name;
	@api label;
	@api value;
	@api options;
	@api eventContext;

	valueChange(event){
		this.value = event.target.value;

		const changeEvent = new CustomEvent("change",{
			detail:{
				label:this.label,
				name:this.name,
				value:this.value,
				context:this.eventContext
			}
		});
		this.dispatchEvent(changeEvent);

	}

}