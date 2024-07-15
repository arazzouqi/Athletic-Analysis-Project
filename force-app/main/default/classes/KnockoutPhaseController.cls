public with sharing class KnockoutPhaseController {
    

  
        @AuraEnabled(cacheable=true)
        public static List<Match__c> getmatchsById(Id matchId){   
            return [SELECT Team1__r.Name,Team1_Goals__c,Team1__r.Team_Logo__c,Team2__r.Name,Team2__r.Team_Logo__c,Team2_Goals__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Id=:matchId WITH USER_MODE ];
         } 


         @AuraEnabled(cacheable=true)
        public static List<Match__c> getGameResultsByCompetitionFirstRound(Id matchId){   

            return [SELECT Id,Team1__r.Name,Team1__r.Team_Logo__c ,Team1_Goals__c,Team2__r.Name,Team2__r.Team_Logo__c ,Team2_Goals__c,Match_Date__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Tournament__c=:matchId AND Knockout_Stage__c='Round of 16' WITH USER_MODE ORDER BY Match_Date__c ASC ];
         }  
         @AuraEnabled(cacheable=true)
        public static List<Match__c> getGameResultsByCompetitionSecondRound(Id matchId){   
            return [SELECT Id,Team1__r.Name,Team1_Goals__c,Team1__r.Team_Logo__c ,Team2__r.Name,Team2__r.Team_Logo__c,Team2_Goals__c,Match_Date__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Tournament__c=:matchId AND Knockout_Stage__c='Quarter-finals' WITH USER_MODE ORDER BY Match_Date__c ASC ];
         }  
         @AuraEnabled(cacheable=true)
        public static List<Match__c> getGameResultsByCompetitionSemiFinals(Id matchId){   
            return [SELECT Id,Team1__r.Name,Team1_Goals__c,Team1__r.Team_Logo__c ,Team2__r.Name,Team2__r.Team_Logo__c,Team2_Goals__c,Match_Date__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Tournament__c=:matchId AND Knockout_Stage__c='Semi-finals' WITH USER_MODE ORDER BY Match_Date__c ASC ];
         } 
         @AuraEnabled(cacheable=true)
         public static List<Match__c> getGameResultsByCompetitionPlacementGame(Id matchId){   
             return [SELECT Id,Team1__r.Name,Team1_Goals__c,Team1__r.Team_Logo__c ,Team2__r.Name,Team2__r.Team_Logo__c,Team2_Goals__c,Match_Date__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Tournament__c=:matchId  AND Knockout_Stage__c='Third-place' WITH USER_MODE ORDER BY Match_Date__c ASC ];
          } 
          
          @AuraEnabled(cacheable=true)
         public static List<Match__c> getGameResultsByCompetitionFinals(Id matchId){   
             return [SELECT Id,Team1__r.Name,Team1_Goals__c,Team1__r.Team_Logo__c ,Team2__r.Name,Team2__r.Team_Logo__c,Team2_Goals__c,Match_Date__c,Away_Team_Penalties__c,Home_Team_Penalty__c FROM Match__c WHERE Tournament__c=:matchId  AND Knockout_Stage__c='Finals' WITH USER_MODE ORDER BY Match_Date__c ASC ];
          } 
  




}
