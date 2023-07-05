public with sharing class OpportunityManagement {

  //列のラベルを取得する
  @AuraEnabled
  public static string getLabel(String fieldName) {
    Schema.DescribeFieldResult columnLabel;

    if (fieldName == 'Product2__c') {
      columnLabel = Schema.SObjectType.OpportunityItem__c.fields.Product2__c;
    } else if (fieldName == 'UnitCounts__c') {
      columnLabel = Schema.SObjectType.OpportunityItem__c.fields.UnitCounts__c;
    } else if (fieldName == 'StageName__c') {
      columnLabel = Schema.SObjectType.OpportunityItem__c.fields.StageName__c;
    }
    return columnLabel.getLabel();
  }

  @AuraEnabled
  public static List<Product2> getProductPickList() {
    return [SELECT Id, Name FROM Product2];
  }

  //StageName__cの選択肢を取得する
  @AuraEnabled
  public static List<convertPicklist> getStageNamePickList() {
    Schema.DescribeFieldResult objFieldDescribe = OpportunityItem__c.StageName__c.getDescribe();

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

  @AuraEnabled
  public static void updateItem(List<OpportunityItem__c> items,List<OpportunityItem__c> deleteOpportunityItems) {
		if(!deleteOpportunityItems.isEmpty()){
			delete deleteOpportunityItems;
		}
    upsert items;
  }

  public with sharing class convertPicklist {
    @auraenabled
    public string label;

    @auraenabled
    public string value;

    convertPicklist(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  @AuraEnabled(cacheable=true)
  public static list<OpportunityItem__c> getData(id opportunityId) {
    return [
      SELECT id, Opportunity__c, Product2__c, UnitCounts__c, StageName__c
      FROM OpportunityItem__c
      WHERE Opportunity__c = :opportunityId
    ];
  }
}

