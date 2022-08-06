public without sharing class OpportunityPagerWrapper {
      
       @AuraEnabled  public Integer pageSize {get;set;}
       @AuraEnabled  public Integer pageNumber {get;set;}
       @AuraEnabled  public Integer totalRecords {get;set;}
       @AuraEnabled  public Integer recordStart {get;set;}
       @AuraEnabled  public Integer recordEnd {get;set;}
       @AuraEnabled  public String  serviceCode {get;set;}
       @AuraEnabled  public List<OpportunityListWrapper> optDetails {get;set;}
     


   }