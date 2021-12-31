#include <utils>
#include <tgconnector>
#include <a_mysql>
#include <string>
#include <float>

#define TG_BOT_TOKEN "1472571056:AAFpUrV9KGf8OpUliFnzmiNbZPIEYTxgbJQ"

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
                mysql_set_charset("utf8",dbHandle);
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
            TGChatId:chatid[128],
            query[256];
        
        TGCacheGetMessage(message,sizeof(message));
        TGCacheGetUserName(username,sizeof(username));
        TGCacheGetChatId(chatid,sizeof(chatid));

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
            mysql_format(dbHandle,query,sizeof(query),"select*,DAY(NOW())-DAY(`dateofregister`)as`days`from`users`where`userid`='%i'and`chatid`='%e'",_:fromid,_:chatid);
            cache_users=mysql_query(dbHandle,query,true);

            if(cache_get_row_count(dbHandle)){
                new messages,
                    dateofregister[32],
                    days;

                messages=cache_get_field_content_int(0,"messages",dbHandle);
                cache_get_field_content(0,"dateofregister",dateofregister,dbHandle,sizeof(dateofregister));
                days=cache_get_field_content_int(0,"days",dbHandle);

                new Float:messagesperday=float(messages)/days;

                new string[2*157-(2*3)+32+11+11];

                format(string,sizeof(string),"Личная статистика в чате\n\nДата регистрации в чате - %s\nКоличество сообщений с момента регистрации в чате - %i\nСреднее количество сообщений в день в чате - %.2f",dateofregister,messages,messagesperday);
                TGSendMessage(tgHandle,chatid,string,messageid);

                cache_delete(cache_users,dbHandle);
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #2",messageid);
            }
        }
        else if(!strfind(message,"/stats")){
            mysql_format(dbHandle,query,sizeof(query),"select*,DAY(NOW())-DAY(`dateofregister`)as`days`from`chats`where`id`='%e'",_:chatid);
            cache_chats=mysql_query(dbHandle,query,true);

            if(cache_get_row_count(dbHandle)){
                mysql_format(dbHandle,query,sizeof(query),"select count(`id`)as`registeredusers`from`users`where`chatid`='%e'",_:chatid);
                cache_users=mysql_query(dbHandle,query,true);

                if(cache_get_row_count(dbHandle)){
                    new registeredusers;

                    registeredusers=cache_get_field_content_int(0,"registeredusers",dbHandle);

                    cache_delete(cache_users,dbHandle);
                    cache_set_active(cache_chats,dbHandle);

                    new messages,
                        dateofregister[32],
                        days;

                    messages=cache_get_field_content_int(0,"messages",dbHandle);
                    cache_get_field_content(0,"dateofregister",dateofregister,dbHandle,sizeof(dateofregister));
                    days=cache_get_field_content_int(0,"days",dbHandle);

                    new Float:messagesperday=float(messages)/days;

                    new totalusers;

                    totalusers=TGGetChatMembersCount(tgHandle,chatid);

                    new string[2*196-(2*2)+32+11];
                    
                    format(string,sizeof(string),"Статистика чата\n\nДата регистрации чата - %s\nКоличество сообщений с момента регистрации - %i\nСреднее количество сообщений в день - %.2f\nКоличество участников чата - %i (%i зарегистрированных)",dateofregister,messages,messagesperday,totalusers,registeredusers);
                    TGSendMessage(tgHandle,chatid,string,messageid);

                    cache_delete(cache_chats,dbHandle);
                }
                else{
                    TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #5",messageid);
                }
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #1",messageid);
            }
        }
        else if(!strfind(message,"/help")){
            TGSendMessage(tgHandle,chatid,"Список доступных команд\n\n/stats - просмотр статистики чата\n/statsme - просмотр личной статистики в чате\n/updates - просмотр последнего обновления бота\n/top - рейтинг участников чата",messageid);
        }
        else if(!strfind(message,"/updates")){
            new Cache:cache_updates=mysql_query(dbHandle,"select`text`from`updates`order by`id`desc",true);

            if(cache_get_row_count(dbHandle)){
                new text[1024];

                cache_get_field_content(0,"text",text,dbHandle,sizeof(text));

                TGSendMessage(tgHandle,chatid,text,messageid);

                cache_delete(cache_updates,dbHandle);
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #3",messageid);
            }
        }
        else if(!strfind(message,"/top")){
            mysql_format(dbHandle,query,sizeof(query),"select`username`,`messages`,DAY(NOW())-DAY(`dateofregister`)as`days`from`users`where`chatid`='%e'order by`messages`desc limit 10",_:chatid);
            cache_users=mysql_query(dbHandle,query,true);

            if(cache_get_row_count(dbHandle)){
                new localUsername[24],
                    messages,
                    days;

                new tempString[48-(2*4)+2+24+11+11],
                    string[28+2*sizeof(tempString)*10];

                strcat(string,"Рейтинг участников чата\n\n");

                for(new i=0; i<cache_get_row_count(dbHandle); i++){
                    cache_get_field_content(i,"username",localUsername,dbHandle,sizeof(username));
                    messages=cache_get_field_content_int(i,"messages",dbHandle);
                    days=cache_get_field_content_int(i,"days",dbHandle);

                    new Float:messagesperday=float(messages)/days;

                    format(tempString,sizeof(tempString),"%i. @%s (%i сообщений, %.2f сообщений в день)\n",i+1,username,messages,messagesperday);
                    strcat(string,tempString);
                }

                TGSendMessage(tgHandle,chatid,string,messageid);

                cache_delete(cache_users,dbHandle);
            }
            else{
                TGSendMessage(tgHandle,chatid,"Произошла ошибка при обработке вашего запроса!\n\nОшибка #4",messageid);
            }
        }

        printf("[%s] %s(%d): %s",_:chatid,username,_:fromid,message);
    }
    return true;
}