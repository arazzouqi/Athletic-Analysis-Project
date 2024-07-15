global class TournamentMockDataBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Id tournamentId;
    global List<Account> mockTeams;
    global List<Match__c> createdMatches;
    
    global TournamentMockDataBatch(Id tournamentId) {
        this.tournamentId = tournamentId;
        this.mockTeams = new List<Account>();
        this.createdMatches = new List<Match__c>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Name FROM Tournament__c WHERE Id = :tournamentId
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (scope.isEmpty()) return;
        Tournament__c tournament = (Tournament__c)scope[0];

        // Create mock teams
        mockTeams = createMockTeams();

        // Get pre-created groups
        List<Group__c> groups = [SELECT Id FROM Group__c WHERE Tournament__c = :tournament.Id];

        // Create and insert group stage matches
        createAndInsertGroupStageMatchesStatically(tournament.Id, mockTeams, groups);

        // Create and insert knockout stage matches
        createAndInsertKnockoutStageMatchesStatically(tournament.Id,mockTeams);
    }

    global void finish(Database.BatchableContext BC) {
        // Optionally, add logic to run when the batch job finishes
    }

    private List<Account> createMockTeams() {
        List<Account> teams = new List<Account>();
        for (Integer i = 1; i <= 32; i++) {
            Account team = new Account(Name = 'Team ' + i);
            teams.add(team);
        }
        insert teams;
        return teams;
    }

    private void createAndInsertGroupStageMatchesStatically(Id tournamentId, List<Account> teams, List<Group__c> groups) {
        List<Match__c> matches = new List<Match__c>();

        // Manually create matches for each group
        for (Integer i = 0; i < groups.size(); i++) {
            Id groupId = groups[i].Id;
            Integer baseIndex = i * 4; // Each group has 4 teams

            // Team 1 vs Team 2
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 1].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 1),
                Team1_Goals__c = 1,
                Team2_Goals__c = 2
            ));
            // Team 1 vs Team 3
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 2].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 2),
                Team1_Goals__c = 2,
                Team2_Goals__c = 1
            ));
            // Team 1 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 3),
                Team1_Goals__c = 0,
                Team2_Goals__c = 3
            ));
            // Team 2 vs Team 3
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 1].Id,
                Team2__c = teams[baseIndex + 2].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 4),
                Team1_Goals__c = 1,
                Team2_Goals__c = 1
            ));
            // Team 2 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 1].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 5),
                Team1_Goals__c = 3,
                Team2_Goals__c = 0
            ));
            // Team 3 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 2].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 6),
                Team1_Goals__c = 2,
                Team2_Goals__c = 2
            ));
        }

        insert matches;
    }
