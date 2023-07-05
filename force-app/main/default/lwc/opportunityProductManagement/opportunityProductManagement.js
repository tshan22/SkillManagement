import { LightningElement,api } from 'lwc';

export default class OpportunityProductManagement extends LightningElement {
	@api recordId;

	isDisplayErrorPanel = true;
	saveErrorTitle = 'test';
	panelErrorMessage='hello';

	// label = {
	// 		save,
	// 		cancel,
	// 		deleteableStageName,
	// 		noChangeInOpportunityItemRecord,
	// 		opportunityItemSaveCompleted,
	// 		someFieldsNotEntered,
	// 		unitCountsInputError,
	// 		saveErrorTitle
	// };

	// unitCountsLabel;
	// stageNameLabel;
	// product2Label;

	// data = [];
	// originalData = [];
	// columns;

	// defaultRecordTypeId;

	// isNotSavable = false;
	// isShowSpinner = true;
	// isDisplayErrorPanel = false;
	// panelErrorMessage;

	// deleteOpportunityItems = [];
}