function userName=dpxGetUserName    
    try
        userName = java.lang.System.getProperty('user.name');
        userName = char(userName); % cast to regular matlab char-array
    catch
        userName = 'Unknown';
    end
end