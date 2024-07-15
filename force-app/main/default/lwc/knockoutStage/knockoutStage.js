import { LightningElement, track, api, wire } from 'lwc';
import getGameResultsByCompetitionFirstRound from '@salesforce/apex/KnockoutPhaseController.getGameResultsByCompetitionFirstRound';
import getGameResultsByCompetitionSecondRound from '@salesforce/apex/KnockoutPhaseController.getGameResultsByCompetitionSecondRound';
import getGameResultsByCompetitionSemiFinals from '@salesforce/apex/KnockoutPhaseController.getGameResultsByCompetitionSemiFinals';
import getGameResultsByCompetitionPlacementGame from '@salesforce/apex/KnockoutPhaseController.getGameResultsByCompetitionPlacementGame';
import getGameResultsByCompetitionFinals from '@salesforce/apex/KnockoutPhaseController.getGameResultsByCompetitionFinals';
import IMAGE_URL from "@salesforce/resourceUrl/MA";

export default class KnockoutStage extends LightningElement {
    @api recordId;
   
    @track results = [];
    matches16 = [];
    @track allRounds = [
        {
            id: 'roundOf16',
            name: 'Round of 16',
            class: 'bracket round-of-16',
            classe:'',
            matches: []
        },
        {
            id: 'quarterfinals',
            name: 'Quarterfinals',
            class: 'bracket',
            classe:'quarterfinals',
            matches: [
                { id: 'match9', team1: 'Team 1', team2: 'Team 3', winner: 'Team 1' },
                { id: 'match10', team1: 'Team 5', team2: 'Team 7', winner: 'Team 5' },
                { id: 'match11', team1: 'Team 9', team2: 'Team 11', winner: 'Team 9' },
                { id: 'match12', team1: 'Team 13', team2: 'Team 15', winner: 'Team 13' }
            ]
        },
        {
            id: 'semifinals',
            name: 'Semifinals',
            class: 'bracket',
            classe:'semifinals',
            matches: [
                { id: 'match13', team1: 'Team 1', team2: 'Team 5', winner: 'Team 1' },
                { id: 'match14', team1: 'Team 9', team2: 'Team 13', winner: 'Team 13' }
            ]
        },
        {
            id: 'placementGame',
            name: 'Placement Game',
            class: 'bracket ',
            classe:'final',
            matches: [
                { id: 'match15', team1: 'Team 1', team2: 'Team 13', winner: 'Team 1' }
            ]
        },
        {
            id: 'final',
            name: 'Final',
            class: 'bracket ',
            classe:'final',
            matches: [
                { id: 'match15', team1: 'Team 1', team2: 'Team 13', winner: 'Team 1' }
            ]
        }
    ];

    @wire(getGameResultsByCompetitionFirstRound, { competitionId: '$recordId' })
    getGameResultsByCompetitionFirstRound({ error, data }) {
        if (data) {
            this.results = data;
            this.updateRoundOf16Matches(this.results);
         } else if (error) {
            console.error('Error fetching game results:', error);
            this.error = error;
        }
    }
    @wire(getGameResultsByCompetitionSecondRound, { competitionId: '$recordId' })
    getGameResultsByCompetitionSecondRound({ error, data }) {
        if (data) {
            this.results = data;
            this.updateRoundOf8Matches(this.results);
         } else if (error) {
            console.error('Error fetching game results:', error);
            this.error = error;
        }
    }
    @wire(getGameResultsByCompetitionSemiFinals, { competitionId: '$recordId' })
    getGameResultsByCompetitionSemiFinals({ error, data }) {
        if (data) {
            this.results = data;
            this.updateRoundOf4Matches(this.results);
         } else if (error) {
            console.error('Error fetching game results:', error);
            this.error = error;
        }
    }
    @wire(getGameResultsByCompetitionPlacementGame, { competitionId: '$recordId' })
    getGameResultsByCompetitionPlacementGame({ error, data }) {
        if (data) {
            this.results = data;
            this.updateRoundOfplacementGameMatches(this.results);
         } else if (error) {
            console.error('Error fetching game results:', error);
            this.error = error;
        }
    }
    @wire(getGameResultsByCompetitionFinals, { competitionId: '$recordId' })
    getGameResultsByCompetitionFinals({ error, data }) {
        if (data) {
            this.results = data;
            this.updateRoundOffinalGameMatches(this.results);
         } else if (error) {
            console.error('Error fetching game results:', error);
            this.error = error;
        }
    }
    
