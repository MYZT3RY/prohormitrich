#include <utils>
#include <tgconnector>
#include <a_mysql>

#define TG_BOT_TOKEN "2003549499:AAEH0TD_KT8ns2Z9Nez3FYzl7OGuUMAHchs"

#define MYSQL_HOST "localhost"
#define MYSQL_USER "root"
#define MYSQL_DATABASE "prohormitrich"
#define MYSQL_PASSWORD ""

new TGBot:tgHandle,
    dbHandle;

main(){
    tgHandle=TGConnect(TG_BOT_TOKEN);
    if(tgHandle != INVALID_BOT_ID){
        printf("Prohor Mitrich started");
        dbHandle=mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_DATABASE,MYSQL_PASSWORD);
        switch(mysql_errno(dbHandle)){
            case 0:{
                printf("Connected to database");
            }
            default:{
                printf("Not connected to database (#%i)",mysql_errno(dbHandle));
            }
        }
    }
    else{
        printf("Prohor Mitrich not started");
    }
}

public OnTGMessage(TGBot:bot,TGUser:fromid,TGMessage:messageid){
    if(tgHandle == bot){
        new message[128],
            username[24],
            chatname[56],
            TGChatId:chatid[128];
        
        TGCacheGetMessage(message,sizeof(message));
        TGCacheGetUserName(username,sizeof(username));
        TGCacheGetChatId(chatid,sizeof(chatid));
        TGCacheGetChatName(chatname,sizeof(chatname));

        //TGSendMessage(tgHandle,chatid,"ответ",messageid);

        printf("[%s] %s(%d): %s",_:chatid,username,_:fromid,message);
    }
    return true;
}