import { LightningElement, api, wire } from 'lwc';
import getGroupById from '@salesforce/apex/GroupController.getGroupById';
import cssstyle from '@salesforce/resourceUrl/cssstyle'
import { loadStyle } from 'lightning/platformResourceLoader';

const columns = [
    { label: 'Team', fieldName: 'teamName', type: 'text', cellAttributes: { class: { fieldName: 'accountColor' } } },
    { label: 'MP', fieldName: 'matchesPlayed', type: 'number', cellAttributes: { class: { fieldName: 'accountColor' } } },
    { label: 'GF', fieldName: 'goalsFor', type: 'number', cellAttributes: { class: { fieldName: 'accountColor' } } },
    { label: 'GA', fieldName: 'goalsAgainst', type: 'number', cellAttributes: { class: { fieldName: 'accountColor' } } },
    { label: 'GD', fieldName: 'goalDifference', type: 'number', cellAttributes: { class: { fieldName: 'accountColor' } } },
    { label: 'Points', fieldName: 'points', type: 'number', cellAttributes: { class: { fieldName: 'accountColor' } } },
];

export default class Group extends LightningElement {
    @api recordId;
    results = [];
    columns = columns;
    isCssLoaded = false;

    renderedCallback() {
        if (this.isCssLoaded) return;
        this.isCssLoaded = true;
        loadStyle(this, cssstyle).then(() => {
            console.log("Loaded Successfully");
        }).catch(error => {
            console.error("Error in loading the cssstyle");
        });
    }

    @wire(getGroupById, { groupId: '$recordId' })
    wiredGroups({ data, error }) {
        if (data) {
            this.results = data.map((record, index) => ({
                index: index + 1,
                id: record.id,
                teamName: record.teamName,
                matchesPlayed: record.matchesPlayed > 3 ? 3 : record.matchesPlayed,
                goalsFor: record.goalsFor,
                goalsAgainst: record.goalsAgainst,
                goalDifference: record.goalDifference,
                points: record.points,
                accountColor: index === 0 && record.points != 0 || index === 1 && record.matchesPlayed != 0 ? 'datatable-orange' : null
            }));
        } else {
            console.error('Error fetching data:', error);
        }
    }
}
