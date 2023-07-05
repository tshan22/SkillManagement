public class methodTest {
    //列のラベルを取得する
    public static void getLabel(){
       Schema.DescribeFieldResult machineLabel = Schema.SObjectType.OpportunityItem__c.fields.Product2__c;
       Schema.DescribeFieldResult unitCountsLabel = Schema.SObjectType.OpportunityItem__c.fields.UnitCounts__c;
	   Schema.DescribeFieldResult stageNameLabel = Schema.SObjectType.OpportunityItem__c.fields.StageName__c;
        
        System.debug(machineLabel.getLabel());
        System.debug(unitCountsLabel.getLabel());
        System.debug(stageNameLabel.getLabel());       
    }
    
    public static void test(){      
        Schema.DescribeSObjectResult d =  Account.sObjectType.getDescribe();
        System.debug('aaaaaaa' + d);
        Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
        System.debug(FsMap);
        
        Schema.DescribeFieldResult dfr = Schema.SObjectType.Account.fields.Name;
        System.debug(dfr);
        
        System.debug('----------------------------------');
   
        
        
        
        Schema.DescribeFieldResult machineLabel = Schema.SObjectType.OpportunityItem__c.fields.Product2__c;
       Schema.DescribeFieldResult unitCountsLabel = Schema.SObjectType.OpportunityItem__c.fields.UnitCounts__c;
	   Schema.DescribeFieldResult stageNameLabel = Schema.SObjectType.OpportunityItem__c.fields.StageName__c;
        
        System.debug(machineLabel.getLabel());
        System.debug(unitCountsLabel.getLabel());
        System.debug(stageNameLabel.getLabel());
    }
      
    //選択肢を取得する
	 public static void test2() {
		Schema.DescribeFieldResult objFieldDescribe = OpportunityItem__c.StageName__c.getDescribe();
		List<Schema.PicklistEntry> PK = objFieldDescribe.getPickListValues();
      
        System.debug('ssssssssssssss');
		System.debug(objFieldDescribe);  
         System.debug(PK);
         
         List<convertPicklist> stageNamePicklist = new List<convertPicklist>();
         
       for(Schema.PicklistEntry lists : PK){
           System.debug(lists.getlabel()+','+lists.getValue());
           
           convertPicklist pickList = new convertPicklist(lists.getlabel(),lists.getValue());
           
           System.debug(pickList);           
           stageNamePicklist.add(pickList);     
           
       }
         System.debug(stageNamePicklist);
    }
    
    public  class convertPicklist{
         String label;
         String value;
        
        convertPicklist(String l,String v){
            this.label = l;
            this.value = v;
        }
    }
 	 public static void getLabel(String fieldName){
		Schema.DescribeFieldResult columnLabel;
			try {
				if(fieldName == 'Product2__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.Product2__c;
				}else if(fieldName == 'UnitCounts__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.UnitCounts__c;					
				}else if(fieldName == 'StageName__c'){
					columnLabel = Schema.SObjectType.OpportunityItem__c.fields.StageName__c;		
				}
				System.debug(columnLabel.getLabel()); 
			} catch (Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
	 	}

    
    public static void getdata() {

		List<OpportunityItem__c> items = [SELECT id, StageName__c ,UnitCounts__c , Product2__c  FROM OpportunityItem__c WHERE Opportunity__c = '0062w00000F5bQtAAJ'];
        System.debug(items);
    }   

}