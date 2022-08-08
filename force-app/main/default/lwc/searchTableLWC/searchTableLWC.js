import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAllOpps from '@salesforce/apex/SearchTableController.getOpps';
import Opportunity_Name from '@salesforce/label/c.Opportunity_Name';
import Opportunity_Description from '@salesforce/label/c.Opportunity_Description';
import Opportunity_Close_Date  from '@salesforce/label/c.Opportunity_Close_Date';
import Associated_Account_Name   from '@salesforce/label/c.Associated_Account_Name';
import Contact_Name  from '@salesforce/label/c.Contact_Name';
import Contact_Email  from '@salesforce/label/c.Contact_Email';
import Contact_Phone  from '@salesforce/label/c.Contact_Number';


export default class SearchTableController extends LightningElement {
     isLoading = false;
     loader = false;
     error = null;
     @api pageSize;
     pageNumber = 1;
     totalRecords = 0;
     totalPages = 0;
     recordEnd = 0;
     recordStart = 0;
     isPrev = true;
     isNext = true;
     searchKey = '';
     @track opportunityList = [];
     @track mapFilterBySearch = {};
     
     isDisplayNoRecords=true;
     selectedValue;
     

      label={
       Opportunity_Name,
       Opportunity_Description,
       Opportunity_Close_Date,
       Associated_Account_Name,
       Contact_Name,
       Contact_Email,
       Contact_Phone

    }
    

    get options() {
        return [
            { label: 'None', value: 'None' },
            { label: 'All', value: 'All' },
            { label: 'Opportunity Stage', value: 'Opportunity Stage' },
            { label: 'Account Name', value: 'Account Name' },
            { label: 'Contact Name', value: 'Contact Name' },
           
        ];
    }
   
   handleFilterChange( event ) {

        this.selectedValue = event.detail.value;
        console.log(' this.selectedValue', this.selectedValue);

    }
    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.handleFilterdSearch();
    }

    handlePrev() {
        this.pageNumber = this.pageNumber - 1;
        this.handleFilterdSearch();
    }

     handleKeyChange(event) {
       this.searchKeyCmp = event.target.value;
     }



     handleFilterdSearch(){
         
        let filterCmp = this.template.querySelector(".searchFilter");
        let searchBarCmp = this.template.querySelector(".searchBar");
        
        let filterValue = filterCmp.value;
        let searchBarCmpValue = searchBarCmp.value;
        console.log('searchBarCmpValue',searchBarCmpValue.length);
        
        if (filterValue=='None' || filterValue=='' || filterValue==undefined) {
            filterCmp.setCustomValidity("search filter is required");
        } else {
            filterCmp.setCustomValidity("");
        }
            filterCmp.reportValidity();

        if (searchBarCmpValue=='' || searchBarCmpValue.length<=1) {
            searchBarCmp.setCustomValidity("search key is required and must be more than 1 charecters");
        } else {
            searchBarCmp.setCustomValidity("");
        }
            searchBarCmp.reportValidity();

       
       if((filterValue!= 'None' || filterValue!='' || filterValue!=undefined) && (searchBarCmpValue!='' && searchBarCmpValue.length>=2))
       {
        this.mapFilterBySearch[this.selectedValue] =  this.searchKeyCmp;
       
            getAllOpps({ searchFilterByKeyMap:  this.mapFilterBySearch,searchFilterKey:this.selectedValue,pageSize: this.pageSize, pageNumber: this.pageNumber})
            .then((result) => {
                
                if(result.optDetails.length>0)
                {
                this.wiredResult = result;
                if(result.data) {
                this.myData = result.data;
                 }
                this.isDisplayNoRecords=false;
                this.pageNumber = result.pageNumber;
                this.totalRecords = result.totalRecords;
                this.recordStart = result.recordStart;
                this.recordEnd = result.recordEnd;
                this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                this.opportunityList=[]; 
                this.oppDetailsInit(result);
                }
                else{
                    this.isDisplayNoRecords=true;

                }
               
            })
            .catch((error) => {
               this.error = error;
               console.log('error',error);
               this.opportunityList=[]; 
            });
       }
    }


    oppDetailsInit(result){
          var i;
          for(i=0;i<result.optDetails.length;i++){      
                let newOppWrapper = {};
                newOppWrapper.Id = i;
                newOppWrapper.recordId=result.optDetails[i].oppId;
                newOppWrapper.oppName = result.optDetails[i].oppName;
                newOppWrapper.oppAccountName = result.optDetails[i].oppAccountName;
                newOppWrapper.oppDesc = result.optDetails[i].oppDesc;
                newOppWrapper.oppCloseDate = result.optDetails[i].oppCloseDate;
                newOppWrapper.mostRecentContact = result.optDetails[i].mostRecentContact;
                newOppWrapper.mostRecentContactEmail = result.optDetails[i].mostRecentContactEmail; 
				newOppWrapper.mostRecentPhoneNumber = result.optDetails[i].mostRecentPhoneNumber;
                this.opportunityList.push(newOppWrapper);  
                                
            }
            
       
    }
     
    
   
    
}
