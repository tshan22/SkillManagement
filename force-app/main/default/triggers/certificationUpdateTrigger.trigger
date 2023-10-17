trigger certificationUpdateTrigger on certification__c (after update) {
	 if (!recordHandler.triggerCalled) {
			recordHandler.triggerCalled = true;
			recordHandler.certificationUpdate(Trigger.new,Trigger.oldMap);
		}

}