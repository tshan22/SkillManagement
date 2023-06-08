import { LightningElement, api } from "lwc";
import FIELD_REQUIRED from "@salesforce/label/c.FieldRequired";
import REQUIRED from "@salesforce/label/c.Required";
import { className } from "c/util";


export default class Select extends LightningElement {
	@api name;
	@api label;
	@api emptyLabel;
	@api options;
	@api optgroup;
	@api disabled;
	@api required;
	@api eventContext
	_multiple;
	_value;
	customValidity;
	dirty = false;
	_label = { REQUIRED };

	get value() {
			return this._value ? this._value : "";
	}

	@api set value(value) {
			this._value = value;
			const el = this.template.querySelector("select");
			if (el) {
					el.value = this.multiple ? "" : value;
			}
	}

	get multiple() {
			return this._multiple;
	}

	@api set multiple(value) {
			this._multiple = value;
			const el = this.template.querySelector("select");
			if (el) {
					el.value = this.multiple ? "" : this.value;
			}
	}

	@api pristine() {
			this.dirty = false;
	}

	@api touch() {
			this.dirty = true;
	}

	get errorMessage() {
			if (this.customValidity) {
					return this.customValidity;
			}
			if (this.required && !this.value) {
					return FIELD_REQUIRED;
			}
			return null;
	}

	@api
	setCustomValidity(message) {
			this.customValidity = message;
	}

	@api
	checkValidity() {
			return !this.errorMessage;
	}

	@api
	reportValidity() {
			this.touch();
			return this.checkValidity;
	}

	get hasValues() {
			return this.multiple && Array.isArray(this.value) && this.value.length > 0;
	}

	get valueWithLabel() {
			return this.value.map((value) => ({
					value,
					label: this.findLabel(value)
			}));
	}

	get showError() {
			return this.dirty && !this.checkValidity();
	}

	get hasLabel() {
			return this.label != null;
	}

	get hasEmptyLabel() {
			return this.emptyLabel != null || this.isGroup;
	}

	get emptySelected() {
			return !this.value;
	}

	get formElementClass() {
			return className("slds-form-element", { "slds-has-error": this.showError });
	}

	get isGroup() {
			return this.optgroup != null;
	}

	get optgroupWithSelected() {
			if (!this.optgroup) {
					return [];
			}
			return this.optgroup.map((g, gIndex) => ({
					label: g.label,
					key: gIndex,
					options: this.buildOptionsWithSelected(g.options, gIndex)
			}));
	}

	get optionsWithSelected() {
			if (!this.options) {
					return [];
			}
			return this.buildOptionsWithSelected(this.options);
	}

	get disabledValues() {
			if (!this.multiple) {
					return new Set();
			}
			return Array.isArray(this.value) ? new Set(this.value) : this.value ? new Set([this.value]) : new Set();
	}

	buildOptionsWithSelected(options, keyPrefix) {
			const disabledValues = this.disabledValues;
			return options.map((e, i) => ({
					label: e.label,
					value: e.value,
					disabled: e.disabled || disabledValues.has(e.value) ? true : null,
					selected: e.value === this.value ? true : null,
					key: JSON.stringify([keyPrefix, i])
			}));
	}

	get selectedLabel() {
			let selected;
			if (this.isGroup) {
					let options = this.optgroup.reduce((a, e) => a.concat(e.options), []);
					selected = options.find((e) => e.value === this.value);
			} else if (this.options != null) {
					selected = this.options.find((e) => e.value === this.value);
			}
			return selected ? selected.label : null;
	}

	handleChange(event) {
			event.stopPropagation();
			const value = this.multiple ? this.concatValue(event.target.value) : event.target.value;
			this.dispatchEvent(
					new CustomEvent("change", {
							composed: this.eventContext != null,
							bubbles: this.eventContext != null,
							cancelable: this.eventContext != null, 
							detail: {
									value: value,
									name: this.name,
									context: this.eventContext
							}
					})
			);
	}

	removeValue(event) {
			if (Array.isArray(this.value)) {
					const value = this.value.filter((e) => e !== event.target.name);
					this.dispatchEvent(
							new CustomEvent("change", {
									composed: this.eventContext != null,
									bubbles: this.eventContext != null,
									cancelable: this.eventContext != null, 
									detail: {
											value: value,
											name: this.name,
											context: this.eventContext
									}
							})
					);
			}
	}

	concatValue(value) {
			return Array.isArray(this.value) ? this.value.concat(value) : this.value ? [this.value, value] : [value];
	}

	handleBlur() {
			this.dirty = true;
	}

	findLabel(value) {
			if (this.optgroup) {
					for (let group of this.optgroup) {
							const item = group.options.find((e) => e.value === value);
							if (item) {
									return item.label;
							}
					}
					return value;
			}
			const item = this.options.find((e) => e.value === value);
			return item ? item.label : value;
	}
}