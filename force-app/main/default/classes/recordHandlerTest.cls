@isTest
public class recordHandlerTest {
	 @testSetup static void setup(){
		List<employee__c> em = new List<employee__c>();

		//テストデータ：ユーザ追加
		Profile p = [SELECT id FROM Profile WHERE Name = '従業員(Platform)' LIMIT 1];
		User testUser = new User(
				LastName = 'TestUser ',
				Alias = 'newUser',
				Email = 'shanting0210@yahoo.co.jp',
				UserName = 'shanting0210@yahoo.co.jp',
				ProfileId = p.Id,
				EmailEncodingKey = 'ISO-2022-JP',
				LanguageLocaleKey = 'ja',
				LocaleSidKey = 'ja_JP',
				TimeZoneSidKey = 'Asia/Tokyo'
		);
		insert testUser;

		//テストデータ：資格追加
		List<certification__c> cfs = new List<certification__c>();
		cfs.add(new certification__c(Name = 'Developer'));
		cfs.add(new certification__c(Name = 'LWC'));
		cfs.add(new certification__c(Name = 'Apex'));
		cfs.add(new certification__c(Name = 'Java'));
		cfs.add(new certification__c(Name = 'Ruby'));
		insert cfs;

		//テストデータ：セミナ追加
		seminar__c s = new seminar__c();
		s.Name = 'Python 入門';
		s.Price__c = 3000;
		s.Description__c='0からPythonを勉強しよう';
		insert s;

		//テストデータ：セミナ日程登録
		seminarScheduleManagement__c sch = new seminarScheduleManagement__c();
		sch.seminar__c = s.id;
		sch.form__c = 'オンライン';		
		sch.Date__c = Date.valueOf('2013-11-11');
		sch.TimeFrom__c =Time.newInstance(10,00,0,0);
		sch.TimeEnd__c = Time.newInstance(12,00,0,0);
		insert sch;
	}



