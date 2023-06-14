import { LightningElement,api } from 'lwc';




export default class InputNumberField extends LightningElement {
    @api name;//id
    @api value;
    @api eventContext;
    @api maxLength;

    handleChange(event) {
			this.value = event.target.value
			
    const changeEvent = new CustomEvent("change", {
            // composed: this.eventContext != null,
            // bubbles: this.eventContext != null,
            // cancelable: this.eventContext != null,
	

            detail: {
                name: this.name,
                value: this.value,
                context: this.eventContext
            }
        });
        this.dispatchEvent(changeEvent);
    }
}