/*
    private void createAndInsertGroupStageMatches(Id tournamentId, List<Account> teams, List<Group__c> groups) {
        List<Match__c> matches = new List<Match__c>();

        // Manually create matches for each group
        for (Integer i = 0; i < groups.size(); i++) {
            Id groupId = groups[i].Id;
            Integer baseIndex = i * 4; // Each group has 4 teams

            // Team 1 vs Team 2
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 1].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 1),
                Team1_Goals__c = 1,
                Team2_Goals__c = 2
            ));
            // Team 1 vs Team 3
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 2].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 2),
                Team1_Goals__c = 2,
                Team2_Goals__c = 1
            ));
            // Team 1 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 3),
                Team1_Goals__c = 0,
                Team2_Goals__c = 3
            ));
            // Team 2 vs Team 3
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 1].Id,
                Team2__c = teams[baseIndex + 2].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 4),
                Team1_Goals__c = 1,
                Team2_Goals__c = 1
            ));
            // Team 2 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 1].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 5),
                Team1_Goals__c = 3,
                Team2_Goals__c = 0
            ));
            // Team 3 vs Team 4
            matches.add(new Match__c(
                Tournament__c = tournamentId,
                Group__c = groupId,
                Team1__c = teams[baseIndex + 2].Id,
                Team2__c = teams[baseIndex + 3].Id,
                Match_Date__c = Date.today().addDays(i * 6 + 6),
                Team1_Goals__c = 2,
                Team2_Goals__c = 2
            ));
        }

        insert matches;
    }
*/


    private void createAndInsertKnockoutStageMatchesStatically(Id tournamentId, List<Account> teams) {
        List<Match__c> knockoutMatches = new List<Match__c>();

        // Manually create Round of 16 matches
        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[0].Id,
            Team2__c = teams[1].Id,
            Match_Date__c = Date.today().addDays(20),
            Team1_Goals__c = 2,
            Team2_Goals__c = 1
        ));

        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[2].Id,
            Team2__c = teams[3].Id,
            Match_Date__c = Date.today().addDays(21),
            Team1_Goals__c = 1,
            Team2_Goals__c = 3
        ));
        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[4].Id,
            Team2__c = teams[5].Id,
            Match_Date__c = Date.today().addDays(20),
            Team1_Goals__c = 2,
            Team2_Goals__c = 3
        ));

        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[6].Id,
            Team2__c = teams[7].Id,
            Match_Date__c = Date.today().addDays(21),
            Team1_Goals__c = 3,
            Team2_Goals__c = 2
        ));
        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[8].Id,
            Team2__c = teams[9].Id,
            Match_Date__c = Date.today().addDays(20),
            Team1_Goals__c = 1,
            Team2_Goals__c = 2
        ));

        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[10].Id,
            Team2__c = teams[11].Id,
            Match_Date__c = Date.today().addDays(21),
            Team1_Goals__c = 3,
            Team2_Goals__c = 1
        ));
        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[12].Id,
            Team2__c = teams[13].Id,
            Match_Date__c = Date.today().addDays(20),
            Team1_Goals__c = 2,
            Team2_Goals__c = 1
        ));

        knockoutMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Round of 16',
            Team1__c = teams[14].Id,
            Team2__c = teams[15].Id,
            Match_Date__c = Date.today().addDays(21),
            Team1_Goals__c = 1,
            Team2_Goals__c = 3
        ));

        // Add more Round of 16 matches as needed...

        insert knockoutMatches;

        // Manually create Quarter-finals matches
        List<Match__c> quarterFinalMatches = new List<Match__c>();
        quarterFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Quarter-finals',
            Team1__c = teams[0].Id,  // Assuming Team 0 won
            Team2__c = teams[3].Id,  // Assuming Team 3 won
            Match_Date__c = Date.today().addDays(28),
            Team1_Goals__c = 3,
            Team2_Goals__c = 2
        )); 
        quarterFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Quarter-finals',
            Team1__c = teams[5].Id,  // Assuming Team 0 won
            Team2__c = teams[6].Id,  // Assuming Team 3 won
            Match_Date__c = Date.today().addDays(28),
            Team1_Goals__c = 2,
            Team2_Goals__c = 1
        )); 
        quarterFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Quarter-finals',
            Team1__c = teams[9].Id,  // Assuming Team 0 won
            Team2__c = teams[10].Id,  // Assuming Team 3 won
            Match_Date__c = Date.today().addDays(28),
            Team1_Goals__c = 1,
            Team2_Goals__c = 3
        )); 
        quarterFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Quarter-finals',
            Team1__c = teams[12].Id,  // Assuming Team 0 won
            Team2__c = teams[15].Id,  // Assuming Team 3 won
            Match_Date__c = Date.today().addDays(28),
            Team1_Goals__c = 2,
            Team2_Goals__c = 1
        ));

         

        insert quarterFinalMatches;

        // Manually create Semi-finals matches
        List<Match__c> semiFinalMatches = new List<Match__c>();
        semiFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Semi-finals',
            Team1__c = teams[0].Id,  // Assuming Team 0 won
            Team2__c = teams[5].Id,  // Assuming Team 4 won
            Match_Date__c = Date.today().addDays(32),
            Team1_Goals__c = 2,
            Team2_Goals__c = 3
        )); 
        semiFinalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Semi-finals',
            Team1__c = teams[10].Id,  // Assuming Team 0 won
            Team2__c = teams[12].Id,  // Assuming Team 4 won
            Match_Date__c = Date.today().addDays(32),
            Team1_Goals__c = 1,
            Team2_Goals__c = 2
        ));

         

        insert semiFinalMatches;

        // Manually create Final match
        List<Match__c> finalMatches = new List<Match__c>();
        finalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Final',
            Team1__c = teams[5].Id,  // Assuming Team 4 won
            Team2__c = teams[12].Id,  // Assuming Team 5 won
            Match_Date__c = Date.today().addDays(35),
            Team1_Goals__c = 1,
            Team2_Goals__c = 0
        ));

        // Manually create Third place match
        finalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Third-place',
            Team1__c = teams[0].Id,  // Assuming Team 0 lost in Semi-finals
            Team2__c = teams[10].Id,  // Assuming Team 6 lost in Semi-finals
            Match_Date__c = Date.today().addDays(34),
            Team1_Goals__c = 3,
            Team2_Goals__c = 2
        ));

        insert finalMatches;
    }

    /*
    private void createAndInsertGroupStageMatches(Id tournamentId, List<Account> teams, List<Group__c> groups) {
        List<Match__c> matches = new List<Match__c>();
        for (Integer i = 0; i < 32; i += 4) {
            for (Integer j = 0; j < 4; j++) {
                for (Integer k = j + 1; k < 4; k++) {
                    Integer groupIndex = (Integer)Math.floor(i / 4);
                    matches.add(new Match__c(
                        Tournament__c = tournamentId,
                        Group__c = groups[groupIndex].Id,
                        Team1__c = teams[i + j].Id,
                        Team2__c = teams[i + k].Id,
                        Match_Date__c = Date.today().addDays((groupIndex + 1) * 3 + j),
                        Team1_Goals__c = j + 1,
                        Team2_Goals__c = k + 2
                    ));
                }
            }
        }
        Database.insert(matches,false);
    }*/

    /*
    private void createAndInsertKnockoutStageMatches(Id tournamentId) {
        // Get top 16 teams based on points
        List<Id> qualifiedTeams = new List<Id>();
        for (Team_Group__c tc : [SELECT Account__c FROM Team_Group__c 
                                 WHERE Group__r.Tournament__c = :tournamentId
                                 ORDER BY Points__c DESC LIMIT 16]) {
            qualifiedTeams.add(tc.Account__c);
        }

        // Round of 16
        List<Match__c> roundOf16Matches = new List<Match__c>();
        List<Id> roundOf16Winners = new List<Id>();
        for (Integer i = 0; i < 8; i++) {
            Id team1 = qualifiedTeams[i * 2];
            Id team2 = qualifiedTeams[i * 2 + 1];
            Integer team1Goals = 2 + i;
            Integer team2Goals = 1 + i;

            roundOf16Matches.add(new Match__c(
                Tournament__c = tournamentId,
                Knockout_Stage__c = 'Round of 16',
                Team1__c = team1,
                Team2__c = team2,
                Match_Date__c = Date.today().addDays(20 + i),
                Team1_Goals__c = team1Goals,
                Team2_Goals__c = team2Goals
            ));
            roundOf16Winners.add(team1Goals > team2Goals ? team1 : team2);
        }
        Database.insert(roundOf16Matches,false);

        // Quarter-finals
        List<Match__c> quarterFinalMatches = new List<Match__c>();
        List<Id> quarterFinalWinners = new List<Id>();
        for (Integer i = 0; i < 4; i++) {
            Id team1 = roundOf16Winners[i * 2];
            Id team2 = roundOf16Winners[i * 2 + 1];
            Integer team1Goals = 3 + i;
            Integer team2Goals = 2 + i;

            quarterFinalMatches.add(new Match__c(
                Tournament__c = tournamentId,
                Knockout_Stage__c = 'Quarter-finals',
                Team1__c = team1,
                Team2__c = team2,
                Match_Date__c = Date.today().addDays(28 + i),
                Team1_Goals__c = team1Goals,
                Team2_Goals__c = team2Goals
            ));
            quarterFinalWinners.add(team1Goals > team2Goals ? team1 : team2);
        }
        Database.insert(quarterFinalMatches,false);

        // Semi-finals
        List<Match__c> semiFinalMatches = new List<Match__c>();
        List<Id> semiFinalWinners = new List<Id>();
        List<Id> semiFinalLosers = new List<Id>();
        for (Integer i = 0; i < 2; i++) {
            Id team1 = quarterFinalWinners[i * 2];
            Id team2 = quarterFinalWinners[i * 2 + 1];
            Integer team1Goals = 4 + i;
            Integer team2Goals = 3 + i;

            semiFinalMatches.add(new Match__c(
                Tournament__c = tournamentId,
                Knockout_Stage__c = 'Semi-finals',
                Team1__c = team1,
                Team2__c = team2,
                Match_Date__c = Date.today().addDays(32 + i),
                Team1_Goals__c = team1Goals,
                Team2_Goals__c = team2Goals
            ));
            semiFinalWinners.add(team1Goals > team2Goals ? team1 : team2);
            semiFinalLosers.add(team1Goals > team2Goals ? team2 : team1);
        }
        Database.insert(semiFinalMatches);

        // Final
        List<Match__c> finalMatches = new List<Match__c>();
        finalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Final',
            Team1__c = semiFinalWinners[0],
            Team2__c = semiFinalWinners[1],
            Match_Date__c = Date.today().addDays(35),
            Team1_Goals__c = 5,
            Team2_Goals__c = 4
        ));

        // Third place
        finalMatches.add(new Match__c(
            Tournament__c = tournamentId,
            Knockout_Stage__c = 'Third-place',
            Team1__c = semiFinalLosers[0],
            Team2__c = semiFinalLosers[1],
            Match_Date__c = Date.today().addDays(34),
            Team1_Goals__c = 3,
            Team2_Goals__c = 2
        ));
        Database.insert(finalMatches);
    }*/
}
