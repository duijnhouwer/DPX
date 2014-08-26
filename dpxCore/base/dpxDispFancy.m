function dpxDispFancy(msg,sym,nh,nv)

% *********
% *  wow  *
% *********

if nargin==1
    sym='*';
    nh=1;
    nv=1;
elseif nargin==2
    nh=1;
    nv=1;
elseif nargin==3
    nv=1;
end

msg=[repmat(sym,1,nh) ' ' msg ' ' repmat(sym,1,nh) ];
disp(repmat(sym,nv,round(numel(msg)/numel(sym))));
disp(msg);
disp(repmat(sym,nv,round(numel(msg)/numel(sym))));