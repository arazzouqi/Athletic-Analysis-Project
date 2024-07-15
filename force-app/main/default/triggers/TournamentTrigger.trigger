trigger TournamentTrigger on Tournament__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TournamentTriggerHandler handler = new TournamentTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isInsert){
            handler.afterInsert(Trigger.new);
        }
    }
    else if (Trigger.isBefore){
        if (Trigger.isDelete){
            handler.beforeDelete(Trigger.old);
        }
    }

    
}