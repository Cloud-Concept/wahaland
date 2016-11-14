public class ctrl_TCPaymentGeneration {
    // Generate Quote offer Payments
    
    // Declare the Variables
    public Decimal selectedInstallmentsNo {get;set;}
    public integer selectedInstallmentFrq {get;set;}
    public Id TenancyContractId {get;set;}
    public Decimal amount {get;set;}
    public string TCName {get;set;}
    public Decimal nonRefund {get;set;}
    public Decimal nonRefundAmt {get;set;}
    public Decimal x{get;set;}
    public Decimal ReservationAmount{get;set;}
    public Tenancy_Contract__c newContract {get;set;}
    public Decimal rent_per_month{get;set;}
    public List<EscalationRate> escalationList{get;set;}
    private map<integer, decimal> esclationMap = new map<integer, decimal>();
    public decimal percentage {get;set;}
    public decimal parAmount {get;set;} 
    public integer multi {get;set;} 
    public Date dueDate {get;set;}
    public List<Tenancy_Contract_Payment__c> tableData {get;set;}
    public decimal totalPercentage {get;set;}
    public decimal totalAmount {get;set;}
    public decimal deficit {get;set;}
    public boolean RatesSet{get;set;}
    public boolean inputs{get;set;}
    private Decimal TCContractDuration;
    private Id CLI;
	public Decimal DepositAmount{get;set;}

    public ctrl_TCPaymentGeneration() {  
        RatesSet = false;
        inputs = true;
        if(ApexPages.currentPage().getParameters().get('TenancyContractId') != null) {
            TenancyContractId = ApexPages.currentPage().getParameters().get('TenancyContractId');
            
            list<Tenancy_Contract__C> TC = [Select Total_Price__c , Term_Commencement_Date__c, name, Quote__r.Non_Refundable_Deposit__c, Quote__r.Opportunity.Start_Date__c, Contract_Duration__c From Tenancy_Contract__c Where Id =:TenancyContractId ];        
            amount = TC[0].Total_Price__c ;
            TCName = TC[0].name;
            TCContractDuration = TC[0].Contract_Duration__c;
            selectedInstallmentsNo = TCContractDuration;
            
            tableData = new List<Tenancy_Contract_Payment__c>();  
            totalPercentage = 0 ;
            nonRefund = Tc[0].Quote__r.Non_Refundable_Deposit__c ;
            if(nonRefund == null ) nonRefund = 7.5;
            newContract = new Tenancy_Contract__c();
            newContract.Term_Commencement_Date__c = TC[0].Term_Commencement_Date__c;
            ReservationAmount = 0;
            CLI = ([Select Id from Contract_Line_Item__c where contract__c =:TenancyContractId limit 1]).get(0).Id;
            escalationList = new List<EscalationRate>();
            DepositAmount = 0;
        }
    }
    
    // select option for Installment Frequency 
    public list<selectoption> getInstallmentFrq() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption( '0' , 'Select'));
        options.add(new selectOption( '12' , '1'));     
        options.add(new selectOption( '6' , '2'));
        options.add(new selectOption( '4' , '3')); 
        options.add(new selectOption( '3' , '4')); 
        options.add(new selectOption( '2' , '6'));   
        return options;
    } 
    
    //  Generate Payment
    public PageReference generatePayment(){
        Decimal newAmount;
        Decimal yearlyAmount;
        Decimal serviceChargeAmt;
        Decimal ReservationPerc;
		Decimal DepositPerc;
        integer Increment = 0;
        inputs = false;
        RatesSet = false;
        tableData.clear();
        
        try {
            esclationMap.put(1, 0);
            for(EscalationRate item:escalationList){
                esclationMap.put(item.Year, item.Rate);
            }
            
            //First Year Amount = (Amount  / number of years)
            //Yearly Amount starting from the second one = Prev Year Amount + (Prev Year Amount * Escalation Rate / 100)
            //each payment = Yearly Amount / number of payments
            //Reservation Amount = Reservation Amount Amount
            //Payment1 of Year 1 = each payment - Reservation Amount 
            //Rest of Payments = each payment
            //Service charge = (Yearly Amount * Service charge Percentage /100)
            decimal oldAmount = amount;
            newAmount = amount;
            yearlyAmount = newAmount / ((selectedInstallmentsNo <= 1) ? 1 : selectedInstallmentsNo);
            //loop over the number of years
            for(integer y = 0; y < selectedInstallmentsNo; y++){
                yearlyAmount += (yearlyAmount*(esclationMap.get(y+1))/100);
                parAmount = ( yearlyAmount / (12/selectedInstallmentFrq) ) ;
                Percentage = ( ( 100 * parAmount ) / yearlyAmount ) ;  
                decimal per = ( ( 100 * parAmount ) / yearlyAmount ) ;
                multi = ( selectedInstallmentFrq * 30 ) ;           
                dueDate = newContract.Term_Commencement_Date__c ;
                nonRefundAmt =  yearlyAmount * (nonRefund / 100);
                if(selectedInstallmentsNo != null && selectedInstallmentFrq != null && newContract.Term_Commencement_Date__c != null ) {
                    dueDate = dueDate.addYears(y);
                    //loop over the number of months
                    for (integer i=1 ;i<=((12/selectedInstallmentFrq)+1);i++) {
                        Increment++;
                        Tenancy_Contract_Payment__c obj = new Tenancy_Contract_Payment__c();
                        //the Reservation Amount is paid once on the First Year
                        if(Y == 0 && i == 1){
							DepositPerc = (DepositAmount / yearlyAmount)*100;
                            obj.Percentage__c = DepositPerc ;
                            obj.Payment_Name__c = 'Security Deposit' ;
                            obj.Payment_Amount__c = DepositAmount;
                            obj.Due_Date_To__c = dueDate;
                            obj.YearNumber__c = string.valueof(Y+1);
                            obj.originalYearlyAmount__c = yearlyAmount;
                            obj.isSecurityDeposit__c = true;
                            obj.Tenancy_Contract_Line_Item__c = Cli;
                            tableData.add(obj); 
                            obj = new Tenancy_Contract_Payment__c();
							
                            ReservationPerc = (ReservationAmount / yearlyAmount)*100;
                            obj.Percentage__c = ReservationPerc ;
                            obj.Payment_Name__c = 'Reservation Amount' ;
                            obj.Payment_Amount__c = ReservationAmount;
                            obj.Due_Date_To__c = dueDate;
                            obj.YearNumber__c = string.valueof(Y+1);
                            obj.originalYearlyAmount__c = yearlyAmount;
                            obj.isReservation__c = true;
                            obj.Tenancy_Contract_Line_Item__c = Cli;
                            tableData.add(obj); 
                            obj = new Tenancy_Contract_Payment__c();
                        }
                        if (i==1 || i==2) {
                            dueDate = dueDate;
                        }
                        else {dueDate = ((selectedInstallmentsNo < 1) ? dueDate.addDays(Integer.valueof(selectedInstallmentsNo * selectedInstallmentFrq * 30)) : dueDate.addMonths(selectedInstallmentFrq));}
                        obj.Percentage__c = Percentage;
                        obj.Due_Date_To__c = dueDate;
                        obj.Payment_Amount__c = parAmount;
                        obj.Payment_Name__c = 'Payment '+ (i-1) ;
                        //Service Charge is paid once per year
                        if (i==1) {
                            obj.Percentage__c = nonRefund ;
                            obj.Payment_Name__c = 'Service Charge' ;
                            obj.Payment_Amount__c = nonRefundAmt;
                            obj.Due_Date_To__c = dueDate;
                            obj.isServiceCharge__c = true;
                        }
                        if (i==2) {
                            obj.Percentage__c = (Percentage - ReservationPerc)  ;
                            obj.Payment_Amount__c = parAmount - ReservationAmount;
                            system.debug(ReservationAmount);
                            system.debug(ReservationPerc);
                            ReservationAmount = 0;
                            ReservationPerc = 0;
                        }
                        if (obj != null){
                            obj.YearNumber__c = string.valueof(Y+1);
                            obj.originalYearlyAmount__c = yearlyAmount;
                            obj.Tenancy_Contract_Line_Item__c = Cli;
                            if(obj.Payment_Name__c == 'Service Charge' && y == 0 )
                                obj.Payment_Name__c = 'Basic Service Charge';
                            else
                                obj.Payment_Name__c = 'Year ' + obj.YearNumber__c + ' ' + obj.Payment_Name__c;
                            tableData.add(obj); }
                    }  
                    
                    totalAmount = 0 ;        
                    for(Tenancy_Contract_Payment__C pp : tableData){
                        totalAmount += pp.Payment_Amount__c ;   
                    }
                    totalAmount = totalAmount.setScale(2);
                    
                    totalPercentage = 0 ;
                    for(Tenancy_Contract_Payment__C pp : tableData){
                        totalPercentage += pp.Percentage__c;   
                    }
                    totalPercentage = totalPercentage.setScale(2);
                    
                }
                else{ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter all required fields'));} 
                
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getMessage() ));
            //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage())); 
        } 
        
        return null ;   
    } 
    
    public PageReference initPage(){
        
        return null ;
    }
    public PageReference clearPage(){
        RatesSet = false;
        escalationList.clear();
        tableData.clear();
        return null;
    }
    
    public PageReference HidePopup(){
        RatesSet = false;
        return null;
    }
    //set the rate to each year starting from the second Year
    public PageReference setEscalationRate(){
        if(selectedInstallmentFrq != 0){
            if(TCContractDuration == 0 || TCContractDuration == null){
                TCContractDuration = selectedInstallmentsNo;
            }
            if(TCContractDuration == selectedInstallmentsNo){
            decimal paymentAmount = 0;
            decimal newAmount = 0;
            decimal yearlyAmount = 0;
            yearlyAmount = amount / ((selectedInstallmentsNo <= 1) ? 1 : selectedInstallmentsNo);
            paymentAmount = yearlyAmount / (12/selectedInstallmentFrq);
            system.debug('paymentAmount '+paymentAmount);
            if(ReservationAmount > paymentAmount){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Reservation Amount should be less than or equal to '+string.valueOf(paymentAmount)+' . <br/>'));
            }
            else{
                //if(newContract.Term_Commencement_Date__c >= Date.Today()){
                    
                    if( selectedInstallmentsNo <= 1){
                        generatePayment();
                    }
                    else{
                            inputs = True;
                            escalationList.clear();
                            RatesSet = true;
                            for(integer i = 2; i<=selectedInstallmentsNo; i++){
                                escalationList.add(new EscalationRate(i));
                            }
                        
                    }
                    
                    
                //}
                //else{
                  //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please, Enter a Valid Start Date. <br/>'));
                //}
            }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Number of Years should be equals to ' + TCContractDuration+'. <br/>'));
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please, select the Number of Payments per Year. <br/>'));
        }
        
        return null;
    }
    
    public PageReference subApproval(){
        //try{   
        List<Tenancy_Contract_Payment__c> pays = [select id, ReadOnly__c from Tenancy_Contract_Payment__c  where Tenancy_Contract__c = : TenancyContractId] ;
        if(pays.size() > 0 ) {
            for(integer i = 0; i < pays.size(); i++){
                pays[i].ReadOnly__c = false;
            }
            update pays;
            delete pays;
        } 
        boolean noteReq = false;
        Boolean hasErrors = false ;
        string errors = '';
        integer count = 1;
        decimal pAmount = 0;
        map<Integer, Decimal> totalYearlyAmounts = new map<Integer, Decimal>();
        for(integer x = 1; x <= ((selectedInstallmentsNo <= 1) ? 1 : selectedInstallmentsNo); x++){
            totalYearlyAmounts.put(x, 0);
        }
        for(Tenancy_Contract_Payment__C item : tableData){
            if(item.Payment_Amount__c < 0) hasErrors = true ;
            if(item.payment_amount__c == 0 && (item.Description__c == '' || item.Description__c == null)) noteReq = true;
            if(item.isServiceCharge__c == false && item.isSecurityDeposit__c == false){
                pAmount = totalYearlyAmounts.get(Integer.valueOf(item.YearNumber__c));
                pAmount += item.Payment_Amount__c;
                totalYearlyAmounts.put(Integer.valueOf(item.YearNumber__c), pAmount);
            }
            
        }
        for(Tenancy_Contract_Payment__C item : tableData){
            if(item.isServiceCharge__c == false && item.isSecurityDeposit__c == false){
              if(totalYearlyAmounts.get(Integer.valueOf(item.YearNumber__c)).round(System.RoundingMode.HALF_UP) <> item.originalYearlyAmount__c.round(System.RoundingMode.HALF_UP) ){
                    if(errors.contains('Payment summation of Year '+item.YearNumber__c+' should be equal to '+item.originalYearlyAmount__c.round(System.RoundingMode.HALF_UP)+' .') == false)
                        errors += 'Payment summation of Year '+item.YearNumber__c+' should be equal to '+item.originalYearlyAmount__c.round(System.RoundingMode.HALF_UP)+' . <br/>';
                }
            }
        }
        if(noteReq){
            errors += 'Please, fill in notes field. Notes field is mandatory when percentage or price is 0. <br/>';
        }
        if(hasErrors){
            errors +='Payment Amount can not be Negative. <br/>';
        }
        if(errors != '' && errors != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errors)); 
            return null ;
        }
        for(Tenancy_Contract_Payment__C item : tableData){
            item.Tenancy_Contract__c = TenancyContractId ;
            item.Status__C = 'Inactive';
        }
        upsert tableData ;
        
        //Quote q = [select id , Non_Refundable_Deposit__c, PaymentsGenerated__c, status, Contract_Duration__c From Quote where Id = :QuoteId];
        //q.Non_Refundable_Deposit__c = nonRefund;
        //q.Contract_Duration__c = QuoteContractDuration;
        //update q ;
        //submitForApproval(q);
        PageReference nextPage = new PageReference('/' + TenancyContractId);
        return nextPage;
                   
    }  
    
    public PageReference Cancel(){
        //Redirect to the Tenancy Contratc object
        PageReference orderPage = new PageReference('/' + TenancyContractId);
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    public class EscalationRate{
        
        public integer Year{get;set;}
        public Decimal Rate{get;set;}
        
        public EscalationRate(integer y){
            this.year = y;
            this.rate = 0;
        }
    }
}