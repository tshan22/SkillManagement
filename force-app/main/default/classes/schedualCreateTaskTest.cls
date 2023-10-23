@isTest
public without sharing class schedualCreateTaskTest {
  
	 @testSetup static void setup(){
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
		insert cfs;

	 //テストデータ：従業員の追加
		employee__c em1 = new employee__c();
		em1.employeeName__c = testUser.id;
		em1.Position__c = '一般';
		em1.OwnedCertification__c = 'Developer;LWC';
		insert em1;
	}

	@isTest
	static void taskTest(){		
		certification__c cf = [SELECT id,Name,HasUpdate__c,UpdateDate__c FROM certification__c WHERE Name = 'Developer' LIMIT 1];
		Date d = Date.today();
		cf.UpdateDate__c = d.addMonths(2);	
		update cf;

		System.Test.startTest();
		String times = '0 0 0 * * ?';  
		String jobId = System.schedule('forTest',times,new schedualCreateTask());

		CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];
		System.Test.stopTest();
		System.assertEquals(times, ct.CronExpression);
		
	}
}