@isTest
public class ControllerSTest {
    
    @isTest static void One_ctrl_REPaymentGenerationTest(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        ApexPages.currentPage().getParameters().put('QuoteId', q.id);
        ctrl_REPaymentGeneration REP = new ctrl_REPaymentGeneration();
        REP.selectedInstallmentFrq = 2;
        REP.amount = 10000;
        REP.selectedInstallmentsNo = 2;
        REP.selectedInstallmentsNo = 4;
        REP.ReservationAmount = 20;
        REP.DepositAmount = 1000;
        REP.getInstallmentFrq();
        REP.setEscalationRate();
        REP.generatePayment();
        REP.subApproval();
        REP.initPage();
        REP.clearPage();
        REP.HidePopup();
        REP.Cancel();
    }
    
    @isTest static void Two_ctrl_TCPaymentGenerationTest(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Term_Commencement_Date__c = System.today(), Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert tc;
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id);
        Insert cli;
        ApexPages.currentPage().getParameters().put('TenancyContractId', tc.id);
        ctrl_TCPaymentGeneration TCP = new ctrl_TCPaymentGeneration();
        TCP.selectedInstallmentFrq = 2;
        TCP.amount = 10000;
        TCP.selectedInstallmentsNo = 2;
        TCP.selectedInstallmentsNo = 4;
        TCP.ReservationAmount = 20;
        TCP.DepositAmount = 1000;
        TCP.getInstallmentFrq();
        TCP.setEscalationRate();
        TCP.generatePayment();
        TCP.subApproval();
        TCP.initPage();
        TCP.clearPage();
        TCP.HidePopup();
        TCP.Cancel();
    }
    
    @isTest static void Three_ctrl_REProductSelectionTest(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', Product_Type__C = 'Industrial Building', AccountId = Acc.id, Start_Date__c = System.today(), CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        insert unit1;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntryStd;
        
        
        ApexPages.currentPage().getParameters().put('OpportunityId', opp.id);
        ctrl_REProductSelection Rsel = new ctrl_REProductSelection();
        Rsel.ProductType.add('Industrial Building');
        
        for(ctrl_REProductSelection.Wrapper item: Rsel.searchResult){
            item.isSelected = true;
        }
        Rsel.updateOpp();
        Rsel.addProduct();
        Rsel.updateOpportunity();
        Rsel.searchDetails();
        Rsel.first();
        Rsel.next();
        Rsel.previous();
        Rsel.last();
        Rsel.clearSettings();
    }
    
    @isTest static void Four_ctrl_TCProductSelectionTest(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Tenancy_Contract__C Oldtc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert Oldtc;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = OldTc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Renewed_Contract__c = Oldtc.Id);
        Insert tc;
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        ApexPages.currentPage().getParameters().put('TenancyContractId', tc.id);
        ctrl_TCProductSelection Tsel = new ctrl_TCProductSelection();
        
        Tsel.ProductType.add('Industrial Building');
        for(ctrl_TCProductSelection.Wrapper item: Tsel.searchResult){
            item.isSelected = true;
        }
        Tsel.updateOpp();
        Tsel.addProduct();
        Tsel.updateOpportunity();
        Tsel.first();
        Tsel.next();
        Tsel.previous();
        Tsel.last();
        Tsel.clearSettings();   
    }
    
    @isTest static void Five_ctrl_QuoteReservationAgreementTest(){
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        ctrl_QuoteReservationAgreement QR = new ctrl_QuoteReservationAgreement(sc);
        
        
        QR.res_number = 'ee';
        QR.anticipateddate = System.Today();
        QR.amount = 454;
        QR.sent = False;
        QR.signed = False;
        Qr.received = False;
        QR.saveReservation();
    }
    
    @isTest Static void cls_InvoiceGenerationTest(){
         Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        Tenancy_Contract__C Oldtc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert Oldtc;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = OldTc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Lease_Commencement_Date__c= system.today(), Contract_Duration__c = 4, Renewed_Contract__c = Oldtc.Id);
        Insert tc;
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        Tenancy_Contract_Payment__c tcp1 = new Tenancy_Contract_Payment__c(Tenancy_Contract_Line_Item__c = cli.Id ,Tenancy_Contract__c = tc.Id, paid__c = false, Related_to_Offer_Proposal__c = pp.Id, Payment_Name__c = 'Payment 1', Due_Date_To__c = system.today(), Payment_Amount__c = 10000, isSecurityDeposit__c = false, isServiceCharge__c = false, YearNumber__c = '1');
        insert tcp1;
        Tenancy_Contract_Payment__c tcp2 = new Tenancy_Contract_Payment__c(Tenancy_Contract_Line_Item__c = cli.Id ,Tenancy_Contract__c = tc.Id, paid__c = false, Related_to_Offer_Proposal__c = pp.Id, Payment_Name__c = 'Payment 2', Due_Date_To__c = system.today(), Payment_Amount__c = 50000, isSecurityDeposit__c = true, isServiceCharge__c = false, YearNumber__c = '1');
        insert tcp2;
        Tenancy_Contract_Payment__c tcp3 = new Tenancy_Contract_Payment__c(Tenancy_Contract_Line_Item__c = cli.Id ,Tenancy_Contract__c = tc.Id, paid__c = false, Related_to_Offer_Proposal__c = pp.Id, Payment_Name__c = 'Payment 3', Due_Date_To__c = system.today(), Payment_Amount__c = 100000, isSecurityDeposit__c = false, isServiceCharge__c = true, YearNumber__c = '1');
        insert tcp3;
        
        ApexPages.currentPage().getParameters().put('TenancyContractId', tc.id);
        cls_InvoiceGeneration CIG = new cls_InvoiceGeneration();
        CIG.getContractYears();
        for(cls_InvoiceGeneration.paymentWrapper item : cig.paymentList){
            item.isSelected = true;
        }
        cig.Generate_Invoice();
        cig.Cancel();
    }
    
    @isTest Static void cls_InvoiceGenerationTest2(){
         Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        Tenancy_Contract__C Oldtc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4);
        Insert Oldtc;
        
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = OldTc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Lease_Commencement_Date__c= system.today(), Contract_Duration__c = 4, Renewed_Contract__c = Oldtc.Id);
        Insert tc;
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;

        Tenancy_Contract_Payment__c tcp4 = new Tenancy_Contract_Payment__c(ReadOnly__c =false ,Tenancy_Contract_Line_Item__c = cli.Id ,Tenancy_Contract__c = tc.Id, paid__c = false, Related_to_Offer_Proposal__c = pp.Id, Payment_Name__c = 'Payment 3', Due_Date_To__c = system.today(), Payment_Amount__c = 100000, isSecurityDeposit__c = false, isServiceCharge__c = true, YearNumber__c = '1');
        insert tcp4;
        delete tcp4;
    }
    
    @isTest Static void cls_InvoiceGenerationTest3(){
         Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Lease_Commencement_Date__c= system.today(), Contract_Duration__c = 4);
        Insert tc;
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = tc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        cli.Quantity__c =100;
        update cli;
    }
    
    @isTest static void cls_ContractAttachmentsTest(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        Service_Name__c servName = new Service_Name__c(Name= 'Standard Lease');
        insert servName;
        Services__c service = new Services__c(Contract_Documents_Name__c = servName.Id);
        insert service;
        Service_Documents_CheckList__c sdc = new Service_Documents_CheckList__c(doc_Name__c = 'Test',Name = 'Test', services__c = service.Id);
        insert sdc;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        
        tc.Status__c = 'Active' ;
        update tc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(tc);
        ApexPages.currentPage().getParameters().put('Id', tc.id);
        cls_ContractAttachments CA = new cls_ContractAttachments(sc);
        CA.customerDocs = [select Id from contract_documents__c where tenancy_contract__c = :tc.Id];
        Attachment att = new Attachment(name = 'text.txt', ParentId = CA.customerDocs[0].Id, body = Blob.valueOf('test.txt'));
        insert att;
        CA.attachmentId = att.Id;
        CA.fileBody = 'test';
        CA.FileName='test';
        CA.parentId = CA.customerDocs[0].Id;
        CA.useNewFile();
        CA.save();
        CA.deleteAttachmentFile();
        
    }
    
    @isTest static void cls_CommunityTCTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        user u = new User();
        u.Username = c.email;
        u.Email = c.email;
        u.FirstName = c.firstname;
        if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
        else u.LastName = c.Lastname;
        u.CommunityNickname = c.FirstName.subString(0,2) + u.LastName;
        u.ContactId = c.Id;
        u.ProfileId = p.Id;
        u.Alias = c.firstname.substring(0,1) + u.LastName;
        if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
        u.EmailEncodingKey = 'UTF-8';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.DefaultCurrencyIsoCode = 'AED';
        u.TimeZoneSidKey = 'Asia/Dubai';  
        insert u;
        acc.user__c = u.Id;
        update acc;
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, status__c = 'Active');
        Insert tc;
        
        system.runAs(u){
            cls_CommunityTC cTC = new cls_CommunityTC();
        }
        test.stopTest();
    }
    
    @isTest static void cls_CommunityTCDetailsTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        user u = new User();
        u.Username = c.email;
        u.Email = c.email;
        u.FirstName = c.firstname;
        if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
        else u.LastName = c.Lastname;
        u.CommunityNickname = c.FirstName.subString(0,2) + u.LastName;
        u.ContactId = c.Id;
        u.ProfileId = p.Id;
        u.Alias = c.firstname.substring(0,1) + u.LastName;
        if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
        u.EmailEncodingKey = 'UTF-8';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.DefaultCurrencyIsoCode = 'AED';
        u.TimeZoneSidKey = 'Asia/Dubai';  
        insert u;
        acc.user__c = u.Id;
        update acc;
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Service_Name__c servName = new Service_Name__c(Name= 'Standard Lease');
        insert servName;
        Services__c service = new Services__c(Contract_Documents_Name__c = servName.Id);
        
        insert service;
        Service_Documents_CheckList__c sdc = new Service_Documents_CheckList__c(doc_Name__c = 'Test',Name = 'Test', services__c = service.Id);
        insert sdc;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, status__c = 'Draft');
        Insert tc;
        tc.Status__c = 'Active';
        update tc;
        Invoice__c invoice = new Invoice__c(name = 'test', Received_From__c = acc.Id, tenancy_contract__c = tc.Id);
        insert invoice;
        Attachment att = new Attachment(name = 'text.txt', ParentId = invoice.Id, body = Blob.valueOf('test.txt'));
        Insert att;
        
        system.runAs(u){
            ApexPages.currentPage().getParameters().put('TenancyContractId', tc.id);
            cls_CommunityTCDetails tcd = new cls_CommunityTCDetails();
            att = new Attachment(name = 'text.txt', ParentId = tcd.customerDocs[0].Id, body = Blob.valueOf('test.txt'));
            insert att;
            tcd.attachmentId = att.Id;
            tcd.fileBody = 'test';
            tcd.FileName='test';
            tcd.parentId = tcd.customerDocs[0].Id;
            tcd.useNewFile();
            tcd.saveDocument();
            tcd.deleteAttachmentFile();
            tcd.docId = tcd.customerDocs[0].Id;
            tcd.submitDoc();
        }
        test.stopTest();
    }
    
    @isTest static void cls_CommunityCasesTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        user u = new User();
        u.Username = c.email;
        u.Email = c.email;
        u.FirstName = c.firstname;
        if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
        else u.LastName = c.Lastname;
        u.CommunityNickname = c.FirstName.subString(0,2) + u.LastName;
        u.ContactId = c.Id;
        u.ProfileId = p.Id;
        u.Alias = c.firstname.substring(0,1) + u.LastName;
        if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
        u.EmailEncodingKey = 'UTF-8';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.DefaultCurrencyIsoCode = 'AED';
        u.TimeZoneSidKey = 'Asia/Dubai';  
        insert u;
        acc.user__c = u.Id;
        update acc;
        
        Case caseObj = new case(account = acc, contact = c, status='New', Origin='web');
        insert caseObj;
        
        system.runAs(u){
            cls_CommunityCases cTC = new cls_CommunityCases();
            cTc.getAccountCasses();
            cTc.getTotalPages();
            cTc.Beginning();
            ctc.Next();
            ctc.Previous();
            ctc.End();
            ctc.getDisableNext();
            ctc.getDisablePrevious();
            ctc.getTotal_size();
            ctc.getPageNumber();
            cTc.redirectNewCase();
        }
        test.stopTest();
    }
    
    @isTest static void cls_CommunityCaseLayoutTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        user u = new User();
        u.Username = c.email;
        u.Email = c.email;
        u.FirstName = c.firstname;
        if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
        else u.LastName = c.Lastname;
        u.CommunityNickname = c.FirstName.subString(0,2) + u.LastName;
        u.ContactId = c.Id;
        u.ProfileId = p.Id;
        u.Alias = c.firstname.substring(0,1) + u.LastName;
        if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
        u.EmailEncodingKey = 'UTF-8';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.DefaultCurrencyIsoCode = 'AED';
        u.TimeZoneSidKey = 'Asia/Dubai';  
        insert u;
        acc.user__c = u.Id;
        update acc;
        
        Case caseObj = new case(account = acc, contact = c, status='New', Origin='web');
        insert caseObj;
        
        system.runAs(u){
            ApexPages.currentPage().getParameters().put('CaseId', caseObj.id);
            cls_CommunityCaseLayout cTC = new cls_CommunityCaseLayout();
            cTc.redirectCaseList();
        }
        test.stopTest();
    }
    
    @isTest static void cls_CommunityCreateCaseTest(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact c = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert c;   
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        user u = new User();
        u.Username = c.email;
        u.Email = c.email;
        u.FirstName = c.firstname;
        if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
        else u.LastName = c.Lastname;
        u.CommunityNickname = c.FirstName.subString(0,2) + u.LastName;
        u.ContactId = c.Id;
        u.ProfileId = p.Id;
        u.Alias = c.firstname.substring(0,1) + u.LastName;
        if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
        u.EmailEncodingKey = 'UTF-8';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.DefaultCurrencyIsoCode = 'AED';
        u.TimeZoneSidKey = 'Asia/Dubai';  
        insert u;
        acc.user__c = u.Id;
        update acc;
        
        Case caseObj = new case(account = acc, contact = c, status='New', Origin='web');
        insert caseObj;
        
        system.runAs(u){
            cls_CommunityCreateCase cTC = new cls_CommunityCreateCase();
            ctc.getTC();
            ctc.getUnits();
            //ctc.saveCase();
            ctc.showMessage();
            cTc.redirectCaseList();
        }
        test.stopTest();
    }
    
    @isTest Static void cls_editInvoiceLineItemsTest(){
         Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        Payment_Plan__c pp1 = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp1;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Quote__c = q.Id, Account__c = Acc.Id, Lease_Commencement_Date__c= system.today(), Contract_Duration__c = 4);
        Insert tc;
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = tc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        cli.Quantity__c =100;
        update cli;
        
        Tenancy_Contract_Payment__c tcp = new Tenancy_Contract_Payment__c(Tenancy_Contract_Line_Item__c = cli.Id ,Tenancy_Contract__c = tc.Id, paid__c = false, Related_to_Offer_Proposal__c = pp.Id, Payment_Name__c = 'Payment 1', Due_Date_To__c = system.today(), Payment_Amount__c = 10000, isSecurityDeposit__c = false, isServiceCharge__c = false, YearNumber__c = '1');
        insert tcp;
        
        Invoice__c inv = new Invoice__c();
        inv.Related_To_Quote__c = q.Id;
        inv.Received_From__c = acc.Id;
        inv.Tenancy_Contract__c = tc.Id;
        insert inv;
        
        Invoice_Line_Item__c invLI = new Invoice_Line_Item__c(Invoice__c = inv.Id, amount__c = 5000, Offer_Payments__c = pp.Id, Quantity__c = 50, RC_Unit__c = unit1.Id, Related_to_Registration__c = acc.Id, Tenancy_Contract_Payment__c = tcp.Id, Unit_Price__c = 100);
        insert invLI;
        
        ApexPages.currentPage().getParameters().put('InvoiceId', inv.id);
        cls_editInvoiceLineItems eILI = new cls_editInvoiceLineItems();
        eILI.Generate_Invoice();
        eILI.Cancel();
    }
}