@isTest
private class CountryLayerServiceTest {

    @isTest static void testNoResponseScenario() {
        // Set mock for no response scenario
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpCalloutMock(CountryLayerHttpCalloutMock.Scenario.NO_RESPONSE));
        
        Test.startTest();
        CountryLayerService.updateCountryLayerData();
        Test.stopTest();

        // Assertions for no response scenario
        // Check logs or debug statements for validation in this case
    }

    @isTest static void testEmptyListScenario() {
        // Set mock for empty list scenario
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpCalloutMock(CountryLayerHttpCalloutMock.Scenario.EMPTY_LIST));
        
        Test.startTest();
        CountryLayerService.updateCountryLayerData();
        Test.stopTest();

        // No countries should be inserted/updated in this scenario
        List<country2__c> countries = [SELECT Id FROM country2__c];
        System.assertEquals(0, countries.size(), 'No countries should be upserted when the API returns an empty list.');
    }

    @isTest static void testZeroSalesforceRecordsScenario() {
        // Set mock for scenario where there are no matching Salesforce records
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpCalloutMock(CountryLayerHttpCalloutMock.Scenario.ZERO_SALESFORCE_RECORDS));
        
        Test.startTest();
        CountryLayerService.updateCountryLayerData();
        Test.stopTest();

        // One country should be inserted in this case
        List<country2__c> countries = [SELECT Id, Name, alpha3Code__c, Region__c FROM country2__c];
        System.assertEquals(1, countries.size(), 'One country should be inserted.');
        System.assertEquals('AAA', countries[0].alpha3Code__c, 'The inserted country should have alpha3Code AAA.');
        System.assertEquals('Asia', countries[0].Region__c, 'The inserted country should have the region Asia.');
    }

@isTest static void testMismatchedRecordsScenario() {
        // Insert a mismatched country in Salesforce before the test
        country2__c existingCountry = new country2__c(Name = 'Country A', alpha3Code__c = 'AAA', alpha2Code__c = 'AA', Capital__c = 'Capital A', Region__c = 'Asia');
        insert existingCountry;

        // Set mock for mismatched records scenario
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpCalloutMock(CountryLayerHttpCalloutMock.Scenario.MISMATCHED_RECORDS));
        
        Test.startTest();
        CountryLayerService.updateCountryLayerData();
        Test.stopTest();

        // Verify the existing record is updated with new API data
        country2__c updatedCountry = [SELECT Name, alpha3Code__c, Region__c FROM country2__c WHERE alpha3Code__c = 'BBB'];
        System.assertEquals('Country B', updatedCountry.Name, 'Country should be updated with new API data.');
        System.assertEquals('Europe', updatedCountry.Region__c, 'The updated country should have the region Europe.');
    }

    @isTest static void testAllRecordsMatchingScenario() {
        // Insert a matching country in Salesforce before the test
        country2__c existingCountry = new country2__c(Name = 'Country A', alpha3Code__c = 'AAA', alpha2Code__c = 'AA', Capital__c = 'Capital A', Region__c = 'Asia');
        insert existingCountry;

        // Set mock for all records matching scenario
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpCalloutMock(CountryLayerHttpCalloutMock.Scenario.ALL_MATCHING));
        
        Test.startTest();
        CountryLayerService.updateCountryLayerData();
        Test.stopTest();

        // No upserts should happen as records are matching
        List<country2__c> countries = [SELECT Id FROM country2__c];
        System.assertEquals(1, countries.size(), 'No new country should be inserted when records are already matching.');
    }
}