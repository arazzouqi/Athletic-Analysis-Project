public class MatchTriggerHandler {
    private static final Integer MAX_TEAMS_PER_GROUP = 4;
    private static final Integer MAX_MATCHES_PER_TEAM_IN_GROUP_STAGE = 3;

    public void beforeInsert(List<Match__c> newMatches) {
        enforceGroupConstraints(newMatches);
        checkMatchTiming(newMatches);
        validateMatchEligibility(newMatches);
    }

    public void beforeUpdate(List<Match__c> newMatches, Map<Id, Match__c> oldMatches) {
        enforceGroupConstraints(newMatches);
        checkMatchTiming(newMatches); 
    }

    public void afterInsert(List<Match__c> newMatches) {
        createAndUpdateTeamGroups(newMatches);
    }

    private void enforceGroupConstraints(List<Match__c> matches) {
        Set<Id> groupIds = new Set<Id>();
        Set<Id> teamIds = new Set<Id>();
        for (Match__c match : matches) {
            if (match.Group__c != null) {
                groupIds.add(match.Group__c);
            }
            if (match.Team1__c != null) {
                teamIds.add(match.Team1__c);
            }
            if (match.Team2__c != null) {
                teamIds.add(match.Team2__c);
            }
        }

        // Map to store team names
        Map<Id, String> teamNames = new Map<Id, String>();
        for (Account team : [SELECT Id, Name FROM Account WHERE Id IN :teamIds]) {
            teamNames.put(team.Id, team.Name);
        }

        // Map to store the existing teams in each group based on match records
        Map<Id, Set<Id>> groupTeams = new Map<Id, Set<Id>>();
        Map<Id, Integer> teamMatchCounts = new Map<Id, Integer>();

        // Query existing matches to get team counts
        for (AggregateResult ar : [
            SELECT Group__c, Team1__c, COUNT(Id) matchCount
            FROM Match__c
            WHERE Group__c IN :groupIds
            GROUP BY Group__c, Team1__c
        ]) {
            Id groupId = (Id) ar.get('Group__c');
            Id teamId = (Id) ar.get('Team1__c');
            Integer matchCount = (Integer) ar.get('matchCount');

            if (!groupTeams.containsKey(groupId)) {
                groupTeams.put(groupId, new Set<Id>());
            }
            groupTeams.get(groupId).add(teamId);

            if (!teamMatchCounts.containsKey(teamId)) {
                teamMatchCounts.put(teamId, 0);
            }
            teamMatchCounts.put(teamId, teamMatchCounts.get(teamId) + matchCount);
        }

        for (AggregateResult ar : [
            SELECT Group__c, Team2__c, COUNT(Id) matchCount
            FROM Match__c
            WHERE Group__c IN :groupIds
            GROUP BY Group__c, Team2__c
        ]) {
            Id groupId = (Id) ar.get('Group__c');
            Id teamId = (Id) ar.get('Team2__c');
            Integer matchCount = (Integer) ar.get('matchCount');

            if (!groupTeams.containsKey(groupId)) {
                groupTeams.put(groupId, new Set<Id>());
            }
            groupTeams.get(groupId).add(teamId);

            if (!teamMatchCounts.containsKey(teamId)) {
                teamMatchCounts.put(teamId, 0);
            }
            teamMatchCounts.put(teamId, teamMatchCounts.get(teamId) + matchCount);
        }

        for (Match__c match : matches) {
            Id groupId = match.Group__c;

            // Check if the number of distinct teams in the group exceeds the limit
            if (!groupTeams.containsKey(groupId)) {
                groupTeams.put(groupId, new Set<Id>());
            }

            groupTeams.get(groupId).add(match.Team1__c);
            groupTeams.get(groupId).add(match.Team2__c);

            if (groupTeams.get(groupId).size() > MAX_TEAMS_PER_GROUP) {
                match.addError('The group has reached the maximum number of teams (' + MAX_TEAMS_PER_GROUP + ').');
            }

            // Check if Team1 has already played 3 matches in the group stage
            Integer team1MatchCount = [SELECT COUNT() FROM Match__c WHERE Group__c = :groupId AND (Team1__c = :match.Team1__c OR Team2__c = :match.Team1__c)];
            if (team1MatchCount >= MAX_MATCHES_PER_TEAM_IN_GROUP_STAGE && match.Knockout_Stage__c =='Group') {
                match.addError('Team ' + teamNames.get(match.Team1__c) + ' has already played the maximum number of matches (' + MAX_MATCHES_PER_TEAM_IN_GROUP_STAGE + ') in the group stage.');
            }

            // Check if Team2 has already played 3 matches in the group stage
            Integer team2MatchCount = [SELECT COUNT() FROM Match__c WHERE Group__c = :groupId AND (Team1__c = :match.Team2__c OR Team2__c = :match.Team2__c)];
            if (team2MatchCount >= MAX_MATCHES_PER_TEAM_IN_GROUP_STAGE && match.Knockout_Stage__c =='Group') {
                match.addError('Team ' + teamNames.get(match.Team2__c) + ' has already played the maximum number of matches (' + MAX_MATCHES_PER_TEAM_IN_GROUP_STAGE + ') in the group stage.');
            }
        }
    }

    public void checkMatchTiming(List<Match__c> matches) {
        Set<Id> groupIds = new Set<Id>();
        for (Match__c match : matches) {
            if (match.Group__c != null) {
                groupIds.add(match.Group__c);
            }
        }

        if (!groupIds.isEmpty()) {
            // Query existing matches in round 3 within the same group
            Map<Id, List<Match__c>> groupRound3Matches = new Map<Id, List<Match__c>>();
            for (Match__c match : [SELECT Id, Group__c, Match_Date__c, Round_Number__c FROM Match__c WHERE Group__c IN :groupIds AND Round_Number__c = 3 ]) {
                if (!groupRound3Matches.containsKey(match.Group__c)) {
                    groupRound3Matches.put(match.Group__c, new List<Match__c>());
                }
                groupRound3Matches.get(match.Group__c).add(match);
            }

            for (Match__c match : matches) {
                if (match.Round_Number__c == 3 && groupRound3Matches.containsKey(match.Group__c)) {
                    List<Match__c> round3Matches = groupRound3Matches.get(match.Group__c);

                    // Check if there are already matches in round 3 for this group
                    if (round3Matches.size() == 1) {
                        // Ensure the times are the same
                        if (round3Matches[0].Match_Date__c != match.Match_Date__c && round3Matches[0].Id != match.Id) {
                            match.addError('The last two matches of round 3 in the same group must be at the same time.');
                        }
                    } else if (round3Matches.size() > 1) {
                        match.addError('There are already two matches scheduled for round 3 in this group.');
                    }
                }
            }
        }
    }

    

    
    private void createAndUpdateTeamGroups(List<Match__c> matches) {
        Set<Id> groupIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
    
        for (Match__c match : matches) {
            if (match.Group__c != null) {
                groupIds.add(match.Group__c);
            }
            if (match.Team1__c != null) {
                accountIds.add(match.Team1__c);
            }
            if (match.Team2__c != null) {
                accountIds.add(match.Team2__c);
            }
        }
    
        // Query to get the existing teams in each group
        Map<Id, Map<Id, Team_Group__c>> groupTeams = new Map<Id, Map<Id, Team_Group__c>>();
        for (Team_Group__c tg : [
            SELECT Id, Group__c, Account__c, Goals_For__c, Goals_Against__c, Goal_Difference__c, Matches_Played__c, Wins__c, Losses__c, Draws__c, Points__c
            FROM Team_Group__c
            WHERE Group__c IN :groupIds
        ]) {
            if (!groupTeams.containsKey(tg.Group__c)) {
                groupTeams.put(tg.Group__c, new Map<Id, Team_Group__c>());
            }
            groupTeams.get(tg.Group__c).put(tg.Account__c, tg);
        }
    
        // Add new teams to groups if necessary and update existing ones
        List<Team_Group__c> newTeamGroups = new List<Team_Group__c>();
        List<Team_Group__c> updatedTeamGroups = new List<Team_Group__c>();
    
        for (Match__c match : matches) {
            Id groupId = match.Group__c;
    
            // Ensure Team1 is in the group and update its stats
            if (!groupTeams.containsKey(groupId)) {
                groupTeams.put(groupId, new Map<Id, Team_Group__c>());
            }
            if (!groupTeams.get(groupId).containsKey(match.Team1__c)) {
                Team_Group__c newTG = new Team_Group__c(Group__c = groupId, Account__c = match.Team1__c, Goals_For__c = 0, Goals_Against__c = 0, Matches_Played__c = 0, Wins__c = 0, Losses__c = 0, Draws__c = 0, Points__c = 0);
                newTeamGroups.add(newTG);
                groupTeams.get(groupId).put(match.Team1__c, newTG);
            }
    
            // Ensure Team2 is in the group and update its stats
            if (!groupTeams.get(groupId).containsKey(match.Team2__c)) {
                Team_Group__c newTG = new Team_Group__c(Group__c = groupId, Account__c = match.Team2__c, Goals_For__c = 0, Goals_Against__c = 0, Matches_Played__c = 0, Wins__c = 0, Losses__c = 0, Draws__c = 0, Points__c = 0);
                newTeamGroups.add(newTG);
                groupTeams.get(groupId).put(match.Team2__c, newTG);
            }
    
            Team_Group__c tg1 = groupTeams.get(groupId).get(match.Team1__c);
            Team_Group__c tg2 = groupTeams.get(groupId).get(match.Team2__c);
    
            // Update stats for Team1
            tg1.Goals_For__c += match.Team1_Goals__c;
            tg1.Goals_Against__c += match.Team2_Goals__c; 
            tg1.Matches_Played__c += 1;
    
            // Update stats for Team2
            tg2.Goals_For__c += match.Team2_Goals__c;
            tg2.Goals_Against__c += match.Team1_Goals__c; 
            tg2.Matches_Played__c += 1;
    
            if (match.Team1_Goals__c > match.Team2_Goals__c) {
                tg1.Wins__c += 1;
                tg1.Points__c += 3;
                tg2.Losses__c += 1;
            } else if (match.Team1_Goals__c < match.Team2_Goals__c) {
                tg2.Wins__c += 1;
                tg2.Points__c += 3;
                tg1.Losses__c += 1;
            } else {
                tg1.Draws__c += 1;
                tg1.Points__c += 1;
                tg2.Draws__c += 1;
                tg2.Points__c += 1;
            }
    
            updatedTeamGroups.add(tg1);
            updatedTeamGroups.add(tg2);
        }
    
        if (!newTeamGroups.isEmpty()) {
            insert newTeamGroups;
        }
    
        if (!updatedTeamGroups.isEmpty()) {
            update updatedTeamGroups;
        }
    }


        public void validateMatchEligibility(List<Match__c> matches) {
            Set<Id> teamIds = new Set<Id>();
            for (Match__c match : matches) {
                teamIds.add(match.Team1__c);
                teamIds.add(match.Team2__c);
            }
    
            // Query to get the last match each team played
            Map<Id, Match__c> lastMatchMap = new Map<Id, Match__c>();
            for (Match__c lastMatch : [
                SELECT Id, Team1__c, Team2__c, Team1_Goals__c, Team2_Goals__c, Knockout_Stage__c, Match_Date__c, Approved__c,Home_Team_Penalty__c,Away_Team_Penalties__c
                FROM Match__c
                WHERE  (Team1__c IN :teamIds OR Team2__c IN :teamIds)
                ORDER BY Match_Date__c DESC, LastModifiedDate DESC
            ]) {
                if (lastMatch.Team1__c != null && !lastMatchMap.containsKey(lastMatch.Team1__c)) {
                    lastMatchMap.put(lastMatch.Team1__c, lastMatch);
                }
                if (lastMatch.Team2__c != null && !lastMatchMap.containsKey(lastMatch.Team2__c)) {
                    lastMatchMap.put(lastMatch.Team2__c, lastMatch);
                }
            }
    
            for (Match__c match : matches) {
                if (match.Knockout_Stage__c == 'Quarter-finals' ||
                    match.Knockout_Stage__c == 'Semi-finals' ||
                    match.Knockout_Stage__c == 'Finals') {
                    validateKnockoutMatch(match, lastMatchMap);
                } else if (match.Knockout_Stage__c == 'Third-place') {
                    validateThirdPlaceMatch(match, lastMatchMap);
                }
            }
        }
    
        private void validateKnockoutMatch(Match__c match, Map<Id, Match__c> lastMatchMap) {
            Match__c team1LastMatch = lastMatchMap.get(match.Team1__c);
            Match__c team2LastMatch = lastMatchMap.get(match.Team2__c);
    
            if (team1LastMatch == null || team2LastMatch == null) {
                match.addError('One or both teams do not have previous match data.');
                return;
            }
    
            Boolean team1WonLastMatch = (team1LastMatch.Team1__c == match.Team1__c && team1LastMatch.Team1_Goals__c > team1LastMatch.Team2_Goals__c) ||
                                        (team1LastMatch.Team2__c == match.Team1__c && team1LastMatch.Team2_Goals__c > team1LastMatch.Team1_Goals__c);
    
            Boolean team2WonLastMatch = (team2LastMatch.Team1__c == match.Team2__c && team2LastMatch.Team1_Goals__c > team2LastMatch.Team2_Goals__c) ||
                                        (team2LastMatch.Team2__c == match.Team2__c && team2LastMatch.Team2_Goals__c > team2LastMatch.Team1_Goals__c);
            
            // Check for penalty wins if scores are tied
            if (team1LastMatch.Team1_Goals__c == team1LastMatch.Team2_Goals__c) {
                team1WonLastMatch = team1LastMatch.Team1__c == match.Team1__c && team1LastMatch.Home_Team_Penalty__c > team1LastMatch.Away_Team_Penalties__c ||
                                    team1LastMatch.Team2__c == match.Team1__c && team1LastMatch.Away_Team_Penalties__c > team1LastMatch.Home_Team_Penalty__c;
            }

            if (team2LastMatch.Team1_Goals__c == team2LastMatch.Team2_Goals__c) {
                team2WonLastMatch = team2LastMatch.Team1__c == match.Team2__c && team2LastMatch.Home_Team_Penalty__c > team2LastMatch.Away_Team_Penalties__c ||
                                    team2LastMatch.Team2__c == match.Team2__c && team2LastMatch.Away_Team_Penalties__c > team2LastMatch.Home_Team_Penalty__c;
            }

            if (!team1WonLastMatch || !team2WonLastMatch) {
                match.addError('Both teams must have won their last match to proceed.');
            }
        }
    
        private void validateThirdPlaceMatch(Match__c match, Map<Id, Match__c> lastMatchMap) {
            List<Match__c> semiFinalMatches = [
                SELECT Id, Team1__c, Team2__c, Team1_Goals__c, Team2_Goals__c
                FROM Match__c
                WHERE Knockout_Stage__c = 'Semi-finals'
                AND (Team1__c = :match.Team1__c OR Team2__c = :match.Team1__c OR
                     Team1__c = :match.Team2__c OR Team2__c = :match.Team2__c)
            ];
    
            Set<Id> semiFinalLosers = new Set<Id>();
            for (Match__c semiFinal : semiFinalMatches) {
                if (semiFinal.Team1_Goals__c < semiFinal.Team2_Goals__c) {
                    semiFinalLosers.add(semiFinal.Team1__c);
                }
                if (semiFinal.Team2_Goals__c < semiFinal.Team1_Goals__c) {
                    semiFinalLosers.add(semiFinal.Team2__c);
                }
            }
    
            if (!semiFinalLosers.contains(match.Team1__c) || !semiFinalLosers.contains(match.Team2__c)) {
                match.addError('Both teams must have lost their semifinal match to play in the third place match.');
            }
        }    
    
}
