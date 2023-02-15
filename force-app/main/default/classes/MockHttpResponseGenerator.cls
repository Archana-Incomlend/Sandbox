@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    public String resbody;
    public integer status;

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resbody);
        res.setStatusCode(status == null ? 200 : status);
        return res;
    }
    
    public MockHttpResponseGenerator(){
        resbody = '{"result":"OK"}';
    }
    
    public MockHttpResponseGenerator(String ccy){
        resbody = '{"' + ccy + '":10}';
    }

    public MockHttpResponseGenerator(String ccy, boolean isRate){
        resbody = '{"' + ccy + '":10}';
        if (isRate) {
            resbody = '{ "rates": { "' + ccy + '": 1 } }';
        }
    }

    public MockHttpResponseGenerator(integer status, String response) {
        this.status = status;
        this.resbody = response;
    }

}