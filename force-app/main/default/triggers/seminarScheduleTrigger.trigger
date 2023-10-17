trigger seminarScheduleTrigger on seminarScheduleManagement__c (before insert,after insert,before update,after update,before delete) {
	if(Trigger.isInsert && Trigger.isAfter) {
    seminarController.afterInsert(Trigger.new);		
  } else if (Trigger.isUpdate && Trigger.isAfter) {
		recordHandler.afterUpdate(Trigger.oldMap,Trigger.new);		
  }

}