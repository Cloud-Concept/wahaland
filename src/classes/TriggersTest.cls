@isTest
public class TriggersTest {
    
    @isTest static void One_trg_Quote_Attachment_test(){
        //100% for trg_Quote_Attachment trigger
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        
        
        
        Attachment att = new Attachment(name = 'a', ParentId = q.Id, body = Blob.valueOf('hh'));
        Insert att;
        
        Quote_Attachment__c QA = new Quote_Attachment__c(Name = att.id);
        Insert QA;
        
        att.name = 'att';
        Update att;
        
        delete att;
    }
    
     @isTest static void One_trg_Invoice_Attachment_test(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Invoice__c invoice = new Invoice__c(name = 'test', Received_From__c = acc.Id);
        insert invoice;
        
        Attachment att = new Attachment(name = 'text.txt', ParentId = invoice.Id, body = Blob.valueOf('test.txt'));
        Insert att;
        
        Attachment att2 = new Attachment(name = 'text.txt', ParentId = invoice.Id, body = Blob.valueOf('test.txt'));
        Insert att2;
    }
    
    @isTest static void Two_trg_Quote_test1(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Tenancy_Contract__C Oldtc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert Oldtc;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        q.Khalifa_Fund__c = True;
        q.Status = 'Approved';
        update q;
        
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Plot_Land__c Plot2 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot2;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        insert unit1;	
        Unit__c unit2 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot2.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Leased / Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit2;
        
        q.Status = 'Accepted';
        update q;   
    }
    
    @isTest static void Two_trg_Quote_test2(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Leased / Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, Unit__c = Unit1.Id);
        Insert qli;
        
        q.Status = 'Denied';
        update q;
    }    
    
    @isTest static void Two_trg_Quote_test3(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Leased / Reserved', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, Unit__c = Unit1.Id);
        Insert qli;
        
        q.Status = 'Denied';
        update q;       
    }
    
    @isTest static void Two_trg_Quote_test4(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Reserved', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, Unit__c = Unit1.Id);
        Insert qli;
        
        q.Status = 'Denied';
        update q;  
    }
    
    @isTest static void Two_trg_Quote_test5(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, Unit__c = Unit1.Id);
        Insert qli;
        
        q.Status = 'Denied';
        update q;  
    }
    
    @isTest static void Three_QuoteLineItemOperations_Test(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Unserviced_Land' and SObjectType='Unit__c' limit 1].Id;
        
        Pricebook2 PB = new Pricebook2(Name = 'PB', IsActive = True);
        insert PB;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = PB.Id,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        Insert pbEntry2;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, PaymentsGenerated__c = False, Pricebook2Id = PB.Id);
        insert q;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        QuoteLineItem qli2 = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro.Id, PricebookEntryId = pbEntry2.Id, Quantity = 50, UnitPrice =1, ReadOnly__c = True, Unit__c = Unit1.Id);
        Insert qli2;
        
        
        qli2.Quantity = 100;
        Update qli2;
        
        qli2.ReadOnly__c = False;
        Update qli2;
        delete qli2;
    }
    
    @isTest static void Four_trg_OfferPaymentsOperations_Test(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isServiceCharge__c = True, YearNumber__c = '1');
        Insert pp;
        
        Payment_Plan__c pp2 = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today(), isReservation__c = True);
        Insert pp2;
        
        pp.Payment_Amount__c = 20;
        update pp;
        
        pp2.Payment_Amount__c = 20;
        pp2.SubmitForApproval__c = true;
        update pp2;
        try{
        delete pp;
        delete pp2;
        }
        catch(Exception e){}
    }
    
    @isTest static void Five_trg_CalcQuoteAmounts_Test(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Unserviced_Land' and SObjectType='Unit__c' limit 1].Id;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        
        QuoteLineItem qli2 = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro2.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, ReadOnly__c = True, Unit__c = Unit1.Id);
        Insert qli2;
        
        try{
            
        qli2.Quantity = 100;
        Update qli2;
        }
        catch(Exception e){}
        qli2.ReadOnly__c = False;
        qli2.Quantity = 100;
        Update qli2;
        delete qli2;       
        
    }
    
    @isTest static void Five_trg_CalcQuoteAmounts2_Test(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        List<Product2> productList = new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        productList.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        productList.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        productList.add(pro3);
        insert productList;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Unserviced_Land' and SObjectType='Unit__c' limit 1].Id;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntryStd;
        
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Reserved_by_Offer_Letter__c = q.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Pending Sales', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        Insert unit1;
        QuoteLineItem qli3 = new QuoteLineItem(QuoteId = q.Id, Product2Id = pro3.Id, PricebookEntryId = pbEntryStd.Id, Quantity = 50, UnitPrice =1, ReadOnly__c = True, Unit__c = Unit1.Id);
        Insert qli3;
        qli3.ReadOnly__c = False;
        Update qli3;
        delete qli3;
        test.stopTest();
    }
    @isTest static void six_trg_Account_test(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Tenancy_Contract__C Oldtc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert Oldtc;
        
        Acc.name = 'Acc2';
        update Acc;
    }
    
    static testmethod void seven_trg_ReceiptOperations(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Receipt__c receipt1 = new Receipt__c(Name = '1', Received_From__c = acc.Id, Amount__c = 1000);
        insert receipt1;
        Receipt_Line_Items__c RLI1 = new Receipt_Line_Items__c(Amount_Received__c = 1000, Receipt__c = receipt1.Id);
        insert RLI1;
        
        Receipt__c receipt2 = new Receipt__c(Name = '2', Received_From__c = acc.Id, Amount__c = 100);
        insert receipt2;        
        Receipt_Line_Items__c RLI2 = new Receipt_Line_Items__c(Amount_Received__c = 100, Receipt__c = receipt2.Id);
        insert RLI2;
        
        Receipt__c receipt3 = new Receipt__c(Name = '3', Received_From__c = acc.Id, Amount__c = 100000);
        insert receipt3;
        Receipt_Line_Items__c RLI3 = new Receipt_Line_Items__c(Amount_Received__c = 100000, Receipt__c = receipt3.Id);
        insert RLI3;
        
        Receipt__c receipt4 = new Receipt__c(Name = '4', Received_From__c = acc.Id, Amount__c = 50);
        insert receipt4;
        Receipt_Line_Items__c RLI4 = new Receipt_Line_Items__c(Amount_Received__c = 50, Receipt__c = receipt4.Id);
        insert RLI4;
    }
    
    @isTest static void trg_caseOperationsTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        
        List<entitlement> enList = new List<entitlement>();
        enList.add(new entitlement(Name = 'Sales Entitlements', AccountId = acc.Id));
        enList.add(new entitlement(Name = 'Technical Entitlements', AccountId = acc.Id));
        insert enList;
        
        Case caseObj = new case(account = acc, contact = c, status='New', Origin='web', type = 'Sales/Leasing Issues');
        insert caseObj;
        
        Case caseObj2 = new case(account = acc, contact = c, status='New', Origin='web', type = 'Technical');
        insert caseObj2;

        test.stopTest();
    }
    
}