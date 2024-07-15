@IsTest
public class KnockoutPhaseController_Test {
    
    @TestSetup
    static void setup() {
        // Create mock tournament
        Tournament__c tournament = new Tournament__c(Name = 'Mock Tournament');
        insert tournament;
        
        // Create mock accounts (teams)
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 8; i++) {
            teams.add(new Account(Name = 'Team ' + i));
        }
        insert teams;
        
        // Create mock matches for different stages
        List<Match__c> matches = new List<Match__c>();
        matches.add(new Match__c(
            Tournament__c = tournament.Id,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[0].Id,
            Team2__c = teams[1].Id,
            Team1_Goals__c = 2,
            Team2_Goals__c = 1,
            Match_Date__c = Date.today()
        ));
        matches.add(new Match__c(
            Tournament__c = tournament.Id,
            Knockout_Stage__c = 'Quarter-finals',
            Team1__c = teams[2].Id,
            Team2__c = teams[3].Id,
            Team1_Goals__c = 3,
            Team2_Goals__c = 2,
            Match_Date__c = Date.today().addDays(1)
        ));
        matches.add(new Match__c(
            Tournament__c = tournament.Id,
            Knockout_Stage__c = 'Semi-finals',
            Team1__c = teams[4].Id,
            Team2__c = teams[5].Id,
            Team1_Goals__c = 1,
            Team2_Goals__c = 2,
            Match_Date__c = Date.today().addDays(2)
        ));
        matches.add(new Match__c(
            Tournament__c = tournament.Id,
            Knockout_Stage__c = 'Third-place',
            Team1__c = teams[6].Id,
            Team2__c = teams[7].Id,
            Team1_Goals__c = 1,
            Team2_Goals__c = 3,
            Match_Date__c = Date.today().addDays(3)
        ));
        matches.add(new Match__c(
            Tournament__c = tournament.Id,
            Knockout_Stage__c = 'Finals',
            Team1__c = teams[0].Id,
            Team2__c = teams[2].Id,
            Team1_Goals__c = 2,
            Team2_Goals__c = 2,
            Match_Date__c = Date.today().addDays(4)
        ));
        insert matches;
    }

    @IsTest
    static void testGetMatchsById() {
        Match__c match = [SELECT Id FROM Match__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getmatchsById(match.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match');
    }

    @IsTest
    static void testGetGameResultsByCompetitionFirstRound() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getGameResultsByCompetitionFirstRound(tournament.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match in Round of 16');
    }

    @IsTest
    static void testGetGameResultsByCompetitionSecondRound() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getGameResultsByCompetitionSecondRound(tournament.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match in Quarter-finals');
    }

    @IsTest
    static void testGetGameResultsByCompetitionSemiFinals() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getGameResultsByCompetitionSemiFinals(tournament.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match in Semi-finals');
    }

    @IsTest
    static void testGetGameResultsByCompetitionPlacementGame() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getGameResultsByCompetitionPlacementGame(tournament.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match in Third-place');
    }

    @IsTest
    static void testGetGameResultsByCompetitionFinals() {
        Tournament__c tournament = [SELECT Id FROM Tournament__c LIMIT 1];
        Test.startTest();
        List<Match__c> result = KnockoutPhaseController.getGameResultsByCompetitionFinals(tournament.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected to find one match in Finals');
    }
}
