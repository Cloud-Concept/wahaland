@isTest
public class HelperClassesTest {
    
    @isTest static void One_invoiceHelperClass_Test(){
        Account Acc = new Account(name = 'Acc');
        Insert Acc;
        Invoice__c inv = new Invoice__c(name = 'inv', Received_From__c = Acc.Id);
        Insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c(Invoice__c = inv.Id);
        Insert ili;
        
        invoiceHelperClass.postInvoice(inv.Id);
        invoiceHelperClass.generateServiceRequestReceipt(inv.id);
    }
    
    @isTest static void Two_ContractHelperClass_Test(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Term_Commencment_Date__c = System.today(), Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        ContractHelperClass.createTenancyContract(q.Id);
        
    }
    
    @isTest static void Two_ContractHelperClass_Test2(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, Agreement_Status__c = 'Approved', Status__c = 'Draft', Payments_Counter__c = 2);
        Insert tc;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id,  Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        ContractHelperClass.activateTenancyContract(tc.Id);
        
    }
    
    @isTest static void Two_ContractHelperClass_Test3(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Agreement_Status__c = 'Approved', Status__c = 'Draft', Payments_Counter__c = 2);
        Insert tc;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id,  Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        ContractHelperClass.renewContract(tc.Id);
        ContractHelperClass.cancelContract(tc.Id);
        ContractHelperClass.confirmCancelContract(tc.Id);
        
    }
    
    @isTest static void Two_ContractHelperClass_Test4(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Agreement_Status__c = 'Approved', Status__c = 'Draft', Payments_Counter__c = 2);
        Insert tc;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id,  Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;

        ContractHelperClass.cancelContract(tc.Id);
        
    }
    
    @isTest static void Two_ContractHelperClass_Test5(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Agreement_Status__c = 'Approved', Status__c = 'Draft', Payments_Counter__c = 2);
        Insert tc;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id,  Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;

        ContractHelperClass.confirmCancelContract(tc.Id);
        
    }
    
    @isTest static void Three_ProposalHelperClass_Test(){
        Account Acc = new Account(name = 'Acc');
        Insert Acc;
        
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Term_Commencment_Date__c = System.today() , Lease_Commencment_Date__c = System.today(), Contract_Duration__c = 2, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1);
        Insert qli;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=Opp.Id,PriceBookEntryID=pbEntryStd.id, quantity=4, totalprice=200);
        insert lineItem1;
        
        ProposalHelperClass.isReadyToCreateNewOfferLetter(Opp.Id);
        ProposalHelperClass.CreateOfferLetters(Opp.Id);
        //ProposalHelperClass.checkSubmitForApproval(q.Id);
        ProposalHelperClass.checkAgreementGenerated(q.Id);
        ProposalHelperClass.ConvertOfferLetterStatus(Opp.Id);
        
    }
    
}