function revisionNr=dpxVersion(varargin)
    
    % revisionNr=dpxVersion(varargin)
    %
    % dpxVersion('svncompare',false,'offerupdate',false)
    %       returns current local DPX revision
    %
    % dpxVersion('svncompare',true,'offerupdate',false)
    %       returns current local DPX revision and notifies the availability of a new
    %       version in the SVN repository
    %
    % dpxVersion('offerupdate',true)
    %       returns current local DPX revision and notifies if newer
    %       version is available online and offers to update.
    %
    % dpxVersion without arguments is same as dpxVersion('offerupdate',true)
    %
    % Jacob 2014-06-11
    %
    % See also: dpxSystemInfo
    
    p = inputParser;   % Create an instance of the inputParser class.
    p.addOptional('svncompare',true,@(x)islogical(x) | x==1 | x==0);
    p.addOptional('offerupdate',true,@(x)islogical(x) | x==1 | x==0);
    p.parse(varargin{:});
    
    fp=mfilename('fullpath');
    DPXPATH=fp(1:strfind(fp,'dpxCore')-2); 
    % !svn update "C:\Users\jacob\Documents\MATLAB\DPX\" failed on SVN version 1.8.10 (r1615264) 
    % However, !svn update "C:\Users\jacob\Documents\MATLAB\DPX" DID work! Hence "-2" [Jacob 2014-10-21]
    try
        str=evalc(['!svn info "' DPXPATH '"']);
        revisionNr=extractNumber(str);
        if isnan(revisionNr)
            warning(str);
        end
    catch me
        warning(me.message);
    end
    
    try
        if p.Results.svncompare || p.Results.offerupdate
            disp(['Checking local DPX (version ' num2str(revisionNr) ') against ''https://github.com/duijnhouwer/dpx/trunk'' ...']);
            str=evalc('!svn info https://github.com/duijnhouwer/dpx/trunk');
            onlineVersion=extractNumber(str);
            if onlineVersion==revisionNr
                disp('You have the latest DPX.');
            elseif onlineVersion>revisionNr
                disp(['An updated DPX (' num2str(onlineVersion) ') is available online.']);
                if p.Results.offerupdate
                    a=input(['Do you wish to update your local DPX to revision ' num2str(onlineVersion) '? [y|N] > '],'s');
                    if strcmpi(strtrim(a),'y')
                        eval(['!svn update "' DPXPATH '"']);
                    end
                    revisionNr=dpxVersion('svncompare',false);
                    disp(['You now have the latest DPX revision (' num2str(revisionNr) ').']);
                else
                    disp('Run dpxVersion(''offerupdate'',true) to update your DPX.');
                end
            end
        end
    catch me
        warning(me.message);
    end
end


function num=extractNumber(str)
    match=regexp(str,'[\n\r]Revision:[ \w]*([^\n\r]*)','match');
    if isempty(match)
        num=nan;
    else
        match=regexp(match,' ','split');
        if isempty(match)
            num=nan;
        else
            num=str2double(match{1}{2});
        end
    end
end
