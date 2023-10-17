public with sharing class seminarHandler {
	public static void afterInsert(List<seminarAttendingHistory__c> newRecords){
		List<seminarAttendingHistory__c> records = [SELECT Id, employeeId__c,employeeId__r.seminarAmount__c,employeeId__r.employeeName__c,Price__c FROM	seminarAttendingHistory__c WHERE id IN :newRecords];
		List<seminarAttendingHistory__Share> seHisShare = new List<seminarAttendingHistory__Share>();
		List<employee__c> forUpdates = new List<employee__c>();

		for(seminarAttendingHistory__c e :records){
			employee__c em = e.employeeId__r;

			//共有レコード作成する
			// seHisShare.add(new seminarAttendingHistory__Share(
			// 	ParentId = e.id,
			// 	AccessLevel = 'Edit',
			// 	RowCause = 'Manual',
			// 	UserOrGroupId = em.employeeName__c
			// ));

			//関連従業員のセミナ合計金額集計			
			if(em.seminarAmount__c == null){
				em.seminarAmount__c = 0;
			}
			em.seminarAmount__c += e.Price__c;
			forUpdates.add(em);
		}
		update forUpdates;
		// insert seHisShare;
	}

	public static void taskCreated(List<seminarAttendingHistory__c> newRecords){
		List<seminarAttendingHistory__c> records = [SELECT Id,Name,Form__c,Venue__c,seminarName__c,seminarName__r.Name,employeeId__c,EmployeeName__c,employeeId__r.Name,employeeId__r.employeeName__c,ConcreteDateTime__c,Status__c FROM seminarAttendingHistory__c WHERE id IN :newRecords];
		List<Event> newEvent = new List<Event>();

		for(seminarAttendingHistory__c r :records){
			employee__c em = r.employeeId__r;
			String con = r.ConcreteDateTime__c;
			String st = con.substring(0, 10) +' ' + con.substring(14, 22);
			String et = con.substring(0, 10) +' ' + con.substring(23);
			Datetime startTime = Datetime.valueOfGMT(st);
			Datetime endTime = Datetime.valueOfGMT(et);
			if(r.Form__c == 'オンライン'){
				newEvent.add(new Event(
					Subject = '受講予定:' + r.seminarName__r.Name,
					StartDateTime = startTime,
					EndDateTime = endTime,
					WhatId = r.employeeId__c,
					Location = r.Form__c
				));
			}else {
				newEvent.add(new Event(
					Subject = '受講予定',
					StartDateTime = startTime,
					EndDateTime = endTime,
					WhatId = r.employeeId__c,
					Location = r.Venue__c
				));
			}
			
		}
		insert newEvent;
	}
	
	

}