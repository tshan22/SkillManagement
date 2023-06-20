public with sharing class OpportunityManagement {
	/**
	 * @description 機種選択リスト用の価格表エントリ取得
	 * @param opportunityId 現在開いている引合のレコードId
	 * @return 機種選択リスト用の価格表エントリ
	 */


	 //列のラベルを取得する
	 @AuraEnabled
	 public static string getLabel(String fieldName){
		Schema.DescribeFieldResult columnLabel;
			try {
				if(fieldName == 'Product2__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.Product2__c;
				}else if(fieldName == 'UnitCounts__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.UnitCounts__c;					
				}else if(fieldName == 'StageName__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.StageName__c;		
				}
				return columnLabel.getLabel();
			} catch (Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
	 	}

//選択肢を取得する
	@AuraEnabled(cacheable=true)
	public static List<convertPicklist> getPickList(String picklistName) {
	  Schema.DescribeFieldResult objFieldDescribe ;

		//StageName__cの情報を取得する
		if(picklistName == 'StageName__c'){
			objFieldDescribe = OpportunityItem__c.StageName__c.getDescribe();
		}else if(picklistName == 'Product2__c'){
			objFieldDescribe = OpportunityItem__c.Product2__c.getDescribe();
		}

		// 選択リスト値の一覧を取得する。
		List<Schema.PicklistEntry> pickListValues = objFieldDescribe.getPickListValues();
		//System.debug(objFieldDescribe);getLabel、getValue、isActive、isDefualtValue


		List<convertPicklist> pickList = new List<convertPicklist>();
		for (Schema.PicklistEntry objPickList : pickListValues) {
			convertPicklist convertedLists = new convertPicklist(
				objPickList.getLabel(),
				objPickList.getValue()
			);
			//System.debug(pickList);PickListObj:[Label=V22 GRAPHITE, Value=V22 GRAPHITE]

			pickList.add(convertedLists);
		}

		return pickList;
	}


	public with sharing class convertPicklist {
		@auraenabled
		public string label ;

		@auraenabled
		public string value;

		convertPicklist(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}

	@AuraEnabled(cacheable=true)
	public static list<OpportunityItem__c> getdata(id opportunityId) {

		return [SELECT id,Product2__c,UnitCounts__c,StageName__c FROM OpportunityItem__c WHERE Opportunity__c = :opportunityId];
		
		// return [
		// 	SELECT Id, machine__c, quantity__c, StageName
		// 	FROM Opportunity
		// 	WHERE Id = :opportunityId
		// ];
	}
}

// @AuraEnabled
// public static OpportunityItem__c[] selectOpportunityItemByOpportunityId(Id opportunityId) {
// 		Integer limitCount = Limits.getLimitQueryRows();
// 		return [
// 				SELECT
// 				Id,
// 				Opportunity__c,
// 				Product2__c,
// 				UnitCounts__c,
// 				StageName__c
// 				FROM OpportunityItem__c
// 				WHERE Opportunity__c = :opportunityId
// 				ORDER BY CreatedDate
// 				LIMIT :limitCount
// 		];
// }

// @AuraEnabled
// public static Id[] saveOpportynityItem(SaveOpportynityItemParamater saveParamater) {
// 		Id[] savedItemIds = insertAndUpdateOpportunityItems(saveParamater.saveOpportunityItems);

// 		if (!saveParamater.deleteOpportunityItems.isEmpty()) {
// 				delete saveParamater.deleteOpportunityItems;
// 		}

// 		return savedItemIds;
// }

// private static Id[] insertAndUpdateOpportunityItems(OpportunityItem__c[] saveOpportunityItems) {
// 		Id[] savedItemIds = new List<Id>();
// 		if (!saveOpportunityItems.isEmpty()) {
// 				// 作成・更新どちらも行う可能性があるのでupsertを使用
// 				upsert saveOpportunityItems;
// 				for (OpportunityItem__c e : saveOpportunityItems) {
// 						savedItemIds.add(e.Id);
// 				}
// 		}

// 		return savedItemIds;
// }

// /**
//  	 @descriotion 画面で入力された作成・更新・削除する引合商品を保持するクラス
//
// public class SaveOpportynityItemParamater {
// 		/**
// 		  @description 作成・更新する引合商品の配列
//
// 		@AuraEnabled
// 		public OpportunityItem__c[] saveOpportunityItems { get; set; }

//
// 		  @description 削除する引合商品の配列
//
// 		@AuraEnabled
// 		public OpportunityItem__c[] deleteOpportunityItems { get; set; }

