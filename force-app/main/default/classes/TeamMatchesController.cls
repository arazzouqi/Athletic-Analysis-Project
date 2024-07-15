public with sharing class TeamMatchesController {
    
    @AuraEnabled(cacheable=true)
    public static List<Match__c> getTeamMatches(Id teamId) {
        List<Match__c> matches =  [
            SELECT Id, Match_Date__c, Team1__c, Team1__r.Name, Team2__c, Team2__r.Name,Team1__r.Team_Logo__c, Team2__r.Team_Logo__c, 
                   Team1_Goals__c, Team2_Goals__c, Home_Team_Penalty__c, Away_Team_Penalties__c
            FROM Match__c
            WHERE Team1__c = :teamId OR Team2__c = :teamId
            ORDER BY Match_Date__c DESC
        ];
        return matches;
    }


    @AuraEnabled(cacheable=true)
    public static List<Account> getTeams() {
        return [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.Name = 'Team'
            ORDER BY Name
        ];
    }


    @AuraEnabled(cacheable=true)
    public static List<Match__c> getTournamentResults(String tournamentId) {
        String endpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/tournamentResults/' + tournamentId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            return (List<Match__c>) JSON.deserialize(res.getBody(), List<Match__c>.class);
        } else {
            throw new AuraHandledException('Error fetching tournament results: ' + res.getStatus());
        }
    }
}