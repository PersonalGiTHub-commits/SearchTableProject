public class ContactNameServiceRequest  implements IOpportunityRequestInterface{
   
@AuraEnabled(cacheable=true)
   public static OpportunityPagerWrapper getOppsListBasedOnFilter(Map<String,String> searchFilterByKeyMap, String searchFilterKey,Integer pageSize, Integer pageNumber) {
       System.debug('searchKey'+searchFilterByKeyMap);
        List<OpportunityListWrapper> opplistWrapper = new List<OpportunityListWrapper>();
        OpportunityListWrapper oplw=new OpportunityListWrapper(); 
        OpportunityPagerWrapper opw=new OpportunityPagerWrapper();
       	List<Contact> oppList=new List<Contact>();
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
        String searchKeyquery=searchFilterByKeyMap.get(searchFilterKey);
        query='SELECT ID,NAME,AccountId from Contact WHERE NAME Like  \'%' + searchKeyquery + '%\'  LIMIT :pageSize OFFSET :offset'; 
        countQuery = 'select count() from Contact  where  Name Like \'%' + searchKeyquery + '%\'' ;
        }
       Integer totalRecords=Database.countQuery(countQuery);
	   opw.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
	   opw.totalRecords = totalRecords;
        oppList=Database.query(query);
      	System.debug('oppList'+oppList);
      	for(Contact del : oppList) {                      
      	oplw = new OpportunityListWrapper(); 
        List<Opportunity> listOppCon=[select NAME,DESCRIPTION,Account.Name,AccountId,CLOSEDATE,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess From Opportunity WHERE accountId=: del.accountid];
        if(listOppCon.size()>0)
        {
            for(Opportunity conOpt:listOppCon )
            {
            oplw.oppName= conOpt.Name; 
            oplw.oppDesc=conOpt.description;
            oplw.oppCloseDate=conOpt.closeDate;
            oplw.oppAccountName=conOpt.account.Name;
            }
        }
       if (!string.isEmpty(del.accountid)){ 
         
            List<Contact> cc=[Select accountid, name,email, createddate,phone  from contact where accountid =:del.accountid order by createdDate desc limit 1];
           if(cc.size()>0){
            oplw.mostRecentContact=cc[0].name;
            oplw.mostRecentContactEmail=cc[0].email;
            oplw.mostRecentPhoneNumber=cc[0].phone;
           }
            }
            opplistWrapper.add(oplw);
            opw.optDetails=opplistWrapper;
           	opw.serviceCode='OK';
            }
         System.debug('opw'+opw.optDetails[0].oppName);
        
         return opw;   
       }
       catch (Exception e) {
       		 ExceptionHandler.logHandledExceptions(e,'ContactNameServiceRequest','getOppsListBasedOnFilter','ContactNameServiceRequestManagement');
            return null;
   		}
   }
}