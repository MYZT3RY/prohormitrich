#include <utils>
#include <tgconnector>
#include <a_mysql>
#include <string>

#define TG_BOT_TOKEN ""

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
            TGChatId:chatid[128],
            query[256];
        
        TGCacheGetMessage(message,sizeof(message));
        TGCacheGetUserName(username,sizeof(username));
        TGCacheGetChatId(chatid,sizeof(chatid));
        TGCacheGetChatName(chatname,sizeof(chatname));

        mysql_format(dbHandle,query,sizeof(query),"select`id`from`chats`where`id`='%e'",_:chatid);
        new Cache:cache_chats=mysql_query(dbHandle,query,true);
        if(!cache_get_row_count(dbHandle)){
            cache_delete(cache_chats,dbHandle);
            mysql_format(dbHandle,query,sizeof(query),"insert into`chats`(`id`)values('%e')",_:chatid);
            mysql_query(dbHandle,query,false);
        }

        mysql_format(dbHandle,query,sizeof(query),"select`id`from`users`where`userid`='%i'and`chatid`='%e'",_:fromid,_:chatid);
        new Cache:cache_users=mysql_query(dbHandle,query,true);
        if(!cache_get_row_count(dbHandle)){
            cache_delete(cache_users,dbHandle);
            mysql_format(dbHandle,query,sizeof(query),"insert into`users`(`userid`,`username`,`chatid`)values('%i','%e','%e')",_:fromid,username,_:chatid);
            mysql_query(dbHandle,query,false);
        }
        else{
            mysql_format(dbHandle,query,sizeof(query),"update`users`set`messages`=`messages`+'1'where`userid`='%i'and`chatid`='%e'",_:fromid,_:chatid);
            mysql_query(dbHandle,query,false);
            mysql_format(dbHandle,query,sizeof(query),"update`chats`set`messages`=`messages`+'1'where`id`='%e'",_:chatid);
            mysql_query(dbHandle,query,false);
        }

        if(!strfind(message,"/statsme")){
            mysql_format(dbHandle,query,sizeof(query),"select*from`users`where`userid`='%i'and`chatid`='%e'",_:fromid,_:chatid);
            cache_users=mysql_query(dbHandle,query,true);
            if(cache_get_row_count(dbHandle)){
                new messages,
                    dateofregister[32];

                messages=cache_get_field_content_int(0,"messages",dbHandle);
                cache_get_field_content(0,"dateofregister",dateofregister,dbHandle,sizeof(dateofregister));

                new string[2*113-(2*2)+32+11];

                format(string,sizeof(string),"Личная статистика в чате\n\nДата регистрации в чате - %s\nКоличество сообщений с момента регистрации в чате - %i",dateofregister,messages);
                TGSendMessage(tgHandle,chatid,string,messageid);

                cache_delete(cache_users,dbHandle);
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #2",messageid);
            }
        }
        else if(!strfind(message,"/stats")){
            mysql_format(dbHandle,query,sizeof(query),"select*from`chats`where`id`='%e'",_:chatid);
            cache_chats=mysql_query(dbHandle,query,true);
            if(cache_get_row_count(dbHandle)){
                new messages,
                    dateofregister[32];

                messages=cache_get_field_content_int(0,"messages",dbHandle);
                cache_get_field_content(0,"dateofregister",dateofregister,dbHandle,sizeof(dateofregister));

                new string[2*95-(2*2)+32+11];

                format(string,sizeof(string),"Статистика чата\n\nДата регистрации чата - %s\nКоличество сообщений с момента регистрации - %i",dateofregister,messages);
                TGSendMessage(tgHandle,chatid,string,messageid);

                cache_delete(cache_chats,dbHandle);
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #1",messageid);
            }
        }
        else if(!strfind(message,"/help")){
            TGSendMessage(tgHandle,chatid,"Список доступных команд\n\n/stats - просмотр статистики чата\n/statsme - просмотр личной статистики в чате",messageid);
        }
        else if(!strfind(message,"/updates")){
            TGSendMessage(tgHandle,chatid,"Обновление 0.1\n\nДобавлен счётчик сообщений группы и пользователей.\nДобавлены команды /stats и /statsme",messageid);
        }

        printf("[%s] %s(%d): %s",_:chatid,username,_:fromid,message);
    }
    return true;
}