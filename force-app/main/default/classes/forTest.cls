Account myAccount = new Account(Name = ‘MyAccount’);
Insert myAccount;
For (Integer x = 0; x < 250; x++) {
	 Account newAccount = new Account (Name='MyAccount' + x); 
	 try { 
		Insert newAccount; 
	} catch (Exception ex) { 
		System.debug (ex) ; 
	} } 
	insert new Account (Name='myAccount'); 


trigger leadTrigger on Lead （before update）{
	final ID BUSINESS_RECORDTYPEID = ‘012500000009Qad‘;
		for(Lead thisLead : Trigger.new){
			if(thisLead.Company !=null &&thisLead.RecordTypeId !=BUSINESS_RECORDTYPE){
				thisLead.RecordTypeId = BUSINESS_RECORDTYPEID;
			}
		}
}

for(ListtheseLeads : [SELECT LastName, Company, Email FROM Lead LIMIT 2000]){
	for(Lead this Lead : theseLeads)  {
		if (thisLead.Email == null)
		thisLead.Email = assignGenericEmail (thisLead.LastName, thisLead.Company) ;
	}

	Database.Update(theseLeads,false);
}


public without sharing class OpportunityService{
	public static List getopportunityProducts (Set opportunityIds) {
		List oppLineItems = new List();
		For (Id thisOppId : opportunityIds){
			oppLineItems.addAll ( [Select Id FROM OpportunityLineItem WHERE OpportunityId = :thisOppId] );
		}
	
	Return oppLineItems;
	}
}

for ( Account thisAccount : [ Select Id, Industry FROM Account LIMIT 250] ) {
	if (thisAccount.Industry == “Technology‘) {
		thisAkccount.Is_Tech_¢ = true;
	}
	
	update thisAccount;
}
	

List getContracts=new List();
for(Opportunity opp:(List)Trigger.New){
	Contract con=[SELECT Id FROM Contract where Id=:opp.ContractId];
	con.Description =’This is the contract for Opportunity’+ opp.Name;
	getContracts.add(con);
}
update getContracts;

Account myAccount = new Account(Name = ‘MyAccount’);
Insert myAccount;
For (Integer x = 0; x < 150; x++) {
	Account newAccount = new Account (Name='MyAccount' + x);
	try {
		Insert newAccount;
	} catch (Exception ex) {
		System.debug (ex) ;
	}
}
insert new Account (Name='myAccount');
How many accounts are in the org after this code is run?


public class myController {
	public String myString;
	public String getMyString() {
		return 'getmyString';
	}
	public String getStringMethod1() {
		return myString;
	}
	public String getStringMethod2 () {
		if (myString == null)
		myString = 'Method2';
		return myString;
	}
}
{!myString}, {!StringMethod1}, {!StringMethod2}, {!myString}

GetMyString 、 、 Method2 、 getMystring 

try {
	List nameList;
	Account a;
	String s = a.Name;
	nameList.add(s);
} catch (ListException le ) {
	System.debug(' List Exception ');
} catch (NullPointerException npe) {
	System.debug(' NullPointer Exception ');
} catch (Exception e) {
	System.debug(' Generic Exception ');
} 


List fList = new List ();
For(integer i= 1; I <= 200; i++) { 
	fList.add(new Account ( Name = 'Universal Account ' + i)); 
} 
Insert fList; 200
List sList = new List();
For (integer I = 201; I <= 20000; i ++) { 
	sList.add(new Account (Name = 'Universal Account ' + i));
} 
Insert sList；1800
Line: 13, Column: 1
System.LimitException: Too many DML rows: 10001

