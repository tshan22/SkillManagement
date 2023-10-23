public without sharing class schedualCreateTask implements Schedulable {
	 
  public void execute(SchedulableContext ctx) {

		Date schedualDate = date.today().addMonths(2);

		List<certification__c> cf=[
			SELECT
				id,
				Name,
				HasUpdate__c,
				UpdateDate__c,
				(SELECT Id, Name,employeeRelation__c FROM CertificationRelations__r) 
			FROM certification__c
			WHERE HasUpdate__c = '必要' AND  UpdateDate__c <=: schedualDate 
		];

		List<Task> newTask = new List<Task>();
		for(certification__c u : cf){
			for(emCertificationRelation__c ecf: u.CertificationRelations__r){
				newTask.add(new Task(
					Subject = '資格更新',		
					ActivityDate = u.UpdateDate__c,
					WhatId = ecf.employeeRelation__c
				));
			}
		}
		insert newTask;
	}   
}
