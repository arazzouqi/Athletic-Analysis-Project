@IsTest
public class TournamentMockDataBatch_Test {

    @TestSetup
    static void setup() {
        // Create a mock Tournament
        Tournament__c tournament = new Tournament__c(Name = 'Test Tournament');
        insert tournament;

        // Create mock Groups
        List<Group__c> groups = new List<Group__c>();
        String[] groupNames = new String[]{'Group A', 'Group B', 'Group C', 'Group D', 'Group E', 'Group F', 'Group G', 'Group H'};
        for (Integer i = 0; i < 8; i++) {
            groups.add(new Group__c(Name = groupNames[i], Tournament__c = tournament.Id));
        }
        insert groups;
    }

    @IsTest
    static void testBatchExecution() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        
        Test.startTest();
        // Instantiate and execute the batch
        TournamentMockDataBatch batch = new TournamentMockDataBatch(tournament.Id);
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify the mock teams were created
        List<Account> teams = [SELECT Id, Name FROM Account WHERE Name LIKE 'Team %'];
        System.assertEquals(32, teams.size(), 'Expected 32 teams to be created.');

        // Verify the group stage matches were created
        List<Match__c> groupStageMatches = [SELECT Id FROM Match__c WHERE Knockout_Stage__c = null];
        System.assertEquals(48, groupStageMatches.size(), 'Expected 48 group stage matches to be created.');

        // Verify the knockout stage matches were created
        List<Match__c> knockoutStageMatches = [SELECT Id FROM Match__c WHERE Knockout_Stage__c != null];
        System.assertEquals(15, knockoutStageMatches.size(), 'Expected 15 knockout stage matches to be created.');
    }
}
