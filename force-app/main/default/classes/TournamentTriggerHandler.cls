public with sharing class TournamentTriggerHandler {
    public void beforeInsert(List<Tournament__c> newTournaments) {
        // Logic for before insert
    }

    public void beforeUpdate(List<Tournament__c> newTournaments, Map<Id, Tournament__c> oldTournaments) {
        // Logic for before update
    }

    public void beforeDelete(List<Tournament__c> oldTournaments) {
        Set<Id> tournamentIds = new Set<Id>();
        for (Tournament__c tournament : oldTournaments) {
            tournamentIds.add(tournament.Id);
        }

        List<Group__c> groupsToDelete = [SELECT Id FROM Group__c WHERE Tournament__c IN :tournamentIds];

        if (!groupsToDelete.isEmpty()) {
            delete groupsToDelete;
        }
    }

    public void afterInsert(List<Tournament__c> newTournaments) {

        

        List<Group__c> newGroups = new List<Group__c>();
        String[] groupNames = new String[]{'Group A', 'Group B', 'Group C', 'Group D', 'Group E', 'Group F', 'Group G', 'Group H'};

        for (Tournament__c tournament : newTournaments) {
            Integer numberOfGroups = groupNames.size(); // Number of groups
            for (Integer i = 0; i < numberOfGroups; i++) {
                newGroups.add(new Group__c(
                    Name = tournament.Name+' '+groupNames[i],
                    Tournament__c = tournament.Id
                ));
            }

        
            if (tournament.Mock_Data__c) {
                TournamentMockDataBatch batch = new TournamentMockDataBatch(tournament.Id);
                Database.executeBatch(batch);
            }
        }
        if (!newGroups.isEmpty()) {
            insert newGroups;
        }
 
    }

   
 
}