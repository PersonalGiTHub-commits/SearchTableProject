public interface IOpportunityRequestInterface{

OpportunityPagerWrapper getOppsListBasedOnFilter(Map<String,String> searchFilterByKeyMap, String searchFilterKey,Integer pageSize, Integer pageNumber);

}