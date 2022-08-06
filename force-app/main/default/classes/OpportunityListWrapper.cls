public without sharing class OpportunityListWrapper {
     @AuraEnabled   public string oppId {get;set;}
     @AuraEnabled   public string oppName {get;set;}
     @AuraEnabled   public String oppDesc {get;set;}
     @AuraEnabled   public String oppAccountName {get;set;}
     @AuraEnabled   public Date   oppCloseDate {get;set;}
     @AuraEnabled   public String mostRecentContact {get;set;}
     @AuraEnabled   public String mostRecentContactEmail {get; set;}
     @AuraEnabled   public String mostRecentPhoneNumber {get;set;}
        
        
    }