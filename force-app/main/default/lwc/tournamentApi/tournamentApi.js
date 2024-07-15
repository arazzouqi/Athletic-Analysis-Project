import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTournamentResults from '@salesforce/apex/TeamMatchesController.getTournamentResults';

export default class TournamentApi extends LightningElement {
    @api recordId;
    @track matches;
    @track error;

    @wire(getTournamentResults, { tournamentId: '$recordId' })
    wiredResults({ error, data }) {

        console.log('Data', data); 
        console.log('DataSTRINGIFY', JSON.stringify(data)); 
        if (data) {
            this.matches = data.map(match => ({
                ...match,
                isPenalty: match.Team1_Goals__c === match.Team2_Goals__c && (match.Penalty_Home__c != null && match.Penalty_Away__c != null)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.matches = undefined;
            this.showToast('Error', 'Error fetching tournament results', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}