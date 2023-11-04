@RestResource(urlMapping='/Contact/*')
global with sharing class ContactRestRessource {

    /* inutile car le put fait aussi la création de commptes
     
    @HttpPost // bulkifier comme apres
    global static Id createContact(String email, String name) {
        System.debug(RestContext.request.requestBody);
        // Recherche du contact existant avec l'email donné dans le champ ExternalId
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE ExternalId__c = :email LIMIT 1];

        if (existingContacts.isEmpty()) {
            // crée le contact s'il n'existe pas déjà
            Contact newContact = new Contact(ExternalId__c = email, Email = email, LastName = name);
            newContact.ExternalId__c = email; // Utilisation du champ ExternalId__c pour l'email
            // On ppourra ajouter d'autres champs ici en fonction des informations fournies par le CRM AXG

            // Insère le nouveau contact dans Salesforce
            insert newContact;
            // retourne l'Id du nouveau contact 
            return newContact.Id;
        } else{
            //sinon retourne l'Id du contact existant
            Contact existingContact = existingContacts[0];
            return existingContact.Id;
        }
    }
    */

    @HttpPut
    global static List<Map<String, String>> updateContactFields() {
        //récupère la demande (request) HTTP entrante
        RestRequest request = RestContext.request;
        // désérialise le corps de la demande JSON en utilisant la méthode JSON.deserializeUntyped pour obtenir les paires nom-valeur.
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        System.debug(params);
        List<Object> enregistrements =(List<Object>) params.get('records');
        System.debug(enregistrements);
        // Crée une liste de contacts à mettre à jour en dehors de la boucle
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Object enr : enregistrements){
            Map<String, Object> attributDesenregistrements = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(enr));
            
            Contact contact= new Contact(); 

            // itère à travers chaque champ et sa valeur dans les données JSON
            for (String fieldName : attributDesenregistrements.keySet()) {
                // met à jour les champs du contact en utilisant les valeurs fournies dans les données JSON
                contact.put(fieldName, attributDesenregistrements.get(fieldName));
            }
            
            // Ajoute le contact à la liste des contacts à mettre à jour
            contactsToUpdate.add(contact);
               
        }
               
        // Met à jour les contacts dans Salesforce
        upsert contactsToUpdate Contact.ExternalId__c;

        // Crée une liste pour stocker les informations des contacts mis à jour
        List<Map<String, String>> updatedContactsInfo = new List<Map<String, String>>();

        // Récupère les informations d'Id et ExternalId__c des contacts mis à jour
        for (Contact updatedContact : contactsToUpdate) {
            Map<String, String> contactInfo = new Map<String, String>();
            contactInfo.put('Id', updatedContact.Id);
            contactInfo.put('ExternalId__c', updatedContact.ExternalId__c);
            updatedContactsInfo.add(contactInfo);
        }

        return updatedContactsInfo;
    }
    /*
    le code assume ici qu'un champ custom IsActive est créé sur le contact Salesforce. 
    La logique d'utilisation de ce champ n'est pas considéré dans ce projet.
    */
    @HttpDelete 
    global static void deletedContactWillBeDeactivated() {
        //récupère la demande (request) HTTP entrante
        RestRequest request = RestContext.request;

// désérialise le corps de la demande JSON en utilisant la méthode JSON.deserializeUntyped pour obtenir les paires nom-valeur.
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        System.debug(params);
        List<Object> enregistrements =(List<Object>) params.get('records');
        System.debug(enregistrements);
        // Crée une liste de contacts à mettre à jour en dehors de la boucle
        List<Contact> contactsToDelete = new List<Contact>();
        
        for (Object enr : enregistrements){
            Map<String, Object> attributDesenregistrements = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(enr));
            
            Contact contact= new Contact(); 

            // itère à travers chaque champ et sa valeur dans les données JSON
            for (String fieldName : attributDesenregistrements.keySet()) {
                // met à jour les champs du contact en utilisant les valeurs fournies dans les données JSON
                contact.put(fieldName, attributDesenregistrements.get(fieldName));
                contact.IsActive__c = false;
            }
            
            // Ajoute le contact à la liste des contacts à mettre à jour
            contactsToDelete.add(contact);
               
        }
        upsert contactsToDelete Contact.ExternalId__c;
    
    /*    
        String ContactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id FROM Contact WHERE ExternalId__c = :ContactId];
        thisContact.IsActive__c = false;

        update thisContact;
    */    
    }     
}
