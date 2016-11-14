public class ctrl_QuoteReservationAgreement {
    //update the Reservation agreemnet section.
    private Map<String , String> paramMap;
    Public Quote q{get;set;}
    public Id QuoteId{get;set;}
    List<Quote> quotes = new List<Quote>();
    public string res_number{get;set;}
    public date anticipateddate{get;set;}
    public decimal amount{get;set;}
    public boolean sent{get;set;}
    public boolean signed{get;set;}
    public boolean received{get;set;}
    
    public ctrl_QuoteReservationAgreement(ApexPages.StandardController controller){
        paramMap = new Map<String , String>();
        paramMap = ApexPages.currentPage().getParameters() ;
        QuoteId = controller.getId();
        if(QuoteId != null) {
            q = [select Id, Reservation_Agreement_Deposit_Recieved__c, Reservation_Agreement_Number__c, 
                 Reservation_Agreement_Sent__c, Reservation_Agreement_Signed__c, Reservation_Deposit_Amount__c, 
                 Anticipated_Handover_Date__c, Cheque_Bank__c, Cheque_Date__c, Cheque_Number__c From Quote where Id =:QuoteId];
        }
    }
    public PageReference saveReservation(){
        try{
            system.debug(q.Reservation_Agreement_Signed__c);
            system.debug(q.Reservation_Agreement_Deposit_Recieved__c);
            system.debug(q.Reservation_Agreement_Sent__c);
            update q;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getMessage())); 
            return null;
        }
        return null;
    }  
  
}