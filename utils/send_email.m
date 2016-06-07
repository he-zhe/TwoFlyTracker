function [  ] = send_email(title,content)


mail = ''; %Your GMail email address
password = '';  %Your GMail password
target = ''; %Your recipient email
setpref('Internet','SMTP_Server','smtp.gmail.com');


setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
% Send the email.  Note that the first input is the address you are sending the email to
sendmail('target',title,content)


end

