public with sharing class recordController {
	@AuraEnabled(cacheable=true)
	public static List<employee__c> getinformation(){
		return [SELECT id,Name,employeeName__r.Name,(SELECT seminarName__c,ConcreteDateTime__c FROM employees__r),OwnedCertification__c,Position__c FROM employee__c];
		
	}

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
		@AuraEnabled(cacheable=true)
	public static List<employee__c> getSeminarHistoryinfo(String inputName){
			String fields = '%' + inputName + '%';
    return [
      SELECT
				id,
        Name,
				ConcreteDateTime__c,
				employeeId__c,
				seminarName__c
	
      FROM  seminarAttendingHistory__c
      WHERE employeeName__r.Name LIKE :fields
      ORDER BY Name
    ];
		
	}

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
		


	@AuraEnabled(cacheable=true)
	public static certification__c getCertificationInfos(String name){

		return [
			SELECT 
				id,
				Name,	
				CertificationClassification__c 
			FROM certification__c
			WHERE Name =: name
			LIMIT 1];
		
	}
	
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
}