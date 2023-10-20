@isTest
public class recordContorllerTest {
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

	 //テストデータ：従業員の追加
	//  User user = [SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp' LIMIT 1];
		employee__c em1 = new employee__c();
		em1.employeeName__c = testUser.id;
		em1.Position__c = '一般';
		em1.OwnedCertification__c = 'Developer;LWC';
		insert em1;

		//テストデータ：資格追加
		certification__c cf = new certification__c();
		cf.Name = 'Python基礎エンジニア';
		insert cf;

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
		
		//テストデータ：受講履歴追加
		seminarAttendingHistory__c sh = new seminarAttendingHistory__c();
		sh.seminarName__c = s.id;
		sh.employeeId__c = em1.id;
		sh.Price__c = s.Price__c;
		sh.Form__c = sch.Form__c;
		sh.ConcreteDateTime__c = sch.DateTime__c;
		insert sh;
	}



	@isTest
	static void getinformationTest(){
		List<employee__c>em;

    System.Test.startTest();
    em = recordController.getinformation();	
    System.Test.stopTest();
		System.assertNotEquals(null, em);
		System.assertNotEquals(0, em.size());
	}

	@isTest
	static void searchEmployeeTest(){
		User u =[SELECT id,name FROM User WHERE  Username = 'shanting0210@yahoo.co.jp'];
		employee__c em= [SELECT id,name,employeeName__r.Name FROM employee__c WHERE employeeName__c =: u.id LIMIT 1];
		String inputName = em.employeeName__r.Name;
		List<employee__c> serachEm; 
    System.Test.startTest();
    serachEm = recordController.searchEmployee(inputName);
    System.Test.stopTest();
		System.assertNotEquals(null, serachEm);
		System.assertNotEquals(0, serachEm.size());
	}

	@isTest
	static void searchSeminarTest(){
		seminar__c semi = [SELECT id,Name FROM seminar__c WHERE Name ='Python 入門' LIMIT 1];
		String inputName = semi.Name;
		List<seminar__c> searchSemi; 
    System.Test.startTest();
    searchSemi = recordController.searchSeminar(inputName);
    System.Test.stopTest();
		System.assertNotEquals(null, searchSemi);
		System.assertNotEquals(0, searchSemi.size());
	}

	@isTest
	static void getCertificationInfosTest(){
		certification__c cf = [SELECT id,Name FROM certification__c WHERE Name ='Python基礎エンジニア' LIMIT 1];
		String inputName = cf.Name;
	  certification__c getCfInfo; 
    System.Test.startTest();
    getCfInfo = recordController.getCertificationInfos(inputName);
    System.Test.stopTest();
		System.assertNotEquals(null, getCfInfo);
	}

	@isTest
	static void getSeminarScheduleTest(){
		List<seminar__c> semi = [SELECT id,Name FROM seminar__c WHERE Name IN ('Python 入門')];
	  List<seminarScheduleManagement__c> getSemiSch; 
    System.Test.startTest();
    getSemiSch = recordController.getSeminarSchedule(semi);
    System.Test.stopTest();
		System.assertNotEquals(null, getSemiSch);
		System.assertNotEquals(0, getSemiSch.size());
	}



}