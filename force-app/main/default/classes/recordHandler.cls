public with sharing class recordHandler {
	public static boolean triggerCalled = false;

	public static void afterInsert(List<employee__c> newReocrds) {
		// 従業員作成する際に、連結オブジェクトが自動的に作成されます
		List<emCertificationRelation__c> newBridge = new List<emCertificationRelation__c>();
		List<employee__c> employees = [SELECT Id, Name, OwnedCertification__c,employeeName__c FROM employee__c WHERE Id IN :newReocrds];
		List<employee__Share> emShare = new List<employee__Share>();

		for(employee__c newList :employees) {
			emShare.add(new employee__Share(
				ParentId = newList.id,
				AccessLevel = 'Edit',
				RowCause = 'Manual',
				UserOrGroupId = newList.employeeName__c
			));
			if(newList.OwnedCertification__c == null){
				continue;
			}else if(newList.OwnedCertification__c.length()!= 0){
				List<String> lists = newList.OwnedCertification__c.split(';');
				for(Integer i = 0;i<lists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(lists[i]);					
					newBridge.add(new emCertificationRelation__c(
						employeeRelation__c = newList.Id,
						CertificationRelation__c = cfInfos.Id)
					);
				}	
			}
		}
 
		if(newBridge.size()>0){
			insert newBridge;
		}
		insert emShare;

  }

	public static void afterUpdate(Map<Id,employee__c> oldMap,List<employee__c> newReocrds) {

		// List<employee__c> afterEmployees = [SELECT Id, Name, OwnedCertification__c FROM employee__c WHERE Id IN :newReocrds];

		// List<employee__c> beforeEmployees = new List<employee__c>();

		// List<emCertificationRelation__c> bridge = new List<emCertificationRelation__c>();
		List<emCertificationRelation__c> newBridge = new List<emCertificationRelation__c>();
		List<emCertificationRelation__c> deleteRecords = new List<emCertificationRelation__c>();

		List<Id> ids = new List<Id>();


		for(employee__c newList :newReocrds) {

			if(oldMap.get(newList.Id).OwnedCertification__c == null && newList.OwnedCertification__c != null){
				List<String> afterLists = newList.OwnedCertification__c.split(';',22);
				for(Integer i = 0;i<afterLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(afterLists[i]);	
					emCertificationRelation__c bridgeInfos = new emCertificationRelation__c(employeeRelation__c = newList.Id,CertificationRelation__c = cfInfos.Id);

					newBridge.add(bridgeInfos);	
				}					
			}else if(oldMap.get(newList.Id).OwnedCertification__c != null && newList.OwnedCertification__c != null){
					List<String> afterLists = newList.OwnedCertification__c.split(';',22);
					List<String> oldLists = oldMap.get(newList.Id).OwnedCertification__c.split(';',22);
					// beforeEmployees.add(oldMap.get(newList.id));

				for(Integer i = 0;i<oldLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(oldLists[i]);	
					emCertificationRelation__c bridgeInfos = recordController.getBridgeInfos(oldMap.get(newList.id).Id,cfInfos.Id);
					// bridge.add(bridgeInfos);
					ids.add(bridgeInfos.CertificationRelation__c);

					if(!afterLists.contains(oldLists[i])){
						deleteRecords.add(bridgeInfos);
					}
				}

				for(Integer i = 0;i<afterLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(afterLists[i]);		

					emCertificationRelation__c bridgeInfos = new emCertificationRelation__c(employeeRelation__c = newList.Id,CertificationRelation__c = cfInfos.Id);
					// System.debug('s');

					if(!ids.contains(bridgeInfos.CertificationRelation__c)){
						newBridge.add(bridgeInfos);

							// employeeRelation__c = newList.Id,
							// CertificationRelation__c = cfInfos.Id)
					}
				}
			}else if(oldMap.get(newList.Id).OwnedCertification__c != null && newList.OwnedCertification__c == null){
				List<String> oldLists = oldMap.get(newList.Id).OwnedCertification__c.split(';',22);

				for(Integer i = 0;i<oldLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(oldLists[i]);	
					emCertificationRelation__c bridgeInfos = recordController.getBridgeInfos(oldMap.get(newList.id).Id,cfInfos.Id);
					deleteRecords.add(bridgeInfos);
				}
			}else{
				continue;
			}
		}

		if(deleteRecords.size()>0){
			delete deleteRecords;
		}
		if(newBridge.size()>0){
			upsert newBridge;
		}

	}


	public static void certificationUpdate(List<certification__c> updateRecords,Map<Id,certification__c> oldMap){
		// Set<Id> ids = new Set<Id>();
		List<certification__c> certifications = [SELECT id,Name,HasUpdate__c,UpdateDate__c,(SELECT Id, Name,employeeRelation__c,employeeRelation__r.Name,employeeRelation__r.HasUpdate__c,employeeRelation__r.UpdateCetifications__c,employeeRelation__r.UpdateDate__c FROM CertificationRelations__r) FROM certification__c WHERE id IN :updateRecords];
		List<employee__c> em = new List<employee__c>();


		for(certification__c u : certifications){
			if(u.UpdateDate__c !=null && u.UpdateDate__c != oldMap.get(u.id).UpdateDate__c){				
				u.HasUpdate__c = '必要';
				for(emCertificationRelation__c ecf: u.CertificationRelations__r){
						em.add(ecf.employeeRelation__r);
					// ids.add(ecf.employeeRelation__c);
					ecf.employeeRelation__r.HasUpdate__c = '有り';

					//従業員「更新必要な資格」項目、複数選択クリストの追加、更新
					// if(ecf.employeeRelation__r.UpdateCetifications__c == null){
					// 	ecf.employeeRelation__r.UpdateCetifications__c = ' ';
					// }
					// ecf.employeeRelation__r.UpdateCetifications__c += ';' + u.Name;

					//従業員「更新期限」項目 ロングテキストエリア、エラー
					// String updateDate = String.valueOf(u.UpdateDate__c);
					// if(ecf.employeeRelation__r.UpdateDates__c == null){
					// 	ecf.employeeRelation__r.UpdateDates__c = ' ';
					// }
					// ecf.employeeRelation__r.UpdateDates__c += ';'+ u.Name + ':'+ updateDate;
				}	
			}
		}

		// List<employee__c> em = [SELECT Id,Name,HasUpdate__c,UpdateDate__c,employeeName__c FROM employee__c WHERE id IN :ids];
		// for(employee__c e : em){
		// 	e.HasUpdate__c = '有り';
		// }
    update certifications;
		update em;
	}
}