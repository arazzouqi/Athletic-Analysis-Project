import { LightningElement, track, wire } from 'lwc';
import getTeamMatches from '@salesforce/apex/TeamMatchesController.getTeamMatches';
import getTeams from '@salesforce/apex/TeamMatchesController.getTeams';

export default class TeamMatches extends LightningElement {
    @track teams = [];
    @track selectedTeamId;
    @track matches;
    @track error;

    @wire(getTeams)
    wiredTeams({ error, data }) {
        if (data) {
            this.teams = data.map(team => ({
                label: team.Name,
                value: team.Id
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.teams = [];
        }
    }

    handleTeamChange(event) {
        this.selectedTeamId = event.detail.value;
    }

    handleFetchMatches() {
        if (this.selectedTeamId) {
            getTeamMatches({ teamId: this.selectedTeamId })
                .then(data => {
                    this.matches = data.map(match => ({
                        ...match,
                        isPenalty: match.Team1_Goals__c == match.Team2_Goals__c && (match.Penalty_Home__c != null && match.Penalty_Away__c != null)
                    }));
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.matches = undefined;
                });
        }
    }
}
