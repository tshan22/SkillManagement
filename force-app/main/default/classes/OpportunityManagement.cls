public with sharing class OpportunityManagement {
  /**
   * @description 機種選択リスト用の価格表エントリ取得
   * @param opportunityId 現在開いている引合のレコードId
   * @return 機種選択リスト用の価格表エントリ
   */

  @AuraEnabled(cacheable=true)
  public static list<Opportunity> selectPickList(id opportunityId) {
    return [
      SELECT Id, Machine__c, toLabel(Machine__c) label_pick
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];
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

