#include <utils>
#include <tgconnector>

#define TG_BOT_TOKEN "2003549499:AAEH0TD_KT8ns2Z9Nez3FYzl7OGuUMAHchs"

new TGBot:tgHandle;

main(){
    tgHandle=TGConnect(TG_BOT_TOKEN);
    if(tgHandle != INVALID_BOT_ID){
        printf("Prohor Mitrich started");
    }
    else{
        printf("Prohor Mitrich not started");
    }
}

public OnTGMessage(TGBot:bot,TGUser:fromid,TGMessage:messageid){
    if(tgHandle == bot){
        new message[128],
            username[24],
            chatname[56];
        new TGChatId:chatid[128];
        
        TGCacheGetMessage(message,sizeof(message));
        TGCacheGetUserName(username,sizeof(username));
        TGCacheGetChatId(chatid,sizeof(chatid));
        TGCacheGetChatName(chatname,sizeof(chatname));

        TGSendMessage(tgHandle,chatid,"ответ",messageid);

        printf("[%s] %s(%d): %s",_:chatid,username,_:fromid,message);
    }
    return true;
}