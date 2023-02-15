@RestResource(urlMapping='/v9.2/Contact/*')

global with sharing class RestContactData_v9_2 {
	@HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods_v9.isValidId(p_contactId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid contact ID')));
        } else {

            List<Contact> v_result = new List<Contact> ();
            String v_listQuery = 'SELECT Id, Name, Salutation, FirstName, LastName, Email, MobilePhone, AccountId, Title, relationship_to_account__c FROM Contact WHERE Id = :p_contactId AND IsDeleted = false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid user contact id')));
            } else {
                ContactCustomClass contact = new ContactCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(contact));
                res.statusCode = 200;
            }
        }
    }
}