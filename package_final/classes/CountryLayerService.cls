public with sharing class CountryLayerService {

    @future(callout=true)
    public static void updateCountryLayerData() {
        try {
            // Send HTTP Request to external API
            HttpResponse response = sendHttpRequest();
            if (response != null && response.getStatusCode() == 200) {
                List<ExternalService.countryLayerDefinition_getCountry_OUT_200> countryList = parseResponse(response.getBody());

                if (!countryList.isEmpty()) {
                    // Fetch existing countries from Salesforce
                    Map<String, country2__c> country2Map = getExistingCountries();

                    // Process the countries from API
                    List<country2__c> countriesToUpsert = new List<country2__c>();

                    for (ExternalService.countryLayerDefinition_getCountry_OUT_200 extCountry : countryList) {
                        // Normalize the alpha3Code from the external service for comparison
                        String apiAlpha3Code = extCountry.alpha3Code != null ? extCountry.alpha3Code.trim().toLowerCase() : null;

                        // Check if the country exists in Salesforce by alpha3Code
                        country2__c existingCountry = country2Map.get(apiAlpha3Code);

                        if (existingCountry == null) {
                            // Non-existing: Create new record and add it to the upsert list
                            country2__c newCountry = createNewCountryRecord(extCountry);
                            countriesToUpsert.add(newCountry);
                        } else {
                            // Existing: Check for any changes, only update if necessary
                            if (hasChanges(existingCountry, extCountry)) {
                                updateCountryFields(existingCountry, extCountry);
                                countriesToUpsert.add(existingCountry);
                            }
                        }
                    }

                    // Perform Upsert Operation (inserts new and updates existing records based on external ID)
                    if (!countriesToUpsert.isEmpty()) {
                        upsert countriesToUpsert alpha3Code__c;  // external ID
                        System.debug('Upserted ' + countriesToUpsert.size() + ' country records.');
                    }
                }
            } else {
                System.debug('Error Response Body: ' + response.getBody());
            }
        } catch (Exception ex) {
            System.debug('Callout error: ' + ex.getMessage());
        }
    }
    
     // Sends HTTP request to the CountryLayer API and returns the response
    private static HttpResponse sendHttpRequest() {

        //request.setEndpoint('callout:countrylayerService/v2/all?access_key={!$Credential.countrylayerService.access_key}');
        // doesn't work, because named credentials supports formula only in body and headers, not as a query parameter.  
        // it is unusual to send credentials/tokens as a query parameter. 
		// Fetching the access key from custom settings is reasonable at least for a reason, 
		// that the key is not stored in git repository, however, not ideal.
		
        String accessKey = countrylayerServiceCred__c.getInstance().Access_Key__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Use the dynamic access key in the endpoint
        String endpoint = 'callout:countrylayerService/v2/all?access_key=' + accessKey;
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(120000);
        
        HttpResponse response = http.send(request);
        System.debug('Response Status: ' + response.getStatusCode());
        return response;
    }


    // Parses the response body into a list of country objects
    private static List<ExternalService.countryLayerDefinition_getCountry_OUT_200> parseResponse(String responseBody) {
        return (List<ExternalService.countryLayerDefinition_getCountry_OUT_200>)
            JSON.deserialize(responseBody, List<ExternalService.countryLayerDefinition_getCountry_OUT_200>.class);
    }

    // Fetches existing countries from the Salesforce org and returns a map by normalized alpha3Code
    private static Map<String, country2__c> getExistingCountries() {
        Map<String, country2__c> countryMap = new Map<String, country2__c>();
        for (country2__c country : [SELECT Name, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM country2__c]) {
            String normalizedAlpha3Code = country.alpha3Code__c != null ? country.alpha3Code__c.trim().toLowerCase() : null;
            countryMap.put(normalizedAlpha3Code, country);
        }
        return countryMap;
    }

    // Compares the existing record with the external country data to see if any changes are needed
    private static Boolean hasChanges(country2__c existingCountry, ExternalService.countryLayerDefinition_getCountry_OUT_200 extCountry) {
        return (existingCountry.Name != extCountry.name ||
                existingCountry.alpha2Code__c != extCountry.alpha2Code ||
                existingCountry.Capital__c != extCountry.capital ||
                existingCountry.Region__c != extCountry.region);
    }

    // Updates the country fields with the data from the external country
    private static void updateCountryFields(country2__c countryRecord, ExternalService.countryLayerDefinition_getCountry_OUT_200 extCountry) {
        countryRecord.Name = extCountry.name;
        countryRecord.alpha2Code__c = extCountry.alpha2Code;
        countryRecord.Capital__c = extCountry.capital;
        countryRecord.Region__c = extCountry.region;
    }

    // Creates a new country record from the external country data
    private static country2__c createNewCountryRecord(ExternalService.countryLayerDefinition_getCountry_OUT_200 extCountry) {
        country2__c newCountry = new country2__c();
        newCountry.alpha3Code__c = extCountry.alpha3Code;
        updateCountryFields(newCountry, extCountry);
        return newCountry;
    }
}