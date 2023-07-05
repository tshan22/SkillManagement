/**
 * @description 引合レコードページの「引合商品管理」アクションで表示する画面の処理
 */
public with sharing class OpportunityItemManagementController {
	/**
	 * @description 機種選択リスト用の価格表エントリ取得
	 * @param opportunityId 現在開いている引合のレコードId
	 * @return 機種選択リスト用の価格表エントリ
	 */
	@AuraEnabled
	public static PricebookEntry[] selectProduct2ForPickList(Id opportunityId) {
			Opportunity[] targetOpportunities = [
					SELECT 
					Id, 
					Destination__c
					FROM Opportunity
					WHERE Id = :opportunityId
			];

			Integer limitCount = Limits.getLimitQueryRows();

			return [
					SELECT 
					Product2Id, 
					Product2.Name
					FROM PricebookEntry
					WHERE
							Pricebook2.Destination__c = :targetOpportunities[0].Destination__c
							AND Product2.HasMainUnit__c = TRUE
							AND Product2.IsSpecialSpecification__c = FALSE
					ORDER BY Product2.Name
					LIMIT :limitCount
			];
	}

	
	//   @description 引合に紐づく引合商品の取得
	//   @param opportunityId 現在開いている引合のレコードId
	//  @return 引合に紐づく引合商品
	 
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

	
	  // @description 画面で入力された引合商品の作成・更新・削除
	  // @param saveParamater SaveOpportynityItemParamaterのインスタンス
	  // @return 作成・更新した引合商品のレコードId
	 
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
	
}