public class AccountNameServiceRequest implements IOpportunityRequestInterface{
   
@AuraEnabled(cacheable=true)
   public static OpportunityPagerWrapper getOppsListBasedOnFilter(Map<String,String> searchFilterByKeyMap, String searchFilterKey,Integer pageSize, Integer pageNumber) {
       System.debug('searchKey'+searchFilterByKeyMap);
        List<OpportunityListWrapper> opplistWrapper= new List<OpportunityListWrapper>();
        OpportunityListWrapper oplw;
        OpportunityPagerWrapper opw=new OpportunityPagerWrapper();
        List<Opportunity> oppList=new  List<Opportunity>();
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
                   query='select id,name,description,closeDate,accountid,account.name,stageName from Opportunity where  account.name Like \'%' + searchKeyquery + '%\'LIMIT :pageSize OFFSET :offset'; 
                   countQuery = 'select count() from Opportunity  where  account.name Like \'%' + searchKeyquery + '%\'' ;
                }
               Integer totalRecords=Database.countQuery(countQuery);
               opw.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
               opw.totalRecords = totalRecords;
    
      		   oppList=Database.query(query);
                System.debug('oppList'+oppList);
                  for(Opportunity oppVar : oppList) { 
                       oplw = new OpportunityListWrapper();
                       System.debug('oppVar>>>'+oppVar.Name);                         
                   		oplw.oppName= oppVar.Name; 
                           oplw.oppDesc=oppVar.description;
                           oplw.oppCloseDate=oppVar.closeDate;
                           oplw.oppAccountName=oppVar.account.Name;
     
                               if (!string.isEmpty(oppVar.accountid)){ 
                                 string accId=oppVar.accountId;
                                           List<Contact> cc=[Select accountid, name,email, createddate,phone  from contact where accountid =:accId order by createdDate desc limit 1];
                                           if(cc.size()>0){
                                            oplw.mostRecentContact=cc[0].name;
                                            oplw.mostRecentContactEmail=cc[0].email;
                                            oplw.mostRecentPhoneNumber=cc[0].phone;
                                           }
                                    }
                                            opplistWrapper.add(oplw);
                                            opw.serviceCode='OK';
                                            opw.optDetails=opplistWrapper;
                                          }
                                    return opw;   
        }catch (Exception e) {
       		 ExceptionHandler.logHandledExceptions(e,'AccountNameServiceRequest','getOppsListBasedOnFilter','AccountNameServiceRequestManagement');
            return null;
   		}
                   }
}