trigger trg_TCPaymentsOperations on Tenancy_Contract_Payment__c (after insert, after update, after delete, before delete) {
    //This Trigger is to calculate all the Service charge Payments on a the contract 
    //each time we will re-calcuate the service charge.
    
    //Declare the variables
    Set<Id> TCIds = new set<Id>();
    List<Tenancy_Contract__c> TCList = new List<Tenancy_Contract__c>();
    List<AggregateResult> TCSumList = new List<AggregateResult>();
    List<Tenancy_Contract_Payment__c> TCSCPayments = new List<Tenancy_Contract_Payment__c>();
    Map<Id, Decimal> TCPMap = new Map<Id, Decimal>();
    Decimal sum;
    Integer i;
    List<AggregateResult> paymentsCounterList = new List<AggregateResult>();
    set<Id> TCPIds = new set<Id>();
    List<Tenancy_Contract__c> tcpList = new List<Tenancy_Contract__c>();
    Set<Id> tenancyIds = new Set<Id>();
    Map<Id, Tenancy_Contract__c> tCBasicCharge = new Map<Id, Tenancy_Contract__c>();
    Map<Id, Tenancy_Contract__c> tCSecurityDeposit = new Map<Id, Tenancy_Contract__c>();
    Map<Id, Tenancy_Contract__c> tCReservation = new Map<Id, Tenancy_Contract__c>();
    Map<Id, Decimal> tCAnnualRent = new Map<Id, Decimal>();
    Set<Id> TCIdsPCounter = new Set<Id>();
    Decimal annualRent = 0;
    Decimal securityDeposit = 0;
    Decimal basicCharge = 0;
    Decimal reservationAmount=0;
    if(trigger.isbefore){
        if(trigger.IsDelete){
            for(Tenancy_Contract_Payment__c item: Trigger.Old){
                if(item.ReadOnly__c == true){
                    item.AddError('You Cannot Delete This Record.');
                }
            }
        }
    }
    if(Trigger.isAfter){
        if(Trigger.IsDelete){
            for(Tenancy_Contract_Payment__c TCP:Trigger.Old){
                if(TCP.isServiceCharge__c){
                    TCIds.add(TCP.Tenancy_Contract__c);
                    if(TCP.YearNumber__c == '1')
                        tenancyIds.add(TCP.Tenancy_Contract__c);
                }
                else if(TCP.isReservation__c|| TCP.isSecurityDeposit__c || TCP.YearNumber__c == '1'){
                    tenancyIds.add(TCP.Tenancy_Contract__c);
                }
                TCPIds.add(TCP.Tenancy_Contract__c);
            }
            
            paymentsCounterList = [SELECT COUNT(Id)cnum ,Tenancy_Contract__c FROM Tenancy_Contract_payment__c WHERE Tenancy_Contract__c IN:tcpIds Group by Tenancy_Contract__c];
            List<Tenancy_Contract__c> TCListPayments = [Select Id, Payments_Counter__c From Tenancy_Contract__c where Id in :tcpIds];
            for(Tenancy_contract__C tc:TCListPayments){
                tc.Payments_Counter__c = 0;
            }
            if(TCListPayments.size()>0)
                update TCListPayments;
            for (AggregateResult tc : paymentsCounterList){
                for (Id ids : tcpIds){
                    if (tc.get('Tenancy_Contract__c') == ids){
                        Tenancy_Contract__c t = new tenancy_contract__c (id = ids , Payments_Counter__c = Integer.valueOf(tc.get('cnum')));
                        tcpList.add(t);
                    }
                }
            }
            update tcpList;
        }
        else{
            for(Tenancy_Contract_Payment__c TCP:Trigger.New){
                if(TCP.isServiceCharge__c){
                    TCIds.add(TCP.Tenancy_Contract__c);
                    if(TCP.YearNumber__c == '1')
                        tenancyIds.add(TCP.Tenancy_Contract__c);
                }
                else if(TCP.isReservation__c|| TCP.isSecurityDeposit__c || TCP.YearNumber__c == '1'){
                    tenancyIds.add(TCP.Tenancy_Contract__c);
                }
                TCPIds.add(TCP.Tenancy_Contract__c);
            }
        }
        if(TCIds.size()>0){
            TCSumList = [Select Tenancy_Contract__c, Sum(Payment_Amount__c) payments From Tenancy_Contract_Payment__c Where Tenancy_Contract__c in:TCIds and isServiceCharge__c = true group by Tenancy_Contract__c];
            TCSCPayments = [Select Tenancy_Contract__c, Payment_Amount__c From Tenancy_Contract_Payment__c Where Tenancy_Contract__c in:TCIds and isServiceCharge__c = true];
            TCList = [Select Id, Service_Charges_dev__c From Tenancy_Contract__c Where Id in :TCIds];
            
            for(AggregateResult ar:TCSumList){
                sum = 0;
                sum = (Decimal)ar.get('payments');
                string a = string.valueof(ar.get('Tenancy_Contract__c'));
                Id tcid = Id.Valueof(a);
                TCPMap.Put(tcid, sum);
            }
            i=0;
            for(Tenancy_Contract__c TC:TCList){
                TCList[i].Service_Charges_dev__c = (Decimal)TCPMap.get(TCList[i].Id);
                i++;
            }
            if(TCList.size()>0){
                update TCList;
            }
        }
        if (Trigger.isInsert && TCPIds.size() >0){
            paymentsCounterList = [SELECT COUNT(Id)cnum ,Tenancy_Contract__c FROM Tenancy_Contract_payment__c WHERE Tenancy_Contract__c IN:tcpIds Group by Tenancy_Contract__c];
            for (AggregateResult tc : paymentsCounterList){
                for (Id ids : tcpIds){
                    if (tc.get('Tenancy_Contract__c') == ids){
                        Tenancy_Contract__c t = new tenancy_contract__c (id = ids , Payments_Counter__c = Integer.valueOf(tc.get('cnum')));
                        tcpList.add(t);
                    }
                }
            }
            update tcpList;
        } 
        if(tenancyIds.size()>0){
            TCList = new List<Tenancy_Contract__c>();
            TCList = [Select Id, Basic_Service_Charge__c, Annual_Year_Rent__c, Security_Deposit__c, Reservation_Amount__c From Tenancy_Contract__c Where Id in :tenancyIds];
            TCSumList = new List<AggregateResult>();
            tcBasicCharge.putAll([Select Id, (Select Tenancy_Contract__c, Payment_Amount__c From Tenancy_Contract_Payments__r Where isServiceCharge__c = True and YearNumber__c ='1') From Tenancy_Contract__c Where Id in:tenancyIds]);
            tcReservation.putAll([Select Id, (Select Tenancy_Contract__c, Payment_Amount__c From Tenancy_Contract_Payments__r Where isReservation__c = True) From Tenancy_Contract__c where Id in:tenancyIds]);
            tcSecurityDeposit.putAll([Select Id, (Select Tenancy_Contract__c, Payment_Amount__c From Tenancy_Contract_Payments__r Where isSecurityDeposit__c = True) From Tenancy_Contract__c where Id in:tenancyIds]);
            TCSumList = [Select Tenancy_Contract__c, Sum(Payment_Amount__c) payments From Tenancy_Contract_Payment__c Where Tenancy_Contract__c in:tenancyIds 
                         and isServiceCharge__c = false and isSecurityDeposit__c = false and YearNumber__c ='1' group by Tenancy_Contract__c];
            for(AggregateResult ar:TCSumList){
                Id tcId = Id.Valueof(string.valueof(ar.get('Tenancy_Contract__c')));
                tcAnnualRent.put(tcId, (Decimal)ar.get('payments'));
            }
            for(i = 0; i<tcList.size(); i++){
                if(tcAnnualRent.size()>0 && tcAnnualRent.get(tcList[i].Id) != null)
                    annualRent = tcAnnualRent.get(tcList[i].Id);
                else
                    annualRent = 0;
                if(tcBasicCharge.size()>0 && tcBasicCharge.get(tcList[i].Id).Tenancy_Contract_Payments__r.size() > 0)
                    basicCharge = tcBasicCharge.get(tcList[i].Id).Tenancy_Contract_Payments__r[0].Payment_Amount__c;
                else
                    basicCharge = 0;
                if(tcSecurityDeposit.size()>0 && tcSecurityDeposit.get(tcList[i].Id).Tenancy_Contract_Payments__r.size() > 0)
                    securityDeposit = tcSecurityDeposit.get(tcList[i].Id).Tenancy_Contract_Payments__r[0].Payment_Amount__c;
                else
                    securityDeposit = 0;
                if(tcReservation.size()>0 && tcReservation.get(tcList[i].Id).Tenancy_Contract_Payments__r.size() > 0)
                    reservationAmount = tcReservation.get(tcList[i].Id).Tenancy_Contract_Payments__r[0].Payment_Amount__c;
                else
                    reservationAmount = 0;
                tcList[i].Basic_Service_Charge__c = basicCharge;
                tcList[i].Annual_Year_Rent__c = annualRent;
                tcList[i].Security_Deposit__c = securityDeposit;
                tcList[i].Reservation_Amount__c = reservationAmount;
            }
            update tcList;
        }
    }
}