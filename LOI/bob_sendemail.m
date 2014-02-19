function bob_sendemail(to,subject,message,attachment)
% BOB_SENDEMAIL  Send email from a gmail account
%
% USAGE: bob_sendemail(to,subject,message,attachment)
%
% ARGUMENTS:
%   to:                the email address to send to
%   subject:        the email subject line
%   message:      the email message
%   attachment:  the file(s) to attach (can be a string or cell array of strings)
%
% Written by Bob Spunt, Februrary 22, 2013
% Based on code provided by Pradyumna
% ------------------------------------------------------------------

% ==========================
% gmail account from which to send email 
% --------------------------------
% email = 'neurospunt@gmail.com';
email = 'caltech.brainresearch@gmail.com';
password = 'socialbrain';
% ==========================

% check arguments
if nargin == 3
    attachment = '';
end

% set up gmail SMTP service
setpref('Internet','E_mail',email);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',email);
setpref('Internet','SMTP_Password',password);

% gmail server
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% send
if isempty(attachment)
    sendmail(to,subject,message);
else
    sendmail(to,subject,message,attachment)
end

end
