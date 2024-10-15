@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a few country2__c records for testing
        country2__c country1 = new country2__c(Name = 'United States', alpha2Code__c = 'US', alpha3Code__c = 'USA', Capital__c = 'Washington D.C.', Region__c = 'Americas');
        country2__c country2 = new country2__c(Name = 'France', alpha2Code__c = 'FR', alpha3Code__c = 'FRA', Capital__c = 'Paris', Region__c = 'Europe');
        insert country1;
        insert country2;
    }

    @isTest
    static void testOnBeforeInsert_WithCountry() {
        // Create a new Lead with a Country
        Lead newLead = new Lead(LastName = 'Doe', Company = 'Test Company', Country = 'United States');
        Test.startTest();
        insert newLead;
        Test.stopTest();
        
        // Fetch the inserted lead
        Lead insertedLead = [SELECT Id, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM Lead WHERE Id = :newLead.Id];
        
        // Assert that the fields were correctly populated
        System.assertEquals('US', insertedLead.alpha2Code__c);
        System.assertEquals('USA', insertedLead.alpha3Code__c);
        System.assertEquals('Washington D.C.', insertedLead.Capital__c);
        System.assertEquals('Americas', insertedLead.Region__c);
    }

    @isTest
    static void testOnBeforeInsert_NoCountry() {
        // Create a new Lead without a Country
        Lead newLead = new Lead(LastName = 'Doe', Company = 'Test Company');
        Test.startTest();
        insert newLead;
        Test.stopTest();
        
        // Fetch the inserted lead
        Lead insertedLead = [SELECT Id, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM Lead WHERE Id = :newLead.Id];
        
        // Assert that no fields were populated since the Country was not provided
        System.assertEquals(null, insertedLead.alpha2Code__c);
        System.assertEquals(null, insertedLead.alpha3Code__c);
        System.assertEquals(null, insertedLead.Capital__c);
        System.assertEquals(null, insertedLead.Region__c);
    }

    @isTest
    static void testOnBeforeUpdate_CountryChanged() {
        // Insert a Lead with initial country as 'United States'
        Lead newLead = new Lead(LastName = 'Doe', Company = 'Test Company', Country = 'United States');
        insert newLead;
        
        // Update the Lead with a new Country 'France'
        newLead.Country = 'France';
        Test.startTest();
        update newLead;
        Test.stopTest();
        
        // Fetch the updated lead
        Lead updatedLead = [SELECT Id, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM Lead WHERE Id = :newLead.Id];
        
        // Assert that the fields were correctly updated
        System.assertEquals('FR', updatedLead.alpha2Code__c);
        System.assertEquals('FRA', updatedLead.alpha3Code__c);
        System.assertEquals('Paris', updatedLead.Capital__c);
        System.assertEquals('Europe', updatedLead.Region__c);
    }

    @isTest
    static void testOnBeforeUpdate_CountryNotChanged() {
        // Insert a Lead with initial country as 'United States'
        Lead newLead = new Lead(LastName = 'Doe', Company = 'Test Company', Country = 'United States');
        insert newLead;
        
        // Update the Lead but do not change the Country
        newLead.Company = 'Updated Company';
        Test.startTest();
        update newLead;
        Test.stopTest();
        
        // Fetch the updated lead
        Lead updatedLead = [SELECT Id, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM Lead WHERE Id = :newLead.Id];
        
        // Assert that the fields remain the same since the Country was not changed
        System.assertEquals('US', updatedLead.alpha2Code__c);
        System.assertEquals('USA', updatedLead.alpha3Code__c);
        System.assertEquals('Washington D.C.', updatedLead.Capital__c);
        System.assertEquals('Americas', updatedLead.Region__c);
    }

    @isTest
    static void testOnBeforeUpdate_NoAlpha3Code() {
        // Insert a Lead with no alpha3Code__c
        Lead newLead = new Lead(LastName = 'Doe', Company = 'Test Company', Country = 'United States');
        insert newLead;
        
        // Update the Lead to clear the alpha3Code__c (simulate no alpha3Code__c)
        newLead.alpha3Code__c = '';
        Test.startTest();
        update newLead;
        Test.stopTest();
        
        // Fetch the updated lead
        Lead updatedLead = [SELECT Id, alpha2Code__c, alpha3Code__c, Capital__c, Region__c FROM Lead WHERE Id = :newLead.Id];
        
        // Assert that the fields were correctly re-populated
        System.assertEquals('US', updatedLead.alpha2Code__c);
        System.assertEquals('USA', updatedLead.alpha3Code__c);
        System.assertEquals('Washington D.C.', updatedLead.Capital__c);
        System.assertEquals('Americas', updatedLead.Region__c);
    }
}