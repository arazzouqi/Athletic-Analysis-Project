@RestResource(urlMapping='/tournamentResults/*')
global with sharing class TournamentResultsAPI {

    @HttpGet
    global static List<Match__c> getTournamentResults() {
        RestRequest req = RestContext.request;
        String tournamentId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        List<Match__c> results = [
            SELECT Id, Match_Date__c, Team1__c, Team1__r.Name, Team2__c, Team2__r.Name,Knockout_Stage__c, Tournament__c, Group__c,
                   Team1_Goals__c, Team2_Goals__c, Home_Team_Penalty__c, Away_Team_Penalties__c
            FROM Match__c
            WHERE Tournament__c = :tournamentId or Group__r.Tournament__c = :tournamentId
            WITH USER_MODE
            ORDER BY Match_Date__c DESC
        ];

        return results;
    }
}