    //Id,,Score_Home__c,Away_Team__r.Name,Score_Away__c,StartDate__c,Penalty_Away__c,Penalty_Home__c
    updateRoundOf16Matches(data) {
    
        let roundOf16 = this.allRounds.find(round => round.id === 'roundOf16');
        if (roundOf16) {
            roundOf16.matches = data.map(game => ({
                id: match.Id,
                team1: match.Team1__r.Name,
                score1: match.Team1_Goals__c,
                penalty1: match.Home_Team_Penalty__c,
                team2: match.Team2__r.Name,
                score2: match.Team2_Goals__c,
                penalty2: match.Away_Team_Penalties__c,
                imageUrl1: `/resource/${match.Team1__r.Team__r.Team_Logo__c}`,
                imageUrl2: `/resource/${match.Team2__r.Team__r.Team_Logo__c}`,
                hadPenalty: match.Penalty_Home__c != null || game.Penalty_Away__c != null// Check if either penalty is not null
           
              
            }));
            // Trigger LWC reactivity by copying allRounds
            this.allRounds = [...this.allRounds];
        }
    }
    updateRoundOf8Matches(data) {
      
        let roundOf8 = this.allRounds.find(round => round.id === 'quarterfinals');
        if (roundOf8) {
            roundOf8.matches = data.map(game => ({
                id: match.Id,
                team1: match.Team1__r.Name,
                score1: match.Team1_Goals__c,
                penalty1: match.Home_Team_Penalty__c,
                team2: match.Team2__r.Name,
                score2: match.Team2_Goals__c,
                penalty2: match.Away_Team_Penalties__c,
                imageUrl1: `/resource/${match.Team1__r.Team__r.Team_Logo__c}`,
                imageUrl2: `/resource/${match.Team2__r.Team__r.Team_Logo__c}`,
                hadPenalty: match.Penalty_Home__c != null || game.Penalty_Away__c != null// Check if either penalty is not null
           
              
            }));
            // Trigger LWC reactivity by copying allRounds
            this.allRounds = [...this.allRounds];
        }
    }
    updateRoundOf4Matches(data) {
   
        let roundOf4 = this.allRounds.find(round => round.id === 'semifinals');
        if (roundOf4) {
            roundOf4.matches = data.map(game => ({
                id: match.Id,
                team1: match.Team1__r.Name,
                score1: match.Team1_Goals__c,
                penalty1: match.Home_Team_Penalty__c,
                team2: match.Team2__r.Name,
                score2: match.Team2_Goals__c,
                penalty2: match.Away_Team_Penalties__c,
                imageUrl1: `/resource/${match.Team1__r.Team__r.Team_Logo__c}`,
                imageUrl2: `/resource/${match.Team2__r.Team__r.Team_Logo__c}`,
                hadPenalty: match.Penalty_Home__c != null || game.Penalty_Away__c != null// Check if either penalty is not null
           
              
            }));
            // Trigger LWC reactivity by copying allRounds
            this.allRounds = [...this.allRounds];
        }
    }
    updateRoundOfplacementGameMatches(data) {
   
        let placementGame = this.allRounds.find(round => round.id === 'placementGame');
        if (placementGame) {
            placementGame.matches = data.map(game => ({
                id: match.Id,
                team1: match.Team1__r.Name,
                score1: match.Team1_Goals__c,
                penalty1: match.Home_Team_Penalty__c,
                team2: match.Team2__r.Name,
                score2: match.Team2_Goals__c,
                penalty2: match.Away_Team_Penalties__c,
                imageUrl1: `/resource/${match.Team1__r.Team__r.Team_Logo__c}`,
                imageUrl2: `/resource/${match.Team2__r.Team__r.Team_Logo__c}`,
                hadPenalty: match.Penalty_Home__c != null || game.Penalty_Away__c != null// Check if either penalty is not null
           
              
            }));
            // Trigger LWC reactivity by copying allRounds
            this.allRounds = [...this.allRounds];
        }
    }
    updateRoundOffinalGameMatches(data) {
   
        let final = this.allRounds.find(round => round.id === 'final');
        if (final) {
            final.matches = data.map(game => ({
                id: match.Id,
                team1: match.Team1__r.Name,
                score1: match.Team1_Goals__c,
                penalty1: match.Home_Team_Penalty__c,
                team2: match.Team2__r.Name,
                score2: match.Team2_Goals__c,
                penalty2: match.Away_Team_Penalties__c,
                imageUrl1: `/resource/${match.Team1__r.Team__r.Team_Logo__c}`,
                imageUrl2: `/resource/${match.Team2__r.Team__r.Team_Logo__c}`,
                hadPenalty: match.Penalty_Home__c != null || game.Penalty_Away__c != null // Check if either penalty is not null
           
              
            }));
            // Trigger LWC reactivity by copying allRounds
            this.allRounds = [...this.allRounds];
        }
    }
    
    
    
}