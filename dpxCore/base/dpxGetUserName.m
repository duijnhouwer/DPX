function userName=dpxGetUserName    
    try
        userName = java.lang.System.getProperty('user.name');
    catch
        userName = 'Unknown';
    end
end