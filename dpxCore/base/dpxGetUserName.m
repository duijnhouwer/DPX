function user_name=dpxGetUserName

%function user_name=dpxGetUserName

if isunix % Mac OS X is a Unix
    [~, user_name]=system('$USER');
elseif ispc
    [~, user_name]=system('echo %USERNAME%'); % Not as familiar with windows,
else
    user_name='Unknown';
    warning('Only works on unix and pc');
end
user_name=strtrim(user_name);