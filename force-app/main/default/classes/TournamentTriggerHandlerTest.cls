@isTest
public class TournamentTriggerHandlerTest {
    @isTest
    static void testAfterInsert() {
        // Create a Tournament
        Tournament__c tournament = new Tournament__c(Name = 'Test Tournament', Year__c = 2022, Status__c = 'Draft');
        Test.startTest();
        insert tournament;
        Test.stopTest();
        
        // Verify Groups are created with correct names
        List<Group__c> groups = [SELECT Name, Tournament__c FROM Group__c WHERE Tournament__c = :tournament.Id ORDER BY Name];
        System.assertEquals(8, groups.size(), 'Eight groups should be created.');
        System.assertEquals('Group A', groups[0].Name);
        System.assertEquals('Group B', groups[1].Name);
        System.assertEquals('Group C', groups[2].Name);
        System.assertEquals('Group D', groups[3].Name);
        System.assertEquals('Group E', groups[4].Name);
        System.assertEquals('Group F', groups[5].Name);
        System.assertEquals('Group G', groups[6].Name);
        System.assertEquals('Group H', groups[7].Name);
        for (Group__c g : groups) {
            System.assertEquals(tournament.Id, g.Tournament__c, 'Groups should be associated with the correct tournament.');
        }
    }
}
