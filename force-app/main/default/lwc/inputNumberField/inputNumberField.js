import { LightningElement,api } from 'lwc';




export default class InputNumberField extends LightningElement {
    @api name;
    @api value;
    @api eventContext;
    @api maxLength;

    handleChange(event) {
			
        const changeEvent = new CustomEvent("change", {
            composed: this.eventContext != null,
            bubbles: this.eventContext != null,
            cancelable: this.eventContext != null,
            detail: {
                name: this.name,
                value: event.detail.value,
                context: this.eventContext
            }
        });
        this.dispatchEvent(changeEvent);
    }
}
