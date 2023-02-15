global class ContactCustomClass {
    public String id { get; set; }
    public NameCustomClass name { get; set; }
    public String email { get; set; }
    public String mobilePhone { get; set; }
    public String accountId { get; set; }
    public String title { get; set; }
    public List<String> relationshipToAccount { get; set; }
    
    public ContactCustomClass(Contact contact) {
        this.id = contact.Id;
        this.name = new NameCustomClass(contact.Salutation, contact.FirstName, contact.LastName);
        this.email = contact.Email;
        this.mobilePhone = contact.MobilePhone;
        this.accountId = contact.AccountId;
        this.title = contact.Title;
        if (contact.relationship_to_account__c != null && contact.relationship_to_account__c != '') {
        	this.relationshipToAccount = contact.relationship_to_account__c.split(';');
        }
	}

}