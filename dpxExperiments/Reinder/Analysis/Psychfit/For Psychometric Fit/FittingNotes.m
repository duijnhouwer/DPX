Level2 = 'X:\Daudi\Level2';
PSigDir = fullfile(Level2,'ExternalToolBoxes','Psignifit');
DLLDir = fullfile(Level2,'Level1','OtherAuthors','ClemensIvar');

rn(iLD,:,iPos) = [Ri (Le+Ri)];

S = SigFit([ilds rn(:,:,iPos)]);