import { LightningElement, api } from "lwc";

export default class InputNumberField extends LightningElement {
  @api fieldName;
  @api value;
  @api recordId;
  @api maxLength;

  handleChange(event) {
    this.value = event.target.value;

    const changeEvent = new CustomEvent("input", {
      bubbles: true,
      composed: true,
			cancelable: true,
      detail: {
        name: this.fieldName,
        value: this.value,
        id: this.recordId,
        // actionName: "input"
      }
    });
    this.dispatchEvent(changeEvent);
  }
}