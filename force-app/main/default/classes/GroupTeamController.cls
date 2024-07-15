public with sharing class GroupTeamController {
    @AuraEnabled(cacheable=true)
    public static List<TeamGroupWrapper> getTeamGroups() {
        List<TeamGroupWrapper> teamGroups = new List<TeamGroupWrapper>();

        for (Team_Group__c tg : [
            SELECT Id, Group__c, Group__r.Name, Account__c, Account__r.Name, Goals_For__c, Goals_Against__c, Goal_Difference__c, Matches_Played__c, Wins__c, Losses__c, Draws__c, Points__c
            FROM Team_Group__c
            ORDER BY Group__r.Name, Points__c DESC, Goals_For__c DESC, Goals_Against__c ASC, Goal_Difference__c DESC
        ]) {
            teamGroups.add(new TeamGroupWrapper(tg));
        }

        return teamGroups;
    }

    public class TeamGroupWrapper {
        @AuraEnabled public String groupId;
        @AuraEnabled public String groupName;
        @AuraEnabled public String teamId;
        @AuraEnabled public String teamName;
        @AuraEnabled public Decimal goalsFor;
        @AuraEnabled public Decimal goalsAgainst;
        @AuraEnabled public Decimal goalDifference;
        @AuraEnabled public Decimal matchesPlayed;
        @AuraEnabled public Decimal wins;
        @AuraEnabled public Decimal losses;
        @AuraEnabled public Decimal draws;
        @AuraEnabled public Decimal points;

        public TeamGroupWrapper(Team_Group__c tg) {
            this.groupId = tg.Group__c;
            this.groupName = tg.Group__r.Name;
            this.teamId = tg.Account__c;
            this.teamName = tg.Account__r.Name;
            this.goalsFor = tg.Goals_For__c;
            this.goalsAgainst = tg.Goals_Against__c;
            this.goalDifference = tg.Goal_Difference__c;
            this.matchesPlayed = tg.Matches_Played__c;
            this.wins = tg.Wins__c;
            this.losses = tg.Losses__c;
            this.draws = tg.Draws__c;
            this.points = tg.Points__c;
        }
    }
}
