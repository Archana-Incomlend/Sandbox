@isTest
public class ListViewControllerTest {

    private class RestMock implements HttpCalloutMock {
        integer status {get; set;}
        String response {get; set;}
        
        RestMock(integer status, String response) {
            this.status = status;
            this.response = response;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(response);
            res.setStatusCode(status);
            return res;
        }
    }

    private static Account init() {
        Map<String, Object> result = new Map<String, Object>();
        Account currentAccount = SeedTest.createAccount(result, 'Mel', 'Supplier');
        insert currentAccount;
        return currentAccount;
    }
    
    private static void runTest(ListViewController controller) {
        Test.startTest();
        controller.downloadInit();
        controller.close();
        Test.stopTest();
    }

    @isTest
    private static void TestDownloadDocumentSingle(){
 
        Account currentAccount = init();
        ApexPages.StandardController stdController = new ApexPages.StandardController(currentAccount);        
        PageReference pageRef = Page.DownloadAttachmentAccountView; 
        Test.setCurrentPage(pageRef);
        ListViewController controller = new ListViewController(stdController);

        Test.setMock(HttpCalloutMock.class, new RestMock(200, 'abc'));
        runTest(controller);
    }

    @isTest
    private static void TestDownloadDocumentSingle1(){
 
        Account currentAccount = init();
        ApexPages.StandardController stdController = new ApexPages.StandardController(currentAccount);        
        PageReference pageRef = Page.DownloadAttachmentAccountView; 
        Test.setCurrentPage(pageRef);
        ListViewController controller = new ListViewController(stdController);
        Test.setMock(HttpCalloutMock.class, new RestMock(500, 'abc'));
        runTest(controller);
    }

    @isTest
    private static void TestDownloadDocumentSingle2(){
 
        Account currentAccount = init();
        ApexPages.StandardController stdController = new ApexPages.StandardController(currentAccount);        
        PageReference pageRef = Page.DownloadAttachmentAccountView; 
        Test.setCurrentPage(pageRef);
        ListViewController controller = new ListViewController(stdController);
        Test.setMock(HttpCalloutMock.class, new RestMock(500, 'CalloutException: Exceeded max size limit of 6000000'));
        runTest(controller);
    }

    @isTest
    private static void TestDownloadAttachmentSet(){
        
        Account currentAccount = init();
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(new List<Account> {currentAccount });        
        PageReference pageRef = Page.DownloadAttachmentAccountListView; 
        Test.setCurrentPage(pageRef);
        stdController.setSelected(new List<Account> {currentAccount});
        ListViewController controller = new ListViewController(stdController);

        Test.setMock(HttpCalloutMock.class, new RestMock(200, 'abc'));
        runTest(controller);
        controller.downloadAll();
    }

}