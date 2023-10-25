public with sharing class recordHandler {
	public static boolean triggerCalled = false;

	public static void afterInsert(List<employee__c> newReocrds) {
		// 従業員作成する際に、連結オブジェクトが自動的に作成されます
		List<emCertificationRelation__c> newBridge = new List<emCertificationRelation__c>();
		List<employee__c> employees = [SELECT Id, Name, OwnedCertification__c,employeeName__c FROM employee__c WHERE Id IN :newReocrds];
		List<employee__Share> emShare = new List<employee__Share>();
   
		for(employee__c newList :employees) {
			//従業員にアクセス権を付与する
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
					if(cfInfos.Id != null){
						newBridge.add(new emCertificationRelation__c(
							employeeRelation__c = newList.Id,
							CertificationRelation__c = cfInfos.Id)
						);
					}					
				}	
			}
		}
 
		if(newBridge.size()>0){
			insert newBridge;
		}
		insert emShare;
  }

	//保有資格を更新する際に、連結オブジェクトも更新する
	public static void afterUpdate(Map<Id,employee__c> oldMap,List<employee__c> newReocrds) {
		List<emCertificationRelation__c> newBridge = new List<emCertificationRelation__c>();
		List<emCertificationRelation__c> deleteRecords = new List<emCertificationRelation__c>();

		List<Id> ids = new List<Id>();
		for(employee__c newList :newReocrds) {

			if(oldMap.get(newList.Id).OwnedCertification__c == null && newList.OwnedCertification__c != null){
				List<String> afterLists = newList.OwnedCertification__c.split(';');
				for(Integer i = 0;i<afterLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(afterLists[i]);	
					emCertificationRelation__c bridgeInfos = new emCertificationRelation__c(employeeRelation__c = newList.Id,CertificationRelation__c = cfInfos.Id);

					newBridge.add(bridgeInfos);	
				}					
			}else if(oldMap.get(newList.Id).OwnedCertification__c != null && newList.OwnedCertification__c != null){
					List<String> afterLists = newList.OwnedCertification__c.split(';');
					List<String> oldLists = oldMap.get(newList.Id).OwnedCertification__c.split(';');
					

				for(Integer i = 0;i<oldLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(oldLists[i]);	
					emCertificationRelation__c bridgeInfos = recordController.getBridgeInfos(oldMap.get(newList.id).Id,cfInfos.Id);
				
					ids.add(bridgeInfos.CertificationRelation__c);

					if(!afterLists.contains(oldLists[i])){
						deleteRecords.add(bridgeInfos);
					}
				}

				for(Integer i = 0;i<afterLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(afterLists[i]);		

					emCertificationRelation__c bridgeInfos = new emCertificationRelation__c(employeeRelation__c = newList.Id,CertificationRelation__c = cfInfos.Id);
						if(!ids.contains(bridgeInfos.CertificationRelation__c)){
						newBridge.add(bridgeInfos);
					}
				}
			}else if(oldMap.get(newList.Id).OwnedCertification__c != null && newList.OwnedCertification__c == null){
				List<String> oldLists = oldMap.get(newList.Id).OwnedCertification__c.split(';');

				for(Integer i = 0;i<oldLists.size();i++){
					certification__c cfInfos = recordController.getCertificationInfos(oldLists[i]);	
					emCertificationRelation__c bridgeInfos = recordController.getBridgeInfos(oldMap.get(newList.id).Id,cfInfos.Id);
					deleteRecords.add(bridgeInfos);
				}
			}
		}

		if(deleteRecords.size()>0){
			delete deleteRecords;
		}
		if(newBridge.size()>0){
			upsert newBridge;
		}

	}

	//資格の更新期限を更新する場合、関連している従業員の「更新必要な資格有無」項目も更新される
	public static void certificationUpdate(List<certification__c> updateRecords,Map<Id,certification__c> oldMap){
		// Set<Id> ids = new Set<Id>();
		List<certification__c> certifications = [SELECT id,Name,HasUpdate__c,UpdateDate__c,(SELECT Id, Name,employeeRelation__c,employeeRelation__r.Name,employeeRelation__r.HasUpdate__c,employeeRelation__r.UpdateCetifications__c,employeeRelation__r.UpdateDate__c FROM CertificationRelations__r) FROM certification__c WHERE id IN :updateRecords];
		List<employee__c> em = new List<employee__c>();


		for(certification__c u : certifications){
			if(u.UpdateDate__c !=null && u.UpdateDate__c != oldMap.get(u.id).UpdateDate__c){				
				u.HasUpdate__c = '必要';
				for(emCertificationRelation__c ecf: u.CertificationRelations__r){
					em.add(ecf.employeeRelation__r);
					ecf.employeeRelation__r.HasUpdate__c = '有り';
				}	
			}
		}

    update certifications;
		update em;
	}

  //受講履歴作されるたびに、関連している授業員「セミナ合計金額」が累積される
	public static void semiHisAfterInsert(List<seminarAttendingHistory__c> newRecords){
		List<seminarAttendingHistory__c> records = [SELECT Id, employeeId__c,employeeId__r.seminarAmount__c,employeeId__r.employeeName__c,Price__c FROM	seminarAttendingHistory__c WHERE id IN :newRecords];
		List<employee__c> forUpdates = new List<employee__c>();

		for(seminarAttendingHistory__c e :records){
			employee__c em = e.employeeId__r;

			//関連従業員のセミナ合計金額集計			
			if(em.seminarAmount__c == null){
				em.seminarAmount__c = 0;
			}
			em.seminarAmount__c += e.Price__c;
			forUpdates.add(em);
		}
		update forUpdates;
	}

	//受講履歴作成たれるたびに、新規行動が登録されます
	public static void newEventCreated(List<seminarAttendingHistory__c> newRecords){
		List<seminarAttendingHistory__c> records = [SELECT Id,Name,Form__c,Venue__c,seminarName__c, Date__c,TimeFrom__c,TimeEnd__c,seminarName__r.Name,employeeId__c,EmployeeName__c,employeeId__r.Name,employeeId__r.employeeName__c,ConcreteDateTime__c,Status__c FROM seminarAttendingHistory__c WHERE id IN :newRecords];
		List<Event> newEvent = new List<Event>();

		for(seminarAttendingHistory__c r :records){
			String st = String.valueof(r.Date__c) + ' ' + String.valueof(r.TimeFrom__c);
      String et = String.valueof(r.Date__c) + ' ' + String.valueof(r.TimeEnd__c);			
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
					Subject = '受講予定:' + r.seminarName__r.Name,
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