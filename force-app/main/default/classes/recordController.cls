public with sharing class recordController {
	//従業員情報を取得する
	@AuraEnabled(cacheable=true)
	public static List<employee__c> getinformation(){
		return [SELECT id,Name,employeeName__r.Name,(SELECT seminarName__c,seminarName__r.Name,ConcreteDateTime__c FROM employees__r),OwnedCertification__c,Position__c FROM employee__c];
    // return [SELECT id,Name,employeeName__r.Name AS 'employeeNam',(SELECT seminarName__c,ConcreteDateTime__c FROM employees__r),OwnedCertification__c,Position__c FROM employee__c];    
  }

	//従業員検索
	@AuraEnabled(cacheable=true)
	public static List<employee__c> searchEmployee(String inputName){
		String fields = '%' + inputName + '%';
    return [
      SELECT
				id,
        Name,
				employeeName__c,
				employeeName__r.Name,
				OwnedCertification__c,
				Position__c
      FROM  employee__c
      WHERE employeeName__r.Name LIKE :fields
      ORDER BY Name
    	];	
	}

	//受講履歴を取得する
	// @AuraEnabled(cacheable=true)
	// public static List<seminarAttendingHistory__c> getSeminarHistoryinfo(String inputName){
	// 	String fields = '%' + inputName + '%';
  //   return [
  //     SELECT
	// 			id,
  //       Name,
	// 			ConcreteDateTime__c,
	// 			employeeId__c,
	// 			seminarName__c	
  //     FROM  seminarAttendingHistory__c  
  //   ];	
	// }

	//セミナ情報を取得する
	@AuraEnabled(cacheable=true)
	public static List<seminar__c> searchSeminar(String inputKeyword){
		String fields = '%' + inputKeyword + '%';
    return [
      SELECT
				id,
        Name,
        SeminaName__c,
				Price__c
      FROM  seminar__c
      WHERE Name LIKE :fields
      ORDER BY Name
    ];
	}

	//資格情報を取得する
	@AuraEnabled(cacheable=true)
	public static certification__c getCertificationInfos(String inputName){

		return [
			SELECT 
				id,
				Name
			FROM certification__c
			WHERE Name = :inputName
			LIMIT 1];		
	}
	
	//従業員と資格の連結オブジェクト情報を取得する
	@AuraEnabled(cacheable=true)
	public static emCertificationRelation__c getBridgeInfos(Id emId,Id cfId){

		return [
			SELECT 
				id,
				Name,	
				employeeRelation__c,
				CertificationRelation__c
			FROM emCertificationRelation__c
			WHERE  employeeRelation__c =: emId AND CertificationRelation__c =: cfId
			LIMIT 1];		
	}

	//セミナ開催日程を取得する
	@AuraEnabled(cacheable=true)
	public static List<seminarScheduleManagement__c> getSeminarSchedule(List<seminar__c> selectedLists){
	
			// List<seminarScheduleManagement__c> scheduleList = new List<seminarScheduleManagement__c>();
			
			// List<seminar__c> semi = [SELECT Id,Name,SeminaName__c,(SELECT Id,Name,seminar__c,form__c,Venue__c,DateTime__c FROM seminarRelations__r)FROM seminar__c WHERE id IN:selectedLists];
			List<seminarScheduleManagement__c> schList = [SELECT Id,Name,seminar__c,seminar__r.Name,form__c,Venue__c,DateTime__c FROM seminarScheduleManagement__c WHERE seminar__c IN:selectedLists];

		// for(seminar__c s : semi){			
		// 	for(seminarScheduleManagement__c semiSch: s.seminarRelations__r){
		// 		scheduleList.add(semiSch);
		// 	}				
		// }		
		return schList;
	}
 
	//申し込み内容の確認
	@AuraEnabled(cacheable=true)
	public static List<seminarScheduleManagement__c> getAppliInfo(List<seminarScheduleManagement__c> selectedLists){
	
		List<seminarScheduleManagement__c> selectedSchedule = [SELECT Id,Name,seminar__c,seminar__r.Name,seminar__r.Price__c,form__c,Venue__c,Date__c,TimeFrom__c,TimeEnd__c,DateTime__c FROM seminarScheduleManagement__c WHERE id IN: selectedLists];

		return selectedSchedule;
	}

	//セミナ受講履歴を作成する
	@AuraEnabled
	public static void createAttendanceHistory(List<seminarScheduleManagement__c> appliInfo){
		List<seminarAttendingHistory__c> history = new List<seminarAttendingHistory__c>();

		String userId = userinfo.getUserId();
		employee__c employee = [SELECT id,Name,employeeName__c,employeeName__r.Name FROM employee__c WHERE employeeName__c =: userId LIMIT 1];
		List<seminarAttendingHistory__c> existHistory = [SELECT id,seminarName__c,ConcreteDateTime__c FROM seminarAttendingHistory__c WHERE employeeId__c =:employee.id];

		

		
		for(seminarScheduleManagement__c item : appliInfo){
			
				history.add(new seminarAttendingHistory__c(
				employeeId__c = employee.id,
				EmployeeName__c = employee.employeeName__r.Name,
				seminarName__c =item.seminar__c,
				Price__c =item.seminar__r.Price__c,
				TimeFrom__c = item.TimeFrom__c,
				TimeEnd__c = item.TimeEnd__c,
				ConcreteDateTime__c=item.DateTime__c,
				Form__c=item.form__c,
				Venue__c =item.Venue__c
				));
			}
		
		if(history.size()>0){
			insert history;
		}
	}
}