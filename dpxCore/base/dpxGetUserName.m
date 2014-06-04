function user_name=dpxGetUserName

%function user_name=jdGetUserName

if isunix % Mac OS X is a Unix
    [~, user_name]=system('whoami'); % exists on every unix that I know of
elseif ispc
    [~, user_name]=system('echo %USERDOMAIN%/%USERNAME%'); % Not as familiar with windows,
else
    user_name='Unknown';
    warning('Only works on unix and pc');
end
user_name=strtrim(user_name);