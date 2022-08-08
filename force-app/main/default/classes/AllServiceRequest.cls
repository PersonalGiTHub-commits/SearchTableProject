public with sharing class AllServiceRequest implements IOpportunityRequestInterface{ 
@AuraEnabled
   public static OpportunityPagerWrapper getOppsListBasedOnFilter(Map<String,String> searchFilterByKeyMap, String searchFilterKey,Integer pageSize, Integer pageNumber) {
 	 	List<OpportunityListWrapper> opplistWrapper= new List<OpportunityListWrapper>();
       	OpportunityListWrapper oplw;
        OpportunityPagerWrapper opw=new OpportunityPagerWrapper();
        List<Opportunity> oppListOpp=new  List<Opportunity>();
        List<Opportunity> oppListAcc=new  List<Opportunity>();
        List<Opportunity> oppListCon=new  List<Opportunity>();
        String query='';
        String countQuery='';
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        opw.pageSize=pageSize;
		opw.recordStart = offset + 1;
        opw.pageNumber = pageNumber;
        String searchKeyquery='';
        searchKeyquery=searchFilterByKeyMap.get(searchFilterKey);
        try
        {
        if(searchFilterKey == 'All' && searchKeyquery!= null){
           String myQuery1 = 'FIND \'' + searchKeyquery + '\'  IN ALL FIELDS RETURNING Account(ID,NAME WHERE NAME Like  \'%' + searchKeyquery + '%\'  LIMIT :pageSize OFFSET :offset),Contact(NAME,Email,Phone,AccountId WHERE NAME Like  \'%' + searchKeyquery + '%\' LIMIT :pageSize OFFSET :offset ),Opportunity(NAME,DESCRIPTION,CLOSEDATE,ACCOUNTID,ACCOUNT.NAME,STAGENAME WHERE NAME Like  \'%' + searchKeyquery + '%\'  LIMIT :pageSize OFFSET :offset)';
           
            List<List<sObject>> searchList = System.Search.query(myQuery1);
            List <Account> searchAccounts = searchList.get(0);
            System.debug('searchAccounts'+searchAccounts);
            List <Contact> searchContact = searchList.get(1);
            System.debug('searchContact'+searchContact);
            List <Opportunity> searchOpportunity = searchList.get(2);
            System.debug('searchOpportunity'+searchOpportunity);
            Integer totalRecords= searchList[0].size() +searchList[1].size()+searchList[2].size();
           	opw.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
			opw.totalRecords = totalRecords;
             if(searchAccounts.size()>0){
                  
            	 for(Account acc : searchAccounts) {
                 oplw = new OpportunityListWrapper();
 				 oppListAcc = [select NAME,DESCRIPTION,CLOSEDATE,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,Account.Name From Opportunity WHERE accountId=: acc.Id];
                    if(oppListAcc.size()>0){
                    System.debug('oppListAcc.size()>0'+oppListAcc);
                 	for(Opportunity opacc:oppListAcc)
                    	{ 
                                oplw.oppAccountName =opacc.Account.Name;
                                oplw.oppName= opacc.UserRecordAccess.HasEditAccess? opacc.Name:getMaskedRecord(opacc.Name);
                                oplw.oppDesc=opacc.UserRecordAccess.HasEditAccess?opacc.Description:getMaskedRecord(opacc.Description);
                                oplw.oppCloseDate=opacc.closeDate;
                                oplw.oppAccountName=opacc.UserRecordAccess.HasEditAccess?opacc.account.Name:getMaskedRecord(opacc.account.Name);
                             	System.debug('opacc.account.Name'+opacc.account.Name);
                    	}
                	
                            if (!string.isEmpty(acc.id))
                            { 
                                System.debug('!string.isEmpty(acc.id)'+acc.id);
                                    List<Contact> cc1=[Select accountid, UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,name,email, createddate,phone  from contact where accountId=: acc.Id order by createdDate desc limit 1];
                                    System.debug('cc1'+cc1);
                                    if(cc1.size()>0)
                                        {
                                            System.debug('cc1'+cc1);
                                            oplw.mostRecentContact=cc1[0].UserRecordAccess.HasEditAccess?cc1[0].name:getMaskedRecord(cc1[0].name);
                                            oplw.mostRecentContactEmail=cc1[0].UserRecordAccess.HasEditAccess?cc1[0].email:getMaskedRecord(cc1[0].email);
                                            oplw.mostRecentPhoneNumber=cc1[0].UserRecordAccess.HasEditAccess?cc1[0].phone:getMaskedRecord(cc1[0].phone);
                                        }
                                }           opplistWrapper.add(oplw);
                                            System.debug('opplistWrapper.add(oplw)'+opplistWrapper);
                                            opw.serviceCode='OK';
                                            opw.optDetails=opplistWrapper;
                                            System.debug('opw.optDetails'+opw.optDetails);
                                                }
                 						}
                            	}


                                    if(searchContact.size()>0){
                                         System.debug('searchContact.'+searchContact);
                                                for(Contact oppcont : searchContact) { 
                                                     oplw = new OpportunityListWrapper();
                                                      if (!string.isEmpty(oppcont.accountid))
                                                      { 
                                                        
                                                        List<Opportunity> listOppCon=[select NAME,DESCRIPTION,Accountid,Account.Name,CLOSEDATE,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess From Opportunity WHERE accountId=: oppcont.accountid];
                                                          if(listOppCon.size()>0)
                                                          {
                                                              for(Opportunity oppVar:listOppCon)
                                                              {
                                                              oplw.oppAccountName =oppVar.Account.Name;
                                							  oplw.oppName= oppVar.UserRecordAccess.HasEditAccess? oppVar.Name:getMaskedRecord(oppVar.Name);
                                							  oplw.oppDesc=oppVar.UserRecordAccess.HasEditAccess?oppVar.Description:getMaskedRecord(oppVar.Description);
                                							  oplw.oppCloseDate=oppVar.closeDate;
                                                              }
                                                          }
                                                        
                                                        oplw.mostRecentContact=oppcont.name;
                                                        oplw.mostRecentContactEmail=oppcont.email;
                                                        oplw.mostRecentPhoneNumber=oppcont.phone;
                                                               System.debug(' oplwcc2.'+ oplw);
                                                          
                                                        }
                                                    opplistWrapper.add(oplw);
                                                    opw.serviceCode='OK';
                                                    opw.optDetails=opplistWrapper;
                                                }
                                    }
            
                              if(searchOpportunity.size()>0){
                                  System.debug('searchOpportunity.'+searchOpportunity);
                                         for(Opportunity opp : searchOpportunity) {
                                             oplw = new OpportunityListWrapper();
                                              oplw.oppName = opp.Name;
                                              oplw.oppDesc = opp.Description;
                                              oplw.oppCloseDate = opp.CloseDate;
                                               oplw.oppAccountName =opp.Account.Name;
                                                   if(!string.isEmpty(opp.accountid))
                                                            {
                                                            string accId=opp.accountId;
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
                                                            System.debug('opw.optDetails 112'+opw.optDetails);
                                                        }
                                                }
                                            }
                                           return opw;
                                }  Catch(exception e){
                                        ExceptionHandler.logHandledExceptions(e,'AllServiceRequest','getOppsListBasedOnFilter','AllServiceRequestManagement');
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
