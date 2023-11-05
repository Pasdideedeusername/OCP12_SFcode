@isTest
private class ContactRestRessourceTest {

    @isTest
    static void testUpdateContactFields() {
        // Crée des données de test 
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(ExternalId__c = 'test' + i + '@test.com' , LastName = 'Contact' + i);
            testContacts.add(c);
        }
        insert testContacts;
        system.debug('liste des contacts à leur création' +testContacts);


        // Crée des données JSON de test pour la méthode updateContactFields.
        String jsonRequestBody = '{"records": [{"ExternalId__c": "test0@test.com","LastName": "Updated Contact0"},{"ExternalId__c": "testX@test.com","LastName": "Created ContactX"}]}';

        // Crée une requête HTTP avec les données JSON.
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://ocp12-dev-ed.develop.my.salesforce.com/services/apexrest/Contact/'); 
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonRequestBody);

        // Crée une instance de System.RestRequest basée sur l'objet System.HttpRequest
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = request.getEndpoint();
        restRequest.httpMethod = request.getMethod();
        restRequest.requestBody = Blob.valueOf(request.getBody());
        RestContext.request = restRequest;

        // Appelle la méthode de la classe ContactRestRessource
        Test.startTest();
        ContactRestRessource.updateContactFields();
        Test.stopTest();

        // Vérifie que les contacts ont été modifiés/créés comme prévu en consultant la base de données.
        List<Contact> updatedContacts = [SELECT Id, LastName, ExternalId__c FROM Contact WHERE ExternalId__c IN ('test0@test.com', 'testx@test.com')];

        System.assertEquals('Updated Contact0', updatedContacts[0].LastName);
        System.assertEquals('Created ContactX', updatedContacts[1].LastName);
    }

    @isTest
    static void testDeletedContactWillBeDeactivated() {

        // Crée des données de test 
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(ExternalId__c = 'test' + i + '@test.com' , LastName = 'Contact' + i , IsActive__c = true);
            testContacts.add(c);
        }
        insert testContacts;

        // Crée des données JSON de test pour la méthode TestDeletedContactWillBeDeactivated.
        String jsonRequestBody = '{"records": [{"ExternalId__c": "test0@test.com"},{"ExternalId__c": "test1@test.com"}]}';

        // Crée une requête HTTP avec les données JSON.
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://ocp12-dev-ed.develop.my.salesforce.com/services/apexrest/Contact/'); 
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonRequestBody);

        // Crée une instance de System.RestRequest basée sur l'objet System.HttpRequest
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = request.getEndpoint();
        restRequest.httpMethod = request.getMethod();
        restRequest.requestBody = Blob.valueOf(request.getBody());
        RestContext.request = restRequest;

        // Appelle la méthode de la classe ContactRestRessource
        Test.startTest();
        ContactRestRessource.deletedContactWillBeDeactivated();
        Test.stopTest();

        // Vérifie que les contacts ont été désactivés comme prévu en consultant la base de données.
        List<Contact> deletedContacts = [SELECT Id, IsActive__c, ExternalId__c FROM Contact];

        System.assertEquals(false, deletedContacts[0].IsActive__c);
        System.assertEquals(false, deletedContacts[1].IsActive__c);
        System.assertEquals(true, deletedContacts[2].IsActive__c);
    }
}
