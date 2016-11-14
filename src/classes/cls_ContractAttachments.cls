public class cls_ContractAttachments {
    
    public Boolean refreshPage {get;set;}
    public List<contract_documents__c> customerDocs {get;set;}
    public id recId {get;set;}
    public id parentId {get;set;}
    public id attachmentId {get;set;}
    public String fileName {get;set;}
    public transient String fileBody {get;set;}
    List <Service_Documents_CheckList__c> serviceDocs;
    Tenancy_Contract__c Contract;
    public cls_ContractAttachments(ApexPages.StandardController stdController) {
        if(ApexPages.CurrentPage().getParameters().get('id') != null){
            recId = ApexPages.CurrentPage().getParameters().get('id') ;
            prepareQuery();
        }
    }
    
    public void prepareQuery(){
        customerDocs = [select id , Doc_Name__c, name , Uploaded__c , Verified__c , doc_type__c, Attachment_Id__c , submitted__c
                        from contract_documents__c where Tenancy_Contract__c = : recId] ;
    }
    public id attId {get;set;}
    public PageReference useNewFile(){
        Attachment att = new Attachment(ParentId = parentId , Name = fileName , body = EncodingUtil.base64Decode(fileBody));
        insert att ;
        
        List<contract_documents__c> docs = [select id , uploaded__c, name , Attachment_Id__c , verified__c from contract_documents__c where id = :parentId];
        if(docs.size() > 0 ){
            docs[0].Attachment_Id__c = att.id ;
            docs[0].Uploaded__c = true;
            docs[0].Uploaded_by__c = UserInfo.getUserId();
            upsert docs[0] ;
        }
        attId= att.id ;
        refreshPage = true ;       
        return null ;
    }
    public pageReference save(){
        update customerDocs;
        refreshPage = true ; 
        return null;
    }
    public PageReference deleteAttachmentFile(){
        List<Attachment> attList = [SELECT id, parentId FROM Attachment WHERE Id = :attachmentId Limit 1];
        if(attList.size()>0){
            attachment att = attList[0];
            try{
                delete att;
                contract_documents__c doc = new contract_documents__c(id=att.ParentId);
                doc.Attachment_Id__c = '';
                doc.Uploaded__c = FALSE;
                doc.Submitted__c = false;
                doc.DeletedSF__c = True;
                update doc;
                for(contract_documents__c deletedDoc: customerDocs){
                    if(deletedDoc.Id == att.ParentId){
                        deletedDoc.Uploaded__c = FALSE;
                        deletedDoc.Attachment_Id__c = '';
                        deletedDoc.submitted__c = false;
                        deletedDoc.DeletedSF__c = True;
                    }
                }
            } catch(Exception e){
                system.debug('System Error, Failed to delete attachment with ID: ' + attachmentId + ' with error message ' + e.getMessage());
            }
        }
        return NULL;
    }
}