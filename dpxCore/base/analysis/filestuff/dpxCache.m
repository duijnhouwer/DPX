function [out,foundInCache]=dpxCache(setget,propertyName,value)
    
    % [out,foundInCache]=dpxCache(setget,propertyName,value)
    % save or load a value to the dpxCache file which is stored in the user's
    % tempdir.
    % ARGUMENTS:
    %   setget: 'set' or 'get' to save or load respectively
    %   propertyName: the name of the property (string)
    %   value: the value to save, or to use when the property is not present
    %       in the cache file.
    %
    % EXAMPLES:
    %   dpxCache('set','workdir',pwd)
    %   workdir=dpxCache('get','workdir',pwd)
    %       retrieve workdir, return or pwd if no varianle 'workdir' is found
    %   [~,foundInCache]=dpxCache('get','workdir',pwd)
    %       foundInCache indicates variable was found in cache true or false,
    %       can be used to trigger warnings etc.
    %
    % Jacob 2015-08-06
    
    out=[];
    foundInCache=false;
    if ~ischar(setget) || ~any(strcmpi(setget,{'get','set','clear'}))
        error('First argument must be string ''set'', ''get'', or ''clear''.');
    end
    if nargin>=2
        if ~ischar(propertyName)
            error('propertyName should be a string');
        else
            propertyName=lower(propertyName);
        end
    end
    cachefilename=fullfile(tempdir,'dpxCache.mat');
    if ~exist(cachefilename,'file')
        % Create a fresh cache
        save(cachefilename,'cachefilename');
        cachecreationdate=datestr(now);
        save(cachefilename,'cachecreationdate','-append');
    end
    
    if strcmpi(setget,'set')
        eval([propertyName '=value;'])
        save(cachefilename,propertyName,'-append');
        out=value; % not really necessary or usefull, but otherwise []
    elseif strcmpi(setget,'get')
        if nargin==1
            try
                out=load(cachefilename);
            catch ME
                warning(ME.message)
                out=[];
            end
        elseif nargin==2
            error('1 or 3 arugments required if first argument is get (3rd is alternative value in case property is not found in the cache)');
        elseif nargin==3
            try
                oldwarn=warning;
                warning('off','all');
                K=load(cachefilename,propertyName);
                out=K.(propertyName);
                foundInCache=true;
                warning(oldwarn);
            catch ME
                warning(oldwarn);
                if nargout==2
                    warning(ME.message);
                end
                out=value;
            end
        end
    elseif strcmpi(setget,'clear')
        fname=dpxCache('get','cachefilename','');
        if ~isempty(fname)
            try
                delete(fname);
                out=fname;
            catch ME
                warning(ME.message);
            end
        else
            % This should be impossible, if the file doesn't exist it should have been
            % created at the top of this function
            warning('Could not clear cacheFile');
        end    
    end
end