	@isTest
	static void afterInsertTest(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();
		employee__c em1 = new employee__c();
		em1.employeeName__c = u.id;
		em1.Position__c = '一般';
		em1.OwnedCertification__c = 'Developer;LWC';
		insert em1;
		System.Test.stopTest();		
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId =: em1.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c WHERE employeeRelation__c =:em1.id];
		System.assertNotEquals(null, resultList1);
		System.assertEquals(2, resultList1.size());
		System.assertNotEquals(null, resultList2);
		System.assertEquals(2, resultList2.size());
	}

	@isTest
	static void afterUpdateTest1(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();

		employee__c em2 = new employee__c();
		em2.employeeName__c = u.id;
		em2.Position__c = '一般';
		insert em2;

		List<employee__c> em= [SELECT id,name,employeeName__r.Name,OwnedCertification__c FROM employee__c WHERE employeeName__c =: u.id];
		for(employee__c e : em){
			e.OwnedCertification__c = 'Apex;Developer';
		}
		update em;
		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em2.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c WHERE employeeRelation__c =:em2.id];


	
		System.assertNotEquals(null, resultList1);
		System.assertEquals(2, resultList1.size());
		System.assertNotEquals(null, resultList2);
		System.assertEquals(2, resultList2.size());

	}

	@isTest
	static void afterUpdateTest2(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();

		employee__c em3 = new employee__c();
		em3.employeeName__c = u.id;
		em3.Position__c = '一般';
		em3.OwnedCertification__c = 'Developer;LWC';
		insert em3;

		List<employee__c> em= [SELECT id,name,employeeName__r.Name,OwnedCertification__c FROM employee__c WHERE employeeName__c =: u.id];
		for(employee__c e : em){
			e.OwnedCertification__c = 'Developer;Apex';
		}
		update em;
		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE  ParentId=:em3.id ];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c WHERE employeeRelation__c =:em3.id];
		employee__c emResult = [SELECT id,Name,OwnedCertification__c FROM employee__c WHERE id =: em3.id LIMIT 1];
	
		System.assertNotEquals(null, resultList1);
		System.assertEquals(2, resultList1.size());
		System.assertNotEquals(null, resultList2);
		System.assertEquals(2, resultList2.size());
		System.assertEquals('Developer;Apex', emResult.OwnedCertification__c);
	}


	@isTest
	static void afterUpdateTest3(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();

		employee__c em4 = new employee__c();
		em4.employeeName__c = u.id;
		em4.Position__c = '一般';
		em4.OwnedCertification__c = 'Developer;LWC';
		insert em4;

		List<employee__c> em= [SELECT id,name,employeeName__r.Name,OwnedCertification__c FROM employee__c WHERE employeeName__c =: u.id];
		for(employee__c e : em){
			e.OwnedCertification__c = null;
		}
		update em;
		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em4.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name  FROM emCertificationRelation__c WHERE employeeRelation__c =:em4.id];

		System.assertNotEquals(0, resultList1.size());
		System.assertEquals(2, resultList1.size());
		System.assertEquals(0, resultList2.size());
	}

	@isTest
	static void afterUpdateTest4(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();

		employee__c em5 = new employee__c();
		em5.employeeName__c = u.id;
		em5.Position__c = '一般';
		em5.OwnedCertification__c = 'Developer;LWC';
		insert em5;

		List<employee__c> em= [SELECT id,name,employeeName__r.Name,OwnedCertification__c FROM employee__c WHERE employeeName__c =: u.id];
		for(employee__c e : em){
			e.Position__c = 'マネージャ';
		}
		update em;
		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em5.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c WHERE employeeRelation__c =:em5.id];
		employee__c emResult = [SELECT id,Name,Position__c,OwnedCertification__c FROM employee__c WHERE id =:em5.id LIMIT 1];

	
		System.assertEquals(2, resultList1.size());
		System.assertEquals(2,resultList2.size());
		System.assertEquals('マネージャ', emResult.Position__c);
		System.assertEquals('Developer;LWC',emResult.OwnedCertification__c);
	}

	@isTest
	static void certificationUpdateTest(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		System.Test.startTest();
		employee__c em6 = new employee__c();
		em6.employeeName__c = u.id;
		em6.Position__c = '一般';
		em6.OwnedCertification__c = 'Developer;LWC';
		insert em6;
		List<certification__c> cfs = [SELECT id,Name FROM certification__c WHERE Name ='Developer' OR Name = 'LWC'];
		for(certification__c cf : cfs){
			if(cf.Name == 'LWC'){
				cf.UpdateDate__c = Date.valueOf('2014-4-11');
			}
		}
		update cfs;

		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em6.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c WHERE employeeRelation__c =:em6.id];
		employee__c emResult = [SELECT id,Name,Position__c,OwnedCertification__c,	HasUpdate__c FROM employee__c WHERE id =:em6.id LIMIT 1];

	
		System.assertEquals(2, resultList1.size());
		System.assertEquals(2,resultList2.size());
		System.assertNotEquals(null, emResult.HasUpdate__c);
		System.assertEquals('有り',emResult.HasUpdate__c);
	}

	
	@isTest
	static void semiHisAfterInsertTest(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		seminar__c semi = [SELECT id,Name,Price__c FROM seminar__c WHERE Name = 'Python 入門' LIMIT 1];
		seminarScheduleManagement__c schInfo = [SELECT id,Name,seminar__c,Date__c,TimeFrom__c,TimeEnd__c,seminar__r.Price__c,DateTime__c,Form__c,Venue__c FROM seminarScheduleManagement__c WHERE seminar__c =: semi.id LIMIT 1];

		System.Test.startTest();
		employee__c em7 = new employee__c();
		em7.employeeName__c = u.id;
		em7.Position__c = '一般';
		em7.OwnedCertification__c = 'Developer;LWC';
		insert em7;

		seminarAttendingHistory__c sh = new seminarAttendingHistory__c();
		sh.seminarName__c = semi.id;
		sh.employeeId__c = em7.id;
		sh.Price__c = semi.Price__c;
		sh.Form__c = schInfo.Form__c;
		sh.Venue__c = schInfo.Venue__c;
		sh.Date__c = schInfo.Date__c;
		sh.TimeFrom__c = schInfo.TimeFrom__c;
		sh.TimeEnd__c = schInfo.TimeFrom__c;
		sh.ConcreteDateTime__c = schInfo.DateTime__c;
		insert sh;

		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em7.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c  WHERE employeeRelation__c =:em7.id];
		employee__c emResult = [SELECT id,Name,Position__c,OwnedCertification__c,	HasUpdate__c,seminarAmount__c FROM employee__c WHERE id =:em7.id LIMIT 1];

	
		System.assertEquals(2, resultList1.size());
		System.assertEquals(2,resultList2.size());
		System.assertEquals(3000, emResult.seminarAmount__c);
	}

		@isTest
	static void newEventCreatedTest(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		seminar__c semi = [SELECT id,Name,Price__c FROM seminar__c WHERE Name = 'Python 入門' LIMIT 1];

		System.Test.startTest();
		employee__c em8 = new employee__c();
		em8.employeeName__c = u.id;
		em8.Position__c = '一般';
		em8.OwnedCertification__c = 'Developer;LWC';
		insert em8;

		seminarScheduleManagement__c sch = new seminarScheduleManagement__c();
		sch.seminar__c = semi.id;
		sch.form__c = 'オフライン';
		sch.Venue__c = 'サークレイス株式会社(東京都日本橋駅)';	
		sch.Date__c = Date.valueOf('2023-10-29');
		sch.TimeFrom__c =Time.newInstance(10,00,0,0);
		sch.TimeEnd__c = Time.newInstance(12,00,0,0);
		insert sch;

		seminarScheduleManagement__c schInfo =[SELECT id,Name,form__c,Venue__c,Date__c,TimeFrom__c,TimeEnd__c,DateTime__c FROM seminarScheduleManagement__c WHERE form__c='オフライン' LIMIT 1];

		seminarAttendingHistory__c sh = new seminarAttendingHistory__c();
		sh.seminarName__c = semi.id;
		sh.employeeId__c = em8.id;
		sh.Price__c = semi.Price__c;
		sh.Form__c = schInfo.Form__c;
		sh.Venue__c = schInfo.Venue__c;
		sh.Date__c = schInfo.Date__c;
		sh.TimeFrom__c = schInfo.TimeFrom__c;
		sh.TimeEnd__c = schInfo.TimeEnd__c;
		sh.ConcreteDateTime__c = schInfo.DateTime__c;
		insert sh;


		System.Test.stopTest();	
		List<employee__Share> resultList1 =[SELECT id FROM employee__Share WHERE ParentId=:em8.id];
		List<emCertificationRelation__c> resultList2 =[SELECT id,Name FROM emCertificationRelation__c  WHERE employeeRelation__c =:em8.id];
		employee__c emResult = [SELECT id,Name,Position__c,OwnedCertification__c,HasUpdate__c,seminarAmount__c FROM employee__c WHERE id =:em8.id LIMIT 1];
		List<Event> events = [SELECT id,Subject,WhatId FROM Event];
		Event event = [SELECT id,Subject,WhatId FROM Event WHERE WhatId=:em8.id LIMIT 1];
	

		System.assertEquals(2, resultList1.size());
		System.assertEquals(2,resultList2.size());
		System.assertNotEquals(0, events.size());
		System.assertEquals('受講予定:Python 入門',event.Subject);

	}

	





	


}