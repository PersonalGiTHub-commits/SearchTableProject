public with sharing class ExceptionHandler
{
    public static final String ERROR_IN ='Error in';   
    public static final String CAUSED_BY =' Caused by: '; 
    public static final String NEWLINE = '\n';
    public static final String ABBREVIATE_TEXT = '...';
    public static final String SYSTEM_QUERY_EXCEPTION ='System.QueryException';
    
    Public static final String TEST_METHOD_ERROR ='Test method Error';
   
      
   
   public static void logHandledExceptions(Exception ex, String className, String methodName, String module) {
        
      
        if (ex != null) {
            
            
            ExceptionLogger__c errorLog = new ExceptionLogger__c();
            
           System.debug(ex.getTypeName());
            
            String errDescription = ERROR_IN + 'getMessage - ' + ex.getMessage()+ CAUSED_BY+ ex.getTypeName() + NEWLINE+  'getStackTraceString - ' + ex.getStackTraceString() + NEWLINE + ' getCause - ' + ex.getCause() + NEWLINE + ' getTypeName - ' + ex.getTypeName();
            errorLog.Description__c = errDescription.length() > 32000 ? errDescription.substring(0, 32000) + ABBREVIATE_TEXT  : errDescription;
            errorLog.Error_Code__c = ex.getTypeName();
            if(ex.getTypeName().equalsIgnoreCase(SYSTEM_QUERY_EXCEPTION) ){
                System.QueryException dmlExObj = (System.QueryException)ex;
                if(!String.isBlank(dmlExObj.getDmlId(0))){
                    Id recId = dmlExObj.getDmlId(0);
                    errorLog.Object_Name__c = String.valueOf(recId.getSobjectType()); 
                    errorLog.Error_Record_SF_Id__c = recId;
                }
            } 

            errorLog.Apex_Class__c = className;
            errorLog.Exception_Dated__c=System.Now();     
            errorLog.User_Name__c = UserInfo.getUserName(); 
            errorlog.Method_Name__c = methodName ;
            errorlog.Module__c = module;
            
            
            if (errorLog != null) {
                try{
                 Database.insert(errorLog);
                  }
                catch(Exception e) { 
                    System.debug('Error while inserting a record in ExceptionLogger__c object in insertHandledExceptions method. Error: '+ e.getMessage());
                }                
            }                       
        }
    }
    


}