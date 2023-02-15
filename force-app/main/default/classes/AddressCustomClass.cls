global class AddressCustomClass {
    public String country { get; set; }
    public String state { get; set; }
    public String city { get; set; }
    public String street { get; set; }
    public String postalCode { get; set; }
    public String geocodeAccuracy { get; set; }
    public Decimal latitude { get; set; }
    public Decimal longitude { get; set; }
    
    public AddressCustomClass(Address address) {
        this.country = address.country;
        this.state = address.state;
        this.city = address.city;
        this.street = address.street;
        this.postalCode = address.postalCode;
        this.geocodeAccuracy = address.geocodeAccuracy;
        this.latitude = address.latitude;
        this.longitude = address.longitude;
	}
}