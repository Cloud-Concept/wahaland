global class ContractHelperClass {
    //Create Tenancy Contract from The Quote.
    webservice static string createTenancyContract(Id quoteId){
        Tenancy_Contract__c tenancyContract = new Tenancy_Contract__c();
        Contract_Line_Item__c cli;
        List<Contract_Line_Item__c> contractList = new List<Contract_Line_Item__c>();
        List<Contract_Payments__c> contractPayments = new List<Contract_Payments__c>();
        List<Tenancy_Contract_Payment__c> tenancyConPaymentList = new List<Tenancy_Contract_Payment__c>();
        Tenancy_Contract_Payment__c tCP;
        List<Payment_Plan__c> payments = new List<Payment_Plan__c>(); 
        List<unit__c> units = new List<unit__c>();
        List<Id> unitIds = new List<Id>();
        Id recordTypeId;
        recordTypeId = [select id from recordtype where SobjectType = 'Tenancy_Contract__c' and developername = 'Draft' ].Id;
        
        Quote quoteObj = [SELECT Id , Email, Phone, Fax, ContactId, AccountId , Name , Broker_Account__c , Broker_Contact_Person__c , Cancellation_Reason__c ,
                          Contract_Duration_Year_Month__c , Contract_Duration__c , Date_Approved__c , Khalifa_Fund__c ,
                          Lease_Commencment_Date__c , Non_Refundable_Deposit__c , Number_of_Years_for_Service_Charges__c ,
                          Payment_Plan__c , Proposal_Validaty_Date__c ,Quote_Line_Item_With_High_Discount__c,QuotePaymentSum__c
                          ,Reservation_Agreement_Deposit_Recieved__c,Reservation_Agreement_Number__c,Reservation_Agreement_Sent__c
                          ,Reservation_Agreement_Signed__c , Reservation_Deposit_Amount__c , Term_Commencment_Date__c ,
                          Terms_Conditions__c , Basic_Service_Charge__c, Annual_Year_Rent__c, Security_Deposit__c, Reservation_Amount__c,
                          						(SELECT Discounted_Annual_Rent__c , Actual_1st_Year_Rent_No_Rent_Free_Period__c,
                                                 Discounted_Annual_Service_Charges__c , Actual_Rent_Rate_1st_Year__c , Allocated_Power_in_KVA__c , 
                                                 Annual_Rent_Apron__c , Annual_Rent_Plot__c , Area_in_sq_m_Apron_hidden__c , Area_in_sq_m_Plot_hidden__c
                                                 , Average_Annual_Net_Rent__c , Discount_Below_Minimum_Price__c , Fit_Out_Deposit_Percent__c, 
                                                 Installments_Per_Year__c , List_Price_Apron__c , Maximum_Price_Apron__c , Id ,
                                                 Maximum_Price_Plot__c , Maximum_Rent_Rate__c , Minimum_Price_Apron__c , Minimum_Price_Plot__c ,
                                                 Minimum_Rent_Rate__c , Payment_Plan__c , Payment_Plan_Generated__c , Rent_Price__c , Reserved_or_Leased_Until__c ,
                                                 Sales_Price_Apron__c , Sales_Price_Plot__c , Service_Charge_Installments_Per_Year__c , Total_Price__c ,
                                                 Base_Service_Charges__c , Total_Rent_After_discount__c , Total_Service_Charge_After_discount__c , 
                                                 Unit__c , Unit_name__c , Updated__c, Product2Id, UnitPrice, Quantity FROM QuoteLineItems) FROM Quote WHERE Id =: quoteId];
        List<Contact> con = [Select Id, Email from Contact where is_Primary__c = true and AccountId =:QuoteObj.AccountId];
        if(con.size()>0){
            TenancyContract.PrimaryContactEmail__c = con[0].email;
        }
        tenancyContract.Account__c = quoteObj.AccountId;
        tenancyContract.Quote__c = quoteId;
        tenancyContract.Status__c = 'Draft';
        //edited by Nermin
        tenancyContract.Email__c = quoteObj.Email;
        tenancyContract.Phone__c = quoteObj.Phone;
        tenancyContract.Fax__c = quoteObj.Fax;
        tenancyContract.Contact__c = quoteObj.ContactId;
        tenancyContract.Lease_Commencement_Date__c = quoteObj.Lease_Commencment_Date__c;
        tenancyContract.Term_Commencement_Date__c = quoteObj.Term_Commencment_Date__c;
        tenancyContract.Contract_Duration__c = quoteObj.Contract_Duration__c;
        tenancyContract.Contract_Duration_in_Months__c = quoteObj.Contract_Duration_Year_Month__c;
        tenancyContract.RecordTypeId = recordTypeId;
        tenancyContract.KFund__C = quoteObj.Khalifa_Fund__c;
        tenancyContract.Unit_Release_Date__c = quoteObj.Term_Commencment_Date__c.AddMonths(integer.valueof(quoteObj.Contract_Duration__c * 12))-1;
        tenancyContract.Contract_Expiry_Date__c = tenancyContract.Unit_Release_Date__c;
        tenancyContract.Basic_Service_Charge__c = quoteObj.Basic_Service_Charge__c;
        tenancyContract.Annual_Year_Rent__c = quoteObj.Annual_Year_Rent__c;
        tenancyContract.Security_Deposit__c = quoteObj.Security_Deposit__c;
        tenancyContract.Reservation_Amount__c = quoteObj.Reservation_Amount__c;        
        // edited by Marina
        tenancyContract.Number_of_Years_for_Service_Charges__c = quoteObj.Contract_Duration__c;
        tenancyContract.Owner_Expiration_Notice_days__c = 60;
        tenancyContract.Agreement_Status__c = 'Approved';
        if (quoteObj.quoteLineItems.size()>0){
            tenancyContract.First_Line_Item_Unit_Name__c  = quoteObj.quoteLineItems[0].Unit_Name__c;
        }
        Insert tenancyContract;
        System.Approval.unlock(quoteObj, false);
        system.Approval.unlock(tenancyContract, false);
        
        for (QuoteLineItem item: quoteObj.quoteLineItems){
            cli = new Contract_Line_Item__c();
            cli.Product__c = item.Product2Id;
            cli.Quote_Line_Item__c = item.Id;
            cli.Unit__c = item.Unit__c;
            cli.Status__c = 'Draft';
            cli.Contract__c = tenancyContract.Id;
            cli.Base_Service_Charges__c = item.Base_Service_Charges__c;
            //edited by Nermin
            cli.UnitPrice__c = item.UnitPrice;
            cli.Quantity__c = item.Quantity;
            cli.Reserved_or_Leased_Until__c = item.Reserved_or_Leased_Until__c;
            cli.ReadOnly__c = true;
            //
            contractList.add(cli);
            unitIds.add(item.Unit__c);
        }
        
        if (contractList.size()>0) {
            insert contractList;
        }
        // Create the Tenancy Contract Payments from the offer payments.
        payments = [select Id, isSecurityDeposit__c, isReservation__c, isServiceCharge__c, Due_Date__c, Paid__c, Payment_Amount__c, Payment_Name__c, Name, Status__c, Quote__c, Description__c, YearNumber__C from Payment_Plan__c where Quote__c =:quoteId];
        if(payments.size()>0){
            tenancyConPaymentList = new List<Tenancy_Contract_Payment__c>();
            for (Payment_Plan__c payment : payments){
                tCP = new Tenancy_Contract_Payment__c();
                tCP.Tenancy_Contract__c = tenancyContract.Id;
                tCP.Tenancy_Contract_Line_Item__c = contractList[0].Id; 
                tCP.Status__c = 'Inactive';
                tcp.Payment_Amount__c = payment.Payment_Amount__c;
                tcp.Due_Date_To__c = payment.Due_Date__c;
                tcp.Payment_Name__c = payment.Payment_Name__c;
                tcp.isServiceCharge__c = payment.isServiceCharge__c;
                tcp.isSecurityDeposit__c = payment.isSecurityDeposit__c;
                tcp.isReservation__c = payment.isReservation__c;
                tcp.YearNumber__c = payment.YearNumber__C;
                if(payment.isServiceCharge__c){
                    tcp.Payment_Types__c = 'Service Charge';
                }
                else if(payment.isSecurityDeposit__c){
                    tcp.Payment_Types__c = 'Security Deposit';
                }
                tcp.Related_to_Offer_Proposal__c = payment.Id;
                tcp.Description__c = payment.Description__c;
                tenancyConPaymentList.add(tCP);
                
            }
            insert tenancyConPaymentList;
        }
        
        //System.Approval.lock(quoteObj, false);
        return 'Success'+tenancyContract.Id;
    }
    //Clone the Tenancy Contract
    webservice static String renewContract(Id contractId){
        Tenancy_Contract__c oldContract;
        List<Contract_Line_Item__c> oldContractLIList = new List<Contract_Line_Item__c>();
        List<Tenancy_Contract_Payment__c> oldTContractPayments = new List<Tenancy_Contract_Payment__c>();
        Tenancy_Contract__c newContract;
        List<Contract_Line_Item__c> newContractLIList = new List<Contract_Line_Item__c>();
        List<Tenancy_Contract_Payment__c> newTContractPayments = new List<Tenancy_Contract_Payment__c>();
        Tenancy_Contract_Payment__c newTCP;
        
        List<Tenancy_Contract_Payment__c> paymentsValidation = new List<Tenancy_Contract_Payment__c>();
        List<Tenancy_Contract__c> tCRenewedBefore=new List<Tenancy_Contract__c>();
        tCRenewedBefore.addAll([Select Id, Name From Tenancy_Contract__c Where Renewed_Contract__c =:contractId and status__c not in ('Canceled', 'Rejected')]);
        if(tCRenewedBefore.Size() > 0){
            return 'This Contract is Renwed before.';
        }
        else{
            //Map<Id, List<Tenancy_Contract_Payment__c>> TenancyContractPayment_Map = new Map<Id, List<Tenancy_Contract_Payment__c>>();
            paymentsValidation = [SELECT Id , Paid__c , Status__c FROM Tenancy_Contract_Payment__c WHERE Status__c = 'Active' AND Paid__c = false and tenancy_Contract__c = :contractId];
            if (paymentsValidation.size() > 0){
                return 'You cannot renew contract unless all payments are Cleared';
            }
            else {
                integer Count = 0;
                Id recordTypeId;
                recordTypeId = [select id from recordtype where SobjectType = 'Tenancy_Contract__c' and developername = 'Draft' ].Id;
                //clone the tenancy contract object
                oldContract = [Select Id, Name, Account__c, KFund__c, Actual_1st_Year_Rent__c, Actual_1st_Year_Service_Charges__c, 
                               Agreement_Status__c, Approval_Status__c, Authorized_Waha_Signatory__c, Break_Clause__c, 
                               Cancellation_Date_Payment__c, Checked_Out_Report__c, Contact__c, Contract_Duration__c, 
                               Contract_Duration_in_Months__c, Contract_Expiry_Date__c, Unit_Release_Date__c, Contract_Type__c, 
                               Customer_Signed_By__c, Payments_Cancellation_Date__c, Guarantor_Name__c, Guarantor_Address__c, Guarantor_Trade_Name__c,
                               Customer_Signed_Date__c, Description__c, Development_No__c, First_Line_Item_Unit_Name__c, Grand_Total__c, 
                               Fax__c, Phone__c, Email__c, 
                               Land_Area__c, Lease_Commencement_Date__c, Number_of_Installments__c, Number_of_Years_for_Service_Charges__c, 
                               Renewed_Contract__c, Owner_Expiration_Notice_days__c, Quote__c, Rent_Adjustment__c, Rent_Free_Period_Days__c, 
                               Security_Deposit__c, Service_Charges_Per_Square_Meter__c, SMS_Agent_Mobile__c, SMS_Tenant_Mobile__c, Special_Conditions__c, 
                               Status__c, Tawtheeq_Fees__c, Term_Commencement_Date__c, Term_Expiry_date__c, Termination_Date__c, Unit_Area__c, 
                               Unit_Number__c, Value_of_Damages__c, Waha_Signed_Date__c, RecordTypeId  From Tenancy_Contract__c where id = :contractId];
                
                newContract = new Tenancy_Contract__c();
                newContract = oldContract.clone(false, true, false, false);
                newContract.Status__c = 'Draft';
                newContract.Renewed_Contract__c = contractId;
                newContract.RecordTypeId = recordTypeId;
                newContract.Customer_Signed_By__c = null;
                newContract.Customer_Signed_Date__c = null;
                newContract.Waha_Signed_Date__c = null;
                //newContract.Authorized_Waha_Signatory__c = null;
                newContract.Activated_By__c = null;
                newContract.Activated_Date__c = null;
                newContract.Approval_Status__c = null;
                newContract.Agreement_Status__c = 'Approved';
                newContract.Tawtheeq_Fees__c = 0;
                newContract.Basic_Service_Charge__c = 0;
                newContract.Annual_Year_Rent__c = 0;
                newContract.Security_Deposit__c = 0;
                newContract.Reservation_Amount__c = 0; 
                insert newContract;
                
                //get tenancy contract line items and its Tenancy Contract Payments
                oldContractLIList = [Select id, Name, Base_Service_Charges__c, Building_Number__c, Contract__c, Discount_Description__c, 
                                     Line_Item_Description__c, Quote_Line_Item__c, Office_Area__c, Office_number__c, Office_Rent__c, Payment_Plan_Template__c, 
                                     Product__c, Quantity__c, Reserved_or_Leased_Until__c, UnitPrice__c, Security_Deposit__c, Special_Condition__c, 
                                     Special_Condition_English__c, Status__c, Total_Price__c, Unit__c, Warehouse_Area__c, Warehouse_number__c, 
                                     Warehouse_Rent__c, 
                                     (Select Id, Cash_Inflow_Date__c, Paid__c, Credit__c, Description__c, Is_System_Generated__c, 
                                      Payment_Amount__c, Due_Date_To__c, Payment_Method__c, Payment_Name__c,
                                      Payment_Type__c, Payment_Types__c, Related_to_First_Year__c, Related_to_Offer_Proposal__c, Status__c, 
                                      Tenancy_Contract__c, Tenancy_Contract_Line_Item__c From Tenancy_Contract_Payments__r )
                                     From Contract_Line_Item__c where Contract__c = :contractId ];
                newContractLIList = oldContractLIList.deepclone(false, false, false);
                
                Count = newContractLIList.Size();
                for(integer i = 0; i<Count; i++){
                    newContractLIList[i].Status__c = 'Draft';
                    newContractLIList[i].Contract__c = newContract.Id;
                    newContractLIList[i].ReadOnly__c = true;
                }
                
                insert newContractLIList;
                system.Approval.unlock(newContract, false);
                return 'Success' + newContract.Id;
            }
        }
    }
    //Cancel the Tenancy Contract
    webservice static string cancelContract(Id contractId){
        List<Tenancy_Contract__c> tCRenewedBefore=new List<Tenancy_Contract__c>();
        tCRenewedBefore.addAll([Select Id, Name From Tenancy_Contract__c Where Renewed_Contract__c =:contractId and status__c not in ('Canceled', 'Rejected')]);
        if(tCRenewedBefore.Size() > 0){
            return 'You cannot cancel this contract.';
        }
        else{
            List<Tenancy_Contract_Payment__c> payments = [SELECT Id FROM Tenancy_Contract_Payment__c WHERE Tenancy_Contract__c =: ContractId
                                                          AND Status__c = 'Active' And paid__c = false];
            if (payments.size() > 0 ){
                return 'Contract cannot be set to under cancellation unless all active payments are cleared';
            }
            else{
                Tenancy_Contract__c tContract = new Tenancy_Contract__c();
                Id recordTypeId;
                recordTypeId = [select id from recordtype where SobjectType = 'Tenancy_Contract__c' and developername = 'Under_Cancellation' ].Id;
                tContract = [select id, RecordTypeId, Status__c, Cancellation_Approval_Status__c from Tenancy_Contract__c where id = :contractId];
                tContract.RecordTypeId = recordTypeId;
                tContract.Status__c = 'Under Cancellation';
                tContract.Cancellation_Approval_Status__c = 'Not Submitted';
                update tContract;
                return 'Success';
            }
        }
    }
    
    webservice static String submitContractforApproval(Id contractId){
        Tenancy_Contract__c tc = new Tenancy_Contract__c();
        tc.Id = contractId;
        tc.submit_for_approval__c = true;
        update tc;
        return 'Success';
    }
    
    webservice static String submitContractforCOOApproval(Id contractId){
        Tenancy_Contract__c tc = new Tenancy_Contract__c();
        tc.Id = contractId;
        tc.Submit_for_COO_Approval__c = true;
        update tc;
        return 'Success';
    }
    
    webservice static String submitContractforFinanceApproval(Id contractId){
        Tenancy_Contract__c tc = new Tenancy_Contract__c();
        tc.Id = contractId;
        tc.Submit_for_Finance_Approval__c = true;
        update tc;
        return 'Success';
    }
    
    webservice static String confirmCancelContract(Id contractId){
        Id cancelRecordTypeId = Schema.SObjectType.Tenancy_Contract__c.getRecordTypeInfosByName().get('Canceled').getRecordTypeId();
        Tenancy_Contract__c tc = new Tenancy_Contract__c();
        tc.Id = contractId;
        tc.Status__c = 'Canceled';
        tc.RecordTypeId = cancelRecordTypeId;
        update tc;
        return 'Success';
    }
    
    webservice static string activateTenancyContract(Id contractId){
        Tenancy_Contract__c contract = [SELECT Id , Tenancy_Contract__c , Status__c , Quote__c , Activated_by__c , Activated_date__c
                                        FROM Tenancy_Contract__c WHERE Id =: contractId];  
        List<Contract_line_item__c> cli = [SELECT unit__r.Availability__c FROM Contract_line_item__c WHERE Contract__c =: contractId];
        
        Boolean reserved = false;
        for (Contract_Line_item__c con : cli){
            if (con.unit__r.Availability__c == 'Leased / Reserved'){
                reserved = true;
                break;
            }
        }
        
        if (reserved){
            return 'You cannot activate contract unless all leased units are released';
        }
        else{
            System.debug(contractId);
            contract.Status__c = 'Active';
            contract.Activated_Date__c = System.today();
            contract.Activated_by__c = userInfo.getUserId();
            Quote q = new Quote(id = contract.Quote__c);
            update contract;
            System.Approval.lock(contract);
            System.Approval.lock(q);
            return 'Success';
        }
    }
}