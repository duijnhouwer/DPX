function agDpxDDQObliqueAnalysis(D)
    
    % agDpxDDQObliqueAnalysis(data)
    % Analysis accompanying the agDpxDDQOblique function
    %
    % See also: agDpxDDQOblique
    %
    % Jacob Duijnhouwer, 2014-10-14
    
    % Remove all antiJump trials, these were only included to prevent the
    % observer being able to predict the final orientation of the stimulus
    % from the initial orientation
    D=dpxdSubset(D,D.ddq_antiJump==0);
    % Add an explicit Aspect Ratio field
    D.ddq_aspectRatio=D.ddq_hDeg./D.ddq_wDeg;
    % The observers indicated if the line through the second pair of dots
    % had a CW (rightarrow) or a CCW (leftarrow) orientation relative to
    % the line through the first pair. We will now convert these responses
    % to whether the dots jump parallel to the nominal orientation axis of
    % the DDQ (which corresponds to vertical in the standard, upright DDQ,
    % i.e., 0 degree orientation) or that the dots appeared to jump this
    % axis (horizontal in the standard DDQ).
    % 
    % First, for clarity, replace the names LeftArrow and Rightarrow by
    % what they meant:
    for tr=1:D.N
        if strcmpi(D.resp_kb_keyName{tr},'LeftArrow')
            D.resp_kb_keyName{tr}='CCW';
        else
            D.resp_kb_keyName{tr}='CW';
        end
    end  
    D=dpxdSplit(D,'ddq_oriDeg');
    for di=1:numel(D)
        CW=strcmpi(D{di}.resp_kb_keyName,'CW');
        BL=D{di}.ddq_bottomLeftTopRightFirst;
        D{di}.seenJumpAxis=CW & BL | ~CW & ~BL;
    end
    for di=1:numel(D)
        C=dpxdSplit(D{di},'ddq_aspectRatio');
        x=nan(1,numel(C));
        y=nan(1,numel(C));
        n=nan(1,numel(C));
        for ci=1:numel(C)
            x(ci)=C{ci}.ddq_aspectRatio(1);
            y(ci)=mean(C{ci}.seenJumpAxis);
            n(ci)=C{ci}.N;
        end
        F=dpxPsignifit;
        set(F,'X',log2(x),'Y',y,'N',n);
        markers=F.plotdata;
        hold on
        h(di)=F.plotfit;
        fitcol=get(h(di),'Color');
        set(markers,'MarkerFaceColor',fitcol,'MarkerEdgeColor',fitcol);
    end
    legend(h,{'0','45','90','135'});
end
    