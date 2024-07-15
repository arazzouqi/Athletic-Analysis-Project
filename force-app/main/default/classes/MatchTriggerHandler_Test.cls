@isTest
public class MatchTriggerHandler_Test {
    
    @TestSetup
    static void setup() {
        // Create mock accounts (teams)
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 8; i++) {
            teams.add(new Account(Name = 'Team ' + i));
        }
        insert teams;
        
        // Create a mock tournament
        Tournament__c tournament = new Tournament__c(Name = 'Mock Tournament');
        insert tournament;
        
        // Create mock groups
        List<Group__c> groups = new List<Group__c>();
        for (Integer i = 1; i <= 2; i++) {
            groups.add(new Group__c(Name = 'Group ' + i, Tournament__c = tournament.Id));
        }
        insert groups;

        // Create mock Team_Group__c records
        List<Team_Group__c> teamGroups = new List<Team_Group__c>();
        for (Integer i = 0; i < teams.size(); i++) {
            teamGroups.add(new Team_Group__c(
                Group__c = groups[i].Id,
                Account__c = teams[i].Id,
                Name = teams[i].Name,
                Points__c = 0,
                Matches_Played__c = 0,
                Goals_For__c = 0,
                Goals_Against__c = 0, 
                Draws__c = 0,
                Losses__c = 0,  
                Wins__c = 0 
            ));
        }
        insert teamGroups;
    }
    
    @IsTest
    static void testBeforeInsert() {
        List<Match__c> newMatches = new List<Match__c>();
        
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Account> teams = [SELECT Id FROM Account LIMIT 8];
        
        // Create matches within constraints
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 2));
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 3, Team2_Goals__c = 0));
        
        Test.startTest();
        insert newMatches;
        Test.stopTest();
        
        // Validate that matches were inserted
        System.assertEquals(2, [SELECT COUNT() FROM Match__c]);
    }
    
    @IsTest
    static void testBeforeUpdate() {
        List<Match__c> newMatches = new List<Match__c>();
        
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Account> teams = [SELECT Id FROM Account LIMIT 8];
        
        // Create matches within constraints
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 2));
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 3, Team2_Goals__c = 0));
        
        insert newMatches;
        
        // Update matches
        newMatches[0].Team1_Goals__c = 2;
        newMatches[0].Team2_Goals__c = 2;
        newMatches[1].Team1_Goals__c = 0;
        newMatches[1].Team2_Goals__c = 1;
        
        Test.startTest();
        update newMatches;
        Test.stopTest();
        
        // Validate that matches were updated
        Match__c updatedMatch1 = [SELECT Team1_Goals__c, Team2_Goals__c FROM Match__c WHERE Id = :newMatches[0].Id];
        Match__c updatedMatch2 = [SELECT Team1_Goals__c, Team2_Goals__c FROM Match__c WHERE Id = :newMatches[1].Id];
        System.assertEquals(2, updatedMatch1.Team1_Goals__c);
        System.assertEquals(2, updatedMatch1.Team2_Goals__c);
        System.assertEquals(0, updatedMatch2.Team1_Goals__c);
        System.assertEquals(1, updatedMatch2.Team2_Goals__c);
    }
    
    @IsTest
    static void testAfterInsert() {
        List<Match__c> newMatches = new List<Match__c>();
        
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Account> teams = [SELECT Id FROM Account LIMIT 8];
        
        // Create matches within constraints
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 2));
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 3, Team2_Goals__c = 0));
        
        Test.startTest();
        insert newMatches;
        Test.stopTest();
        
        // Validate that Team_Group__c records were updated
        List<Team_Group__c> teamGroups = [SELECT Account__c, Goals_For__c, Goals_Against__c, Matches_Played__c, Wins__c, Losses__c, Draws__c, Points__c FROM Team_Group__c];
        System.assertEquals(4, teamGroups.size());
        
        // Validate goals, matches played, and points
        for (Team_Group__c tg : teamGroups) {
            if (tg.Account__c == teams[0].Id) {
                System.assertEquals(1, tg.Goals_For__c);
                System.assertEquals(2, tg.Goals_Against__c);
                System.assertEquals(1, tg.Matches_Played__c);
                System.assertEquals(0, tg.Wins__c);
                System.assertEquals(1, tg.Losses__c);
                System.assertEquals(0, tg.Draws__c);
                System.assertEquals(0, tg.Points__c);
            } else if (tg.Account__c == teams[1].Id) {
                System.assertEquals(2, tg.Goals_For__c);
                System.assertEquals(1, tg.Goals_Against__c);
                System.assertEquals(1, tg.Matches_Played__c);
                System.assertEquals(1, tg.Wins__c);
                System.assertEquals(0, tg.Losses__c);
                System.assertEquals(0, tg.Draws__c);
                System.assertEquals(3, tg.Points__c);
            } else if (tg.Account__c == teams[2].Id) {
                System.assertEquals(3, tg.Goals_For__c);
                System.assertEquals(0, tg.Goals_Against__c);
                System.assertEquals(1, tg.Matches_Played__c);
                System.assertEquals(1, tg.Wins__c);
                System.assertEquals(0, tg.Losses__c);
                System.assertEquals(0, tg.Draws__c);
                System.assertEquals(3, tg.Points__c);
            } else if (tg.Account__c == teams[3].Id) {
                System.assertEquals(0, tg.Goals_For__c);
                System.assertEquals(3, tg.Goals_Against__c);
                System.assertEquals(1, tg.Matches_Played__c);
                System.assertEquals(0, tg.Wins__c);
                System.assertEquals(1, tg.Losses__c);
                System.assertEquals(0, tg.Draws__c);
                System.assertEquals(0, tg.Points__c);
            }
        }
    }
    
    @IsTest
    static void testCheckMatchTiming() {
        // Create mock data for checking match timing
        List<Match__c> newMatches = new List<Match__c>();
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Account> teams = [SELECT Id FROM Account LIMIT 8];
        
        // Create matches within constraints
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 2, Round_Number__c = 3, Match_Date__c = Date.today()));
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 3, Team2_Goals__c = 0, Round_Number__c = 3, Match_Date__c = Date.today()));
        
        Test.startTest();
        try {
            insert newMatches;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The last two matches of round 3 in the same group must be at the same time.'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testValidateMatchEligibility() {
        List<Match__c> newMatches = new List<Match__c>();
        
        List<Group__c> groups = [SELECT Id FROM Group__c];
        List<Account> teams = [SELECT Id FROM Account LIMIT 8];
        
        // Create initial matches to set up last match data
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 2));
        newMatches.add(new Match__c(Group__c = groups[0].Id, Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 3, Team2_Goals__c = 0));
        
        insert newMatches;
        
        // Create knockout matches to validate eligibility
        List<Match__c> knockoutMatches = new List<Match__c>();
        knockoutMatches.add(new Match__c(Knockout_Stage__c = 'Quarter-finals', Team1__c = teams[0].Id, Team2__c = teams[1].Id, Team1_Goals__c = 1, Team2_Goals__c = 1, Home_Team_Penalty__c = 5, Away_Team_Penalties__c = 4));
        knockoutMatches.add(new Match__c(Knockout_Stage__c = 'Quarter-finals', Team1__c = teams[2].Id, Team2__c = teams[3].Id, Team1_Goals__c = 2, Team2_Goals__c = 1));
        
        Test.startTest();
        insert knockoutMatches;
        Test.stopTest();
        
        // Validate that the matches were inserted
        System.assertEquals(4, [SELECT COUNT() FROM Match__c]);
    }
}
