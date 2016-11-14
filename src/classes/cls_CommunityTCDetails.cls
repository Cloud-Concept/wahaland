public class cls_CommunityTCDetails {
    public Tenancy_Contract__c TCObject{get;set;}
    Public List<Contract_Line_item__c> cliList{get;set;}
    Public List<invoice__c> invoices{get;set;}
    Id TenancyContractId;
    Public string SignedBy{get;set;}
    Tenancy_Contract__c Contract;
    public Boolean refreshPage {get;set;}
    public List<contract_documents__c> customerDocs {get;set;}
    public id recId {get;set;}
    public id parentId {get;set;}
    public id attachmentId {get;set;}
    public String fileName {get;set;}
    public transient String fileBody {get;set;}
    public boolean isActive{get;set;}
    List <Service_Documents_CheckList__c> serviceDocs;
    public Id docId {get;set;}
    public List<Attachment> attachments{get;set;}
    public List<invoiceWrapper> invoicesWzAttachments{get;set;}
    public cls_CommunityTCDetails(){
        attachments = new List<Attachment>(); 
        invoicesWzAttachments = new List<invoiceWrapper>();
        Map<String , String> paramMap = new Map<String , String>();
        paramMap = ApexPages.currentPage().getParameters() ;
        if(paramMap.containsKey('TenancyContractId')) {
            TenancyContractId = paramMap.get('TenancyContractId') ;
            recId=TenancyContractId;
            TCObject = [select account__r.name, Renewed_Contract__r.Tenancy_Contract_Number__c, Customer_Signed_By__r.FirstName,
                        Customer_Signed_By__r.LastName, id, ownerid, isdeleted, name, currencyisocode, recordtypeid, createddate, createdbyid, 
                        lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate,
                        contract_number__c, account__c, quote__c, license_number__c, contract_type__c, first_line_item_unit_name__c, 
                        line_item_number__c, unit_names__c, total_contract_net_value__c, contract_duration__c, average_annual_net_rent__c, 
                        description__c, owner_expiration_notice_days__c, tenancy_contract__c, sms_tenant_mobile__c, sms_agent_mobile__c, 
                        actual_1st_year_rent__c, actual_1st_year_service_charges__c, customer_signed_by__c, primarycontactemail__c, 
                        activated_by__c, customer_signed_date__c, waha_signed_date__c, activated_date__c, unit_number__c, unit_area__c,
                        land_area__c, contact__c, authorized_waha_signatory__c, accountinitials__c, contract_expiry_date__c, number_of_installments__c, 
                        contract_duration_in_months__c, rent_free_period_days__c, rent_adjustment__c, rent_adjustment_arabic__c, total_rent_price__c, 
                        total_lease_price__c, service_charges_per_square_meter__c, grand_total__c, security_deposit__c, annual_service_charges_formula__c, 
                        annual_service_chargesformula__c, total_price__c, total_contract_value__c, special_conditions__c, renewed_contract__c, development_no__c, 
                        lease_commencement_date__c, term_commencement_date__c, term_expiry_date__c, rent_free_period__c, break_clause__c, cancellation_date_payment__c, 
                        termination_date__c, checked_out_report__c, status__c, number_of_years_for_service_charges__c, value_of_damages__c, tenancy_contract_number__c, 
                        service_charges__c, tawtheeq_fees__c, agreement_status__c, approval_status__c, tcpayments__c, khalifafund__c, cancellation_approval_status__c, 
                        unit_release_date__c, payments_cancellation_date__c, total_price_with_escalation_rate__c, rejectionsubmittingemail__c, 
                        canceledapprovalprocess__c, service_charges_dev__c, email__c, phone__c, fax__c, total_plot_area__c, total_service_area__c, 
                        total_un_serviced_area__c, releaseunitdateisempty__c, contract_end_date__c, submit_for_approval__c, payments_counter__c, 
                        approved_by_coo__c, submit_for_coo_approval__c, submit_for_finance_approval__c, approval_status_formula__c, 
                        template_selection_contract__c, kfund__c, contractexpiryisempty__c, guarantor_name__c, guarantor_address__c, guarantor_trade_name__c, 
                        reservation_amount__c, basic_service_charge__c, annual_year_rent__c, plot_reference__c
                        ,(SELECT Id, Name FROM Attachments where name like '%Contract%')
                        ,(select id,isdeleted,name,currencyisocode,createddate,createdbyid,lastmodifieddate,lastmodifiedbyid,systemmodstamp,lastactivitydate,contract__c,unitprice__c,quantity__c,total_rent_price__c,base_service_charges__c,annual_service_charges__c,annual_rent__c,annual_rent_formula__c,discount_description__c,line_item_description__c,quote_line_item__c,office_area__c,office_number__c,office_rent__c,unit__c,payment_plan_template__c,payments_count__c,product__c,product_code_list__c,reserved_or_leased_until__c,security_deposit__c,special_condition__c,special_condition_english__c,status__c,total_price__c,unit_availability__c,warehouse_area__c,warehouse_number__c,warehouse_rent__c,building_number__c,tcpayments__c,amountwzescalation__c,plot_area__c,service_area__c,unservice_area__c,unit_name__c,building__c,plot_land__c,plot_with_building_formula__c,unit_name_id_conga__c,unit_name_formula__c,readonly__c from Contract_Line_Items__r)
                        from Tenancy_Contract__c where Id = :TenancyContractId];
            isActive = false;
            if(TCObject.Status__c == 'Active'){
                isActive = true;
            }
            cliList = TCObject.Contract_Line_Items__r;
            invoices = [select id,isdeleted,name,currencyisocode,createddate,createdbyid,lastmodifieddate,lastmodifiedbyid,systemmodstamp,lastvieweddate,lastreferenceddate,received_from__c,related_to_quote__c,tenancy_contract__c,development_name__c,amount__c,description__c,posted__c,posted_date_time__c,posted_date__c,status__c,invoice_number__c,invoiceyear__c,receipt__c,payment_method__c,clearance_date__c,amount_paid__c,payment_reference__c,tenancy_contract_number__c,month_year_formula__c,tenancycontractnumber__c,due_date__c, (SELECT Id, Name FROM Attachments order by createdDate desc) from Invoice__c where Tenancy_Contract__c =:TenancyContractId];
            List<attachment> invAttachments = new List<attachment>();
            for(Invoice__c inv:invoices){
                invAttachments = inv.attachments;
                string attachmentname= '';
                Id attachementId;
                for(attachment attach:invAttachments){
                    if(attach.Name.Substring(0, attach.Name.indexOf('.')) == inv.Name.replace('/', '_')){
                        attachmentname = attach.Name;
                        attachementId = attach.Id;
                        break;
                    }
                }
                invoicesWzAttachments.add(new invoiceWrapper(inv.Id, inv.name, inv.Amount__c, inv.Due_Date__c, inv.Description__c, inv.Amount_Paid__c, attachementId, attachmentname));
            }
            SignedBy = TCObject.Customer_Signed_By__r.FirstName + ' ' + TCObject.Customer_Signed_By__r.LastName;
            attachments = TCObject.Attachments;
            prepareQuery();
        }
    }
    public void prepareQuery(){
      customerDocs = [select id , Doc_Name__c, name , Uploaded__c , Verified__c , doc_type__c, Attachment_Id__c, Submitted__c 
                          from contract_documents__c where Tenancy_Contract__c = : recId] ;
    }
    public id attId {get;set;}
    public PageReference useNewFile(){
       Attachment att = new Attachment(ParentId = parentId , Name = fileName , body = EncodingUtil.base64Decode(fileBody));
       insert att ;
       
       List<contract_documents__c> docs = [select id , uploaded__c, DeletedSF__c, name , Attachment_Id__c , verified__c, Submitted__c, Uploaded_by__c from contract_documents__c where id = :parentId];
       if(docs.size() > 0 ){
          docs[0].Attachment_Id__c = att.id ;
          docs[0].Uploaded__c = true;
          docs[0].Uploaded_by__c = UserInfo.getUserId();
          docs[0].DeletedSF__c = false;
          upsert docs[0] ;
       }
       attId= att.id ;
       refreshPage = true ;       
       return null ;
    }
    public pageReference saveDocument(){
        update customerDocs;
        refreshPage = true ;
        return null;
    }
    public PageReference deleteAttachmentFile(){
        List <Attachment> attList = [SELECT id, parentId FROM Attachment WHERE Id = :attachmentId Limit 1];
        if (attList.size() >0){
            Attachment att = attList[0];
        try{
            delete att;
            contract_documents__c doc = new contract_documents__c(id=att.ParentId);
            doc.Attachment_Id__c = '';
            doc.Uploaded__c = FALSE;
            update doc;
            for(contract_documents__c deletedDoc: customerDocs){
                if(deletedDoc.Id == att.ParentId){
                    deletedDoc.Uploaded__c = FALSE;
                    deletedDoc.Attachment_Id__c = '';
                }
            }
        } catch(Exception e){
            system.debug('System Error, Failed to delete attachment with ID: ' + attachmentId + ' with error message ' + e.getMessage());
        }
        }
        return NULL;
    }
    
    public pageReference submitDoc(){
        if (docId != null){
            for(contract_documents__c doc : customerDocs){
                if (doc.Id == docId){
                    doc.Submitted__c = true;
                }
            }
            update customerDocs;
        }
    
        return null;
    }
    
    public class invoiceWrapper{
        public string invName{get;set;}
        public Id InvId {get;set;}
        public Decimal Amount{get;set;}
        public Date Due_Date{get;set;}
        public string Description{get;set;}
        public boolean Amount_Paid{get;set;}
        public Id attachId{get;set;}
        public string attachName{get;set;}
        
        public invoiceWrapper(Id InvId, string invName, decimal Amount, Date Due_Date, string Description, boolean Amount_Paid, Id attachId, string attachName){
            this.InvId = InvId;
            this.invName = invName;
            this.amount = amount;
            this.Due_Date = Due_Date;
            this.Amount_Paid = Amount_Paid;
            this.Description = Description;
            this.attachId = attachId;
            this.attachName = attachName;
        }
    }
}