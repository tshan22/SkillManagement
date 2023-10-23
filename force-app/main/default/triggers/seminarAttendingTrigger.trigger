trigger seminarAttendingTrigger on seminarAttendingHistory__c (after insert)  {
  recordHandler.semiHisAfterInsert(Trigger.new);		
	recordHandler.newEventCreated(Trigger.new);
  
}