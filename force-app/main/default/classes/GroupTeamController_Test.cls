@IsTest
public class GroupTeamController_Test {

    @TestSetup
    static void setup() {
        // Create mock tournament
        Tournament__c tournament = new Tournament__c(Name = 'Mock Tournament');
        insert tournament;

        // Create mock groups
        List<Group__c> groups = new List<Group__c>();
        for (Integer i = 1; i <= 2; i++) {
            groups.add(new Group__c(Name = 'Group ' + i, Tournament__c = tournament.Id));
        }
        insert groups;

        // Create mock accounts (teams)
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 8; i++) {
            teams.add(new Account(Name = 'Team ' + i));
        }
        insert teams;

        // Create mock Team_Group__c records
        List<Team_Group__c> teamGroups = new List<Team_Group__c>();
        for (Integer i = 0; i < teams.size(); i++) {
            teamGroups.add(new Team_Group__c(
                Group__c = groups[i].Id,
                Account__c = teams[i].Id,
                Goals_For__c = i * 2,
                Goals_Against__c = i, 
                Matches_Played__c = i,
                Wins__c = i,
                Losses__c = i,
                Draws__c = i,
                Points__c = i * 3
            ));
        }
        insert teamGroups;
    }

    @IsTest
    static void testGetTeamGroups() {
        Test.startTest();
        List<GroupTeamController.TeamGroupWrapper> teamGroups = GroupTeamController.getTeamGroups();
        Test.stopTest();

        // Validate results
        System.assertNotEquals(0, teamGroups.size(), 'The result should not be empty.');

        for (GroupTeamController.TeamGroupWrapper tg : teamGroups) {
            System.assertNotEquals(null, tg.groupId, 'TeamGroupWrapper groupId should not be null.');
            System.assertNotEquals(null, tg.groupName, 'TeamGroupWrapper groupName should not be null.');
            System.assertNotEquals(null, tg.teamId, 'TeamGroupWrapper teamId should not be null.');
            System.assertNotEquals(null, tg.teamName, 'TeamGroupWrapper teamName should not be null.');
            System.assertNotEquals(null, tg.goalsFor, 'TeamGroupWrapper goalsFor should not be null.');
            System.assertNotEquals(null, tg.goalsAgainst, 'TeamGroupWrapper goalsAgainst should not be null.');
            System.assertNotEquals(null, tg.goalDifference, 'TeamGroupWrapper goalDifference should not be null.');
            System.assertNotEquals(null, tg.matchesPlayed, 'TeamGroupWrapper matchesPlayed should not be null.');
            System.assertNotEquals(null, tg.wins, 'TeamGroupWrapper wins should not be null.');
            System.assertNotEquals(null, tg.losses, 'TeamGroupWrapper losses should not be null.');
            System.assertNotEquals(null, tg.draws, 'TeamGroupWrapper draws should not be null.');
            System.assertNotEquals(null, tg.points, 'TeamGroupWrapper points should not be null.');
        }
    }
}
