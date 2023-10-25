
trigger employeeTrigger on employee__c (after insert,after update) {
  if(Trigger.isInsert && Trigger.isAfter) {
    recordHandler.afterInsert(Trigger.new);		
  } else if (Trigger.isUpdate && Trigger.isAfter) {
		recordHandler.afterUpdate(Trigger.oldMap,Trigger.new);		
  }
}