@IsTest
public class GroupController_Test {
    
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
                Points__c = i * 3,
                Matches_Played__c = i
            ));
        }
        insert teamGroups;
    }
    
    @IsTest
    static void testGetGroupById() {
        // Get an existing group
        Group__c grp= [SELECT Id FROM Group__c LIMIT 1];
        
        Test.startTest();
        List<GroupController.TeamGroupWrapper> teamGroups = GroupController.getGroupById(grp.Id);
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(0, teamGroups.size(), 'The group should have team records.');
        System.assertEquals(4, teamGroups.size(), 'The result should be limited to 4 teams.');

        for (GroupController.TeamGroupWrapper tg : teamGroups) {
            System.assertNotEquals(null, tg.id, 'TeamGroupWrapper id should not be null.');
            System.assertNotEquals(null, tg.groupName, 'TeamGroupWrapper groupName should not be null.');
            System.assertNotEquals(null, tg.teamName, 'TeamGroupWrapper teamName should not be null.');
            System.assertNotEquals(null, tg.goalsFor, 'TeamGroupWrapper goalsFor should not be null.');
            System.assertNotEquals(null, tg.goalDifference, 'TeamGroupWrapper goalDifference should not be null.');
            System.assertNotEquals(null, tg.goalsAgainst, 'TeamGroupWrapper goalsAgainst should not be null.');
            System.assertNotEquals(null, tg.points, 'TeamGroupWrapper points should not be null.');
            System.assertNotEquals(null, tg.matchesPlayed, 'TeamGroupWrapper matchesPlayed should not be null.');
        }
    }

    @IsTest
    static void testGetGroupsByTournament() {
        // Get the existing tournament
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        
        Test.startTest();
        List<Group__c> groups = GroupController.getGroupsByTournament(tournament.Id);
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(0, groups.size(), 'The tournament should have group records.');
        System.assertEquals(2, groups.size(), 'The result should return 2 groups.');

        for (Group__c grp : groups) {
            System.assertNotEquals(null, grp.Id, 'Group Id should not be null.');
            System.assertNotEquals(null, grp.Name, 'Group Name should not be null.');
        }
    }
}
