public with sharing class  OpportunityStageServiceRequest implements IOpportunityRequestInterface{ 
@AuraEnabled
   public static OpportunityPagerWrapper getOppsListBasedOnFilter(Map<String,String> searchFilterByKeyMap, String searchFilterKey,Integer pageSize, Integer pageNumber) {
		System.debug('searchKey'+searchFilterByKeyMap);
        List<OpportunityListWrapper> opplistWrapper= new List<OpportunityListWrapper>();
       	String searchKeyquery='';
        OpportunityListWrapper oplw;
        OpportunityPagerWrapper opw=new OpportunityPagerWrapper();
        List<Opportunity> oppList=new  List<Opportunity>();
       	List<Opportunity> oppListAccess=new  List<Opportunity>();
        List<Opportunity> oppListSysmode=new List<Opportunity>();
        String query='';
        String countQuery='';
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        opw.pageSize=pageSize;
		opw.recordStart = offset + 1;
        opw.pageNumber = pageNumber;
       
        try{
        	if(!searchFilterByKeyMap.isEmpty())
        	{
          	searchKeyquery=searchFilterByKeyMap.get(searchFilterKey);
			query='select id,name,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,Description,closeDate,accountid,account.name,stageName from Opportunity where  stageName Like \'%' + searchKeyquery + '%\' LIMIT :pageSize OFFSET :offset'; 
        	countQuery = 'select count() from Opportunity  where stageName Like \'%' + searchKeyquery + '%\'' ;
        	}
      
			Integer totalRecords=Database.countQuery(countQuery);
			opw.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
			opw.totalRecords = totalRecords;
           
			oppList=Database.query(query);
			System.debug('oppList size for this user'+oppList.size());
        
            if(oppList.size()>0)
            {
      		for(Opportunity oppVar : oppList) 
      		{ 
                oplw = new OpportunityListWrapper();
                System.debug('record has access?'+oppVar.UserRecordAccess.HasReadAccess);
                System.debug('record has access?'+oppVar.Name);
                oplw.oppName= oppVar.UserRecordAccess.HasEditAccess? oppVar.Name:getMaskedRecord(oppVar.Name);
                oplw.oppDesc=oppVar.UserRecordAccess.HasEditAccess?oppVar.Description:getMaskedRecord(oppVar.Description);
                oplw.oppCloseDate=oppVar.closeDate;
                oplw.oppAccountName=oppVar.UserRecordAccess.HasEditAccess?oppVar.account.Name:getMaskedRecord(oppVar.account.Name);
     
       		if (!string.isEmpty(oppVar.accountid))
            { 
         		string accId=oppVar.accountId;
            	List<Contact> cc=[Select accountid, UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,name,email, createddate,phone  from contact where accountid =:accId order by createdDate desc limit 1];
                if(cc.size()>0)
                {
            	oplw.mostRecentContact=cc[0].UserRecordAccess.HasEditAccess?cc[0].name:getMaskedRecord(cc[0].name);
            	oplw.mostRecentContactEmail=cc[0].UserRecordAccess.HasEditAccess?cc[0].email:getMaskedRecord(cc[0].email);
            	oplw.mostRecentPhoneNumber=cc[0].UserRecordAccess.HasEditAccess?cc[0].phone:getMaskedRecord(cc[0].phone);
                }
            }
            	opplistWrapper.add(oplw);
            	opw.serviceCode='OK';
            	opw.optDetails=opplistWrapper;
          
                    System.debug('opw.optDetail 34>>>'+opw.optDetails);
            }
            }
        	    return opw;   
   			}
   			catch (Exception e) {
       		 ExceptionHandler.logHandledExceptions(e,'OpportunityStageServiceRequest','getOppsListBasedOnFilter','OpportuntityStageServiceRequestManagement');
            return null;
   		}
   }
    public static String  getMaskedRecord(String acceptedString)
    {
   
   String valueNotToMask = acceptedString.left(3);
   String mask = acceptedString.substring(3, acceptedString.length());
   String masked = 'x'.repeat(mask.length());
   String finalString=valueNotToMask+masked;
   return finalString;
    }
}