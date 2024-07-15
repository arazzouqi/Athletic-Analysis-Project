trigger MatchTrigger on Match__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    MatchTriggerHandler handler = new MatchTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        } 
        
        if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } 
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        }
    }
}