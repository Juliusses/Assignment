trigger LeadTrigger on Lead( after insert, after update, before insert, before update) {
    LeadTriggerHandler handler = new LeadTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if( Trigger.isInsert ){
        if(Trigger.isBefore) {
            handler.OnBeforeInsert(trigger.New); // To populate country attributes
        }
        /*else {
            handler.OnAfterInsert(trigger.New);
        }*/
    }
    else if ( Trigger.isUpdate ) {
        if(Trigger.isBefore){
            handler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap); // to check if country has changed, and populate current country attributes
        }
        /*else{
            handler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }*/
    }
}