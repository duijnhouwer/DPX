function str=dpxSeconds2readable(seconds,format)

% str=seconds2readable(seconds,format)
% Return a legible time format string.
%
% Example:
% h=tic; pause(2);
% fprintf('Example finished in %s\n',seconds2readable(toc(h)));
%
% Jacob 2011-10-18


seconds=round(seconds);

if nargin==1
    format='shortest';
end

if strcmpi(format,'shortest')
    weeks=floor(seconds/3600/24/7);
    rem=mod(seconds,3600*24*7);
    days=floor(rem/3600/24);
    rem=mod(seconds,3600*24);
    hours=floor(rem/3600);
    rem=mod(seconds,3600);
    mins=floor(rem/60);
    secs=mod(rem,60);
    if weeks>0
        str=sprintf('%d week%s %d day%s %d hour%s %d minute%s %d second%s',weeks,pops(weeks),days,pops(days),hours,pops(hours),mins,pops(mins),secs,pops(secs));
    elseif days>0
        str=sprintf('%d day%s %d hour%s %d minute%s %d second%s',days,pops(days),hours,pops(hours),mins,pops(mins),secs,pops(secs));
    elseif hours>0
        str=sprintf('%d hour%s %d minute%s %d second%s',hours,pops(hours),mins,pops(mins),secs,pops(secs));
    elseif mins>0
        str=sprintf('%d minute%s %d second%s',mins,pops(mins),secs,pops(secs));
    else
        str=sprintf('%d second%s',secs,pops(secs));
    end
else
    error(['Unknown format: ' format]);
end


function s=pops(d)
% pop a plural s, or not
if d==1, s='';
else s='s';
end
