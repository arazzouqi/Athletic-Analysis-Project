@IsTest
private class TournamentResultsAPI_Test {
    
    @TestSetup
    static void setup() {
        // Create a mock Tournament
        Tournament__c tournament = new Tournament__c(Name = 'Test Tournament');
        insert tournament;
        
        // Create mock Groups
        List<Group__c> groups = new List<Group__c>();
        for (Integer i = 0; i < 2; i++) {
            groups.add(new Group__c(Name = 'Group ' + (i + 1), Tournament__c = tournament.Id));
        }
        insert groups;

        // Create mock Teams
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 4; i++) {
            teams.add(new Account(Name = 'Team ' + i));
        }
        insert teams;

        // Create mock Matches
        List<Match__c> matches = new List<Match__c>();
        for (Integer i = 0; i < 2; i++) {
            Id groupId = groups[i].Id;
            for (Integer j = 0; j < 2; j++) {
                matches.add(new Match__c(
                    Tournament__c = tournament.Id,
                    Group__c = groupId,
                    Team1__c = teams[j].Id,
                    Team2__c = teams[j + 1].Id,
                    Match_Date__c = Date.today().addDays(i + j),
                    Team1_Goals__c = i + j,
                    Team2_Goals__c = i + j + 1,
                    Knockout_Stage__c = (j == 0) ? 'Round of 16' : null
                ));
            }
        }
        insert matches;
    }

    @IsTest
    static void testGetTournamentResults() {
        // Fetch the mock Tournament
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];

        // Set up the mock REST request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/tournamentResults/' + tournament.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;

        // Call the API method
        List<Match__c> results = TournamentResultsAPI.getTournamentResults();

        // Verify the results
        System.assertEquals(4, results.size(), 'Expected 4 matches to be returned.');
        
        for (Match__c match : results) {
            System.assertEquals(tournament.Id, match.Tournament__c, 'Tournament ID should match the requested ID.');
        }
    }
}
