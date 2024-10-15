@isTest
global class CountryLayerHttpCalloutMock implements HttpCalloutMock {
    
    // Scenario Enum to handle different test cases
    public enum Scenario { NO_RESPONSE, EMPTY_LIST, ZERO_SALESFORCE_RECORDS, MISMATCHED_RECORDS, ALL_MATCHING }
    private Scenario testScenario;

    // Constructor to set the scenario
    public CountryLayerHttpCalloutMock(Scenario scenario) {
        this.testScenario = scenario;
    }

    // Respond method to provide mocked HTTP response based on scenario
    global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        // Mocking different responses for each scenario
        switch on testScenario {
            when NO_RESPONSE {
                res.setStatusCode(500); // Simulate no response or error
                res.setBody('{"error": "No response"}');
            }
            when EMPTY_LIST {
                res.setStatusCode(200);
                res.setBody('[]'); // Empty list from API
            }
            when ZERO_SALESFORCE_RECORDS {
                res.setStatusCode(200);
                res.setBody('[{"name": "Country A", "alpha3Code": "AAA", "alpha2Code": "AA", "capital": "Capital A", "region": "Asia"}]'); // Single country returned
            }
            when MISMATCHED_RECORDS {
                res.setStatusCode(200);
                res.setBody('[{"name": "Country B", "alpha3Code": "BBB", "alpha2Code": "BB", "capital": "Capital B", "region": "Europe"}]'); // Different country returned
            }
            when ALL_MATCHING {
                res.setStatusCode(200);
                res.setBody('[{"name": "Country A", "alpha3Code": "AAA", "alpha2Code": "AA", "capital": "Capital A", "region": "Asia"}]'); // Matching country record
            }
        }

        return res;
    }
}