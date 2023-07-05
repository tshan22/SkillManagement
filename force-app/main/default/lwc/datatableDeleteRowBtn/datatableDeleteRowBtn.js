/* datatableDeleteRowBtn.js */
import { LightningElement, api } from 'lwc';
// Accessibility module
import { baseNavigation } from 'lightning/datatableKeyboardMixins';
// For the render() method
import template from './datatableDeleteRowBtn.html';

// export default class DatatableDeleteRowBtn extends baseNavigation(LightningElement) {
export default class DatatableDeleteRowBtn extends LightningElement {
    @api recordId;
	  @api iconName;
    @api name;
    @api disabled;

    // Required for mixins
    render() {
        return template;
    }

    fireDeleteRow() {    
			const clickEvent = CustomEvent('deleterow', {
					composed: true,
					bubbles: true,
					cancelable: true,
					detail: {
							id: this.recordId,
							name:this.name,
					},
			});
			this.dispatchEvent(clickEvent );
		}   
}