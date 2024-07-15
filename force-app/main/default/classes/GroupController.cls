public with sharing class GroupController {
    @AuraEnabled(cacheable=true)
    public static List<TeamGroupWrapper> getGroupById(Id groupId) {
        List<TeamGroupWrapper> teamGroups = new List<TeamGroupWrapper>();

        for (Team_Group__c tg : [
            SELECT Id, Group__r.Name, Account__r.Name, Goals_For__c, Goal_Difference__c, Goals_Against__c, Points__c, Matches_Played__c 
            FROM Team_Group__c 
            WHERE Group__c = :groupId 
            ORDER BY Points__c DESC, Goals_For__c DESC, Goal_Difference__c DESC 
            LIMIT 4
        ]) {
            teamGroups.add(new TeamGroupWrapper(tg));
        }

        return teamGroups;
    }

    @AuraEnabled(cacheable=true)
    public static List<Group__c> getGroupsByTournament(Id tournamentId) {
        return [
            SELECT Id, Name 
            FROM Group__c 
            WHERE Tournament__c = :tournamentId 
            ORDER BY Name ASC 
            LIMIT 8
        ];
    }
    
    public class TeamGroupWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String groupName;
        @AuraEnabled public String teamName;
        @AuraEnabled public Decimal goalsFor;
        @AuraEnabled public Decimal goalDifference;
        @AuraEnabled public Decimal goalsAgainst;
        @AuraEnabled public Decimal points;
        @AuraEnabled public Decimal matchesPlayed;

        public TeamGroupWrapper(Team_Group__c tg) {
            this.id = tg.Id;
            this.groupName = tg.Group__r.Name;
            this.teamName = tg.Account__r.Name;
            this.goalsFor = tg.Goals_For__c;
            this.goalDifference = tg.Goal_Difference__c;
            this.goalsAgainst = tg.Goals_Against__c;
            this.points = tg.Points__c;
            this.matchesPlayed = tg.Matches_Played__c;
        }
    }
}
