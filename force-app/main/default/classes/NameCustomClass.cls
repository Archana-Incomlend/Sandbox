global class NameCustomClass {	
    public String salutation { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    
    public NameCustomClass(String salutation, String firstName, String lastName) {
        this.salutation = salutation;
        this.firstName = firstName;
        this.lastName = lastName;
	}
}