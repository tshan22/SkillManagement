public class picklistTest{
    public static void getPk(){
        Schema.DescribeFieldResult a = Opportunity.machine__c.getDescribe();
        
        List<Schema.PicklistEntry> b = a.getPickListValues();
        System.debug(b);
    }
}