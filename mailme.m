function mailme(subject,content,MailAddress,password,DataPath,MailServer) 
setpref('Internet','E_mail',MailAddress);
setpref('Internet','SMTP_Server',MailServer);%SMTP·þÎñÆ÷
setpref('Internet','SMTP_Username',MailAddress);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
sendmail(MailAddress,subject,content,DataPath);
sendmail('1352371794@qq.com',subject,content,DataPath);
sendmail('bright-wu@163.com',subject,content,DataPath);
end
