global class invoiceHelperClass {
	WebService static String postInvoice(ID invoiceId)
    {
        Savepoint sp;
        sp = Database.setSavepoint();
        try
        { 
            Invoice__c Invoice = [Select Id, Posted__c , Status__c , Posted_Date_Time__c From Invoice__c Where id = :invoiceId];
            Invoice.Posted__c = true;
            Invoice.Status__c = 'Posted';
            Invoice.Posted_Date_Time__c = system.now();
            upsert Invoice ;
            
            return 'Success' ; 
            
        }catch(Exception e){system.debug(e); Database.rollback(sp); String errorMsg = 'error : ' + e ;return errorMsg ;
        }
    }
    
    
    WebService static String generateServiceRequestReceipt(ID invoiceId)
    {
        Savepoint sp;
        sp = Database.setSavepoint();
        try
        { 
            //Get Invoice Details
            Invoice__c obj = [select Description__c, Amount__c , Receipt__c , Received_From__c , Name, Related_To_Quote__c, Payment_Method__C, Payment_Reference__c	from Invoice__c where id = : invoiceId] ;
        
            //New Receipt Object
            Receipt__c rec = new Receipt__c(Invoice__c = obj.Id,Name = obj.Name, Date_Received__c = system.today() 
                                            , Description__c = obj.Description__c  , Received_From__c = obj.Received_From__c,
                                           Amount__c = obj.Amount__c, Related_to_Offer__c = obj.Related_To_Quote__c , Payment_Method__C = obj.Payment_Method__C,
                                           Related_to_Quote__c = obj.Related_To_Quote__c, Related_to_Registration__c = obj.Received_From__c, 
                                           Reference_Number__c = string.ValueOf(obj.Payment_Reference__c));
            insert rec ;
        
            //Update Invoice with the Newly Created Receipt
            obj.Receipt__c = rec.id ;
            update obj ;
            approval.lock(rec, false);
            List<Receipt_Line_Items__c> recLineItem = new List<Receipt_Line_Items__c>();
            for(Invoice_Line_Item__c item : [select Invoice__c, Amount__c, Service__c, Description__c from Invoice_Line_Item__c where Invoice__c = : obj.id]){
                Receipt_Line_Items__c recLine = new Receipt_Line_Items__c(Invoice__c = item.Invoice__c, description__c = item.Description__c, Payment_Method__c = obj.Payment_Method__C ,Service__c = item.Service__c , Receipt__c = rec.id , Amount_Received__c = item.Amount__c);
                recLineItem.add(recLine);
            }
            
            if(recLineItem.size() > 0){ 
                insert recLineItem;
                approval.lock(recLineItem, false);
            }
            
            return rec.id ; 
            
        }catch(Exception e){system.debug(e); 
                            Database.rollback(sp); 
                            String errorMsg = 'error : ' + e.getMessage() ;
                            return errorMsg ;
        }
    }
}