trigger seminarAttendingTrigger on seminarAttendingHistory__c (before insert,after insert,before update,after update,before delete)  {
	if(Trigger.isInsert && Trigger.isAfter) {
    seminarHandler.afterInsert(Trigger.new);		
		seminarHandler.taskCreated(Trigger.new);
  } 
}