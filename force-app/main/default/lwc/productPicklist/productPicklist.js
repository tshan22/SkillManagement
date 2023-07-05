import { LightningElement, api } from "lwc";

export default class ProductPicklist extends LightningElement {
  @api fieldName;
  @api label;
  @api value;
  @api options;
  @api recordId;

  handleChange(event) {
    this.value = event.target.value;

    const changeEvent = new CustomEvent("select", {
			bubbles: true,
      composed: true,
			cancelable: true,
      detail: {
        label: this.label,
        name: this.fieldName,
        value: this.value,
        id: this.recordId
      }
    });
    this.dispatchEvent(changeEvent);
  }
}