@IsTest
public class TeamMatchesController_Test {
    
    @TestSetup
    static void setup() { 

        // Create mock teams
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
            teams.add(new Account(Name = 'Team ' + i));
        }
        insert teams;
        
        // Create mock matches
        List<Match__c> matches = new List<Match__c>();
        matches.add(new Match__c(
            Match_Date__c = Date.today().addDays(-1),
            Team1__c = teams[0].Id,
            Team2__c = teams[1].Id,
            Team1_Goals__c = 2,
            Team2_Goals__c = 1,
            Home_Team_Penalty__c = 0,
            Away_Team_Penalties__c = 0
        ));
        matches.add(new Match__c(
            Match_Date__c = Date.today().addDays(-2),
            Team1__c = teams[1].Id,
            Team2__c = teams[0].Id,
            Team1_Goals__c = 1,
            Team2_Goals__c = 3,
            Home_Team_Penalty__c = 0,
            Away_Team_Penalties__c = 0
        ));
        insert matches;
    }

    @IsTest
    static void testGetTeamMatches() {
        Account team = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<Match__c> result = TeamMatchesController.getTeamMatches(team.Id);
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected to find two matches');
    }

    @IsTest
    static void testGetTeams() {
        Test.startTest();
        List<Account> result = TeamMatchesController.getTeams();
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected to find two teams');
    }

    @IsTest
    static void testGetTournamentResults() {
        // Create a mock HTTP response for the endpoint call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[]');
        res.setStatusCode(200);

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));

        // Call the method
        Test.startTest();
        List<Match__c> result = TeamMatchesController.getTournamentResults('someTournamentId');
        Test.stopTest();

        // Assert the result
        System.assertEquals(0, result.size(), 'Expected to find zero matches from the mock response');
    }

    // Mock class for HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse res) {
            this.response = res;
        }

        public HttpResponse respond(HttpRequest req) {
            return this.response;
        }
    }
}
