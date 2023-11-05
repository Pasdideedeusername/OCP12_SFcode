@RestResource(urlMapping='/Contract/*')
global with sharing class ContractRestResource {
    
    /**
    * Crée un ou plusieurs contrats en utilisant une requête HTTP POST.
    * Cette méthode récupère les informations de la demande HTTP entrante, y compris les données JSON contenant les détails des contrats à créer.
    * Elle valide et traite les données, puis crée les contrats correspondants dans Salesforce. Elle renvoie une liste d'informations sur les contrats créés,
    * y compris leur ID et l'ID du compte associé.
    *
    * @return Une liste de mappages contenant les informations des contrats créés.
    */
   
    @HttpPost
    global static List<Map<String, String>> createContract() {
        //récupère la demande (request) HTTP entrante
        RestRequest request = RestContext.request;
        // désérialise le corps de la demande JSON en utilisant la méthode JSON.deserializeUntyped pour obtenir les paires nom-valeur.
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        System.debug(params);
        List<Object> enregistrements =(List<Object>) params.get('records');
        System.debug(enregistrements);
        // Crée une liste de contacts à mettre à jour en dehors de la boucle
        List<Contract> contractsToCreate = new List<Contract>();
        
        for (Object enr : enregistrements){
            Map<String, Object> attributDesenregistrements = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(enr));
            
            Contract contract= new Contract(); 

            // itère à travers chaque champ et sa valeur dans les données JSON
            for (String fieldName : attributDesenregistrements.keySet()) {
                Object fieldValue = attributDesenregistrements.get(fieldName);
                if (fieldValue instanceof String && fieldName == 'StartDate') {
                    // Si le champ est "StartDate" et sa valeur est une chaîne, convertissez-la en Date.
                    contract.put(fieldName, Date.valueOf((String) fieldValue));
                } else if (fieldValue instanceof String && fieldName == 'ContractTerm') {
                    // Si le champ est "ContractTerm" et sa valeur est une chaîne, convertissez-la en entier.
                    contract.put(fieldName, Integer.valueOf((String) fieldValue));
                } else {
                    contract.put(fieldName, fieldValue);
                }
            }
            
            
            // Ajoute le contact à la liste des contacts à créer
            contractsToCreate.add(contract);
        }
               
        // Crée les contrats dans Salesforce
        insert contractsToCreate;

        // Crée une liste pour stocker les informations des contrats mis à jour
        List<Map<String, String>> createdContractsInfo = new List<Map<String, String>>();

        // Récupère les informations d'Id et le client des contrats mis à jour
        for (Contract createdContract : contractsToCreate) {
            Map<String, String> contractInfo = new Map<String, String>();
            contractInfo.put('Id', createdContract.Id); 
            contractInfo.put('AccountId', createdContract.AccountId);
            createdContractsInfo.add(contractInfo);
        }

        return createdContractsInfo;
    }
    
    /** 
    * Cette méthode met à jour les champs d'un contrat existant en utilisant une requête HTTP PATCH.
    *  récupère les informations de la demande HTTP entrante, y compris l'ID du contrat à mettre à jour et les données JSON
    * contenant les nouvelles valeurs des champs. Elle effectue ensuite la mise à jour des champs du contrat et enregistre les modifications
    * dans Salesforce.
    * 
    * Cette méthode n'est pas "bulkifiée" contraiterement au reste du code de cette application du projet 12, l'ojectif étant ici de voir une autre façon d'utiliser
    * en utilisant l'Id de l'objet directement dans l'URI
    */
    @HttpPatch
    global static void updateContractFields() {
        //récupère la demande (request) HTTP entrante
        RestRequest request = RestContext.request;
        //extrait l'ID du contrat à partir de l'URI de la demande en utilisant la méthode substring
        String contractId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/') + 1);
        //requête SOQL pour récupérer le contrat correspondant à l'ID
        Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId]; 
        
        // désérialise le corps de la demande JSON en utilisant la méthode JSON.deserializeUntyped pour obtenir les paires nom-valeur.
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        
        // itère à travers chaque champ et sa valeur dans les données JSON
        for (String fieldName : params.keySet()) {
            // met à jour les champs du contact en utilisant les valeurs fournies dans les données JSON
            thisContract.put(fieldName, params.get(fieldName));
        }
        
        update thisContract;
    }

}