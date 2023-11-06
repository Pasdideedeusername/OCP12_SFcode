@isTest
private class ContractRestResourceTest {

    @isTest
    static void testCreateContract() {
        // Crée un compte de test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // objet de demande HTTP factice pour simuler l'appel REST
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Utilise l'ID du compte de test dans la demande de test
        String requestBody = '{ "records" : [ { "AccountId" : "' + testAccount.Id + '", "StartDate" : "2023-11-05", "ContractTerm" : "3" } ] }';
        request.requestURI = '/services/apexrest/Contract/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Appelle la méthode createContract de la classe ContractRestResource
        test.startTest();
        List<Map<String, String>> result = ContractRestResource.createContract();
        test.stopTest();

        // Vérifie que la réponse est correcte
        System.assertEquals(1, result.size());
        Map<String, String> contractInfo = result[0];
        System.assertEquals(testAccount.Id, contractInfo.get('AccountId'));

    }
  
    @isTest
    static void testUpdateContractFields() {
        // Crée un compte et un contrat de test
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contract testContract = new Contract(AccountId = testAccount.Id);
        insert testContract;

        // Crée un objet de demande HTTP factice pour simuler l'appel REST
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Utilise l'ID du contrat de test dans l'URI de la demande
        request.requestURI = '/services/apexrest/Contract/' + testContract.Id;
        request.httpMethod = 'PATCH';

        // Corps de la demande JSON avec les données de mise à jour
        String requestBody = '{ "Name" : "Nouveau Nom", "Status" : "Activated" }';
        request.requestBody = Blob.valueOf(requestBody);

        // Appelle la méthode updateContractFields de la classe ContractRestResource
        test.startTest();
        ContractRestResource.updateContractFields();
        test.stopTest();

        // Vérifie que le contrat a été mis à jour correctement
        Contract updatedContract = [SELECT Name, Status FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals('Nouveau Nom', updatedContract.Name);
        System.assertEquals('Activated', updatedContract.Status);

    }
}
