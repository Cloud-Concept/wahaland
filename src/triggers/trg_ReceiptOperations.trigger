trigger trg_ReceiptOperations on Receipt__c (before insert, before update) {
    
    for(Receipt__c item:Trigger.New){
        if(item.Total_Amount_Received__c != null){
            long amount = (long)(item.Total_Amount_Received__c);
            item.AmountWords__c = NumberToWord.english_number(amount);
        }
    }

}