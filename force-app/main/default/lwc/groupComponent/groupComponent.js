import { LightningElement, api, wire } from 'lwc';
import getGroupsByTournament from '@salesforce/apex/GroupController.getGroupsByTournament';

export default class GroupsByTournament extends LightningElement {
    @api recordId;
    results = [];

    @wire(getGroupsByTournament, { tournamentId: '$recordId' })
    wiredGroupIds({ data, error }) {
        if (data) {
            this.results = data;            
            console.log(this.results);
        } else if (error) {
            console.error('Error fetching data:', error);
        }
    }
}
