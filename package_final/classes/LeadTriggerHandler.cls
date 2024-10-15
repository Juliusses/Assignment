public class LeadTriggerHandler {
    
    public Boolean isExecuting;
    public Integer size;
    
    public LeadTriggerHandler(Boolean isExecuting, Integer size) {
        this.isExecuting = isExecuting;
        this.size = size;
    }
    
    // Before Insert
    public void OnBeforeInsert(List<Lead> newLeads) {
        List<country2__c> countriesToQuery = new List<country2__c>();
        Set<String> countryNames = new Set<String>();
        
        // Collect all unique country names from new leads
        for (Lead lead : newLeads) {
            if (!String.isEmpty(lead.Country)) {
                countryNames.add(lead.Country);
            }
        }
        
        if (!countryNames.isEmpty()) {
            countriesToQuery = [SELECT Name, alpha2Code__c, alpha3Code__c, Capital__c, Region__c 
                                FROM country2__c 
                                WHERE Name IN :countryNames];
        }
        
        // Create a map for quick lookup
        Map<String, country2__c> countryMap = new Map<String, country2__c>();
        for (country2__c country : countriesToQuery) {
            countryMap.put(country.Name, country);
        }
        
        // Update leads with country information
        for (Lead lead : newLeads) {
            if (!String.isEmpty(lead.Country) && countryMap.containsKey(lead.Country)) {
                country2__c matchedCountry = countryMap.get(lead.Country);
                lead.alpha2Code__c = matchedCountry.alpha2Code__c;
                lead.alpha3Code__c = matchedCountry.alpha3Code__c;
                lead.Capital__c = matchedCountry.Capital__c;
                lead.Region__c = matchedCountry.Region__c;
            }
        }
    }
    
    /*
    // After Insert
    public void OnAfterInsert(List<Lead> newLeads) {
        // Implement any after-insert logic if needed
    }
	*/
    
    // Before Update
    public void OnBeforeUpdate(List<Lead> newLeads, List<Lead> oldLeads, Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        List<String> countriesToUpdate = new List<String>();
        Set<Id> leadIdsToUpdate = new Set<Id>();
        
        // Identify leads where Country has changed or alpha3Code__c is empty
        for (Lead newLead : newLeads) {
            Lead oldLead = oldMap.get(newLead.Id);
            if (isCountryChanged(newLead, oldLead) || String.isEmpty(newLead.alpha3Code__c)) {
                if (!String.isEmpty(newLead.Country)) {
                    countriesToUpdate.add(newLead.Country);
                    leadIdsToUpdate.add(newLead.Id);
                }
            }
        }
        
        // Query matching countries
        List<country2__c> countries = new List<country2__c>();
        if (!countriesToUpdate.isEmpty()) {
            countries = [SELECT Name, alpha2Code__c, alpha3Code__c, Capital__c, Region__c 
                         FROM country2__c 
                         WHERE Name IN :countriesToUpdate];
        }
        
        // Map countries by name for quick access
        Map<String, country2__c> countryMap = new Map<String, country2__c>();
        for (country2__c country : countries) {
            countryMap.put(country.Name, country);
        }
        
        // Update leads with country information
        for (Lead newLead : newLeads) {
            if (leadIdsToUpdate.contains(newLead.Id) && countryMap.containsKey(newLead.Country)) {
                country2__c matchedCountry = countryMap.get(newLead.Country);
                newLead.alpha2Code__c = matchedCountry.alpha2Code__c;
                newLead.alpha3Code__c = matchedCountry.alpha3Code__c;
                newLead.Capital__c = matchedCountry.Capital__c;
                newLead.Region__c = matchedCountry.Region__c;
            }
        }
    }
    
    /*
    // After Update
    public void OnAfterUpdate(List<Lead> newLeads, List<Lead> oldLeads, Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        // Implement any after-update logic if needed
    }*/
    
    // Helper method to check if the country has changed
    private Boolean isCountryChanged(Lead newLead, Lead oldLead) {
        return newLead.Country != oldLead.Country;
    }
}