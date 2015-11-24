function tc=calcDirectionTuningCurveSfTfContrast(dpxd,cellNr,varargin)
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, it's output can be plot with the
    % complementary plotDirectionTuningCurveSfTfContrast
    %
    % This function is a wrapper to the calcDirectionTuningCurve. This function
    % splits the structure according to spatial frequency (SF) temporal
    % frequency (TF) and contrast, and then passes the result to
    % calcDirectionTuningCurve to get a direction for each subset of data.
    %
    % See also: plotDirectionTuningCurveSfTfContrast
    
    % Standard: if the argument to this function is 'info', return for what
    % level of analysis it was designed for (e.g., 'cell'). This is required
    % functionality for all the lkDpxGratingExpAnalysis functions
    if nargin==1 && strcmp(dpxd,'info')
        tc.per='cell';
        return;
    end
    tc={};
    splitidx=0;
    if ~isfield(dpxd,'test_contrastFrac')
        % This is probably a RDK stimulus, this is how contrast is defined in the
        % experiment function:
        %   bright=E.scr.backRGBA(1)+E.scr.backRGBA(1)*cont; % single value between [0..1]
        %   dark=E.scr.backRGBA(1)-E.scr.backRGBA(1)*cont; % single value between [0..1]
        %   S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
        %   S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
        % As a check, calculate cont both from dotRBGAfrac1 and dotRBGAfrac2 and
        % see if they are the same, as they should be.
        cont1=[dpxd.test_dotRBGAfrac1{:}]./[dpxd.scr_backRGBA{:}]-1;
        cont1=cont1(1:4:end);
        cont2=-[dpxd.test_dotRBGAfrac2{:}]./[dpxd.scr_backRGBA{:}]+1;
        cont2=cont2(1:4:end);
        if ~all(cont1-cont2==0)
            error('Contrast was not defined as expected.');
        end
        % As an additional test see if the RGB values were the same for all dots,
        % as they should be
        RGBA1=reshape([dpxd.test_dotRBGAfrac1{:}],4,[]);
        if ~all(std(RGBA1(1:3,:))==0)
            error('RGB values of test_dotRBGAfrac1 were supposed to be identical');
        end
        RGBA2=reshape([dpxd.test_dotRBGAfrac2{:}],4,[]);
        if ~all(std(RGBA2(1:3,:))==0)
            error('RGB values of test_dotRBGAfrac2 were supposed to be identical');
        end
        dpxd.test_contrastFrac=cont1;
        % Also make up test_cyclesPerSecond and test_cyclesPerSecond fields for
        % this RDK experiment
        if any(isfield(dpxd,{'test_cyclesPerDeg','test_cyclesPerSecond'}))
        	error('This does not seem to be an RDK after all!!');
        end
        dpxd.test_cyclesPerDeg=repmat(lkSettings('SFFIX',dpxd.exp_startTime(1)),1,dpxd.N);
        dpxd.test_cyclesPerSecond=dpxd.test_speedDps.*dpxd.test_cyclesPerDeg;
    end
    
    C=dpxdSplit(dpxd,'test_contrastFrac');
    
    for c=1:numel(C)
        CS=dpxdSplit(C{c},'test_cyclesPerDeg');
        for s=1:numel(CS)
            CST=dpxdSplit(CS{s},'test_cyclesPerSecond');
            for t=1:numel(CST)
                KK=calcDirectionTuningCurve(CST{t},cellNr,varargin{:}); % KK = Komplete+Komponents
                % Since february 2015 or so calcDirectionTuningCurve returns a cell-array
                % with first element the analysis ran on all the (merged) data and the
                % optional other elements ran on components of the data (individual runs).
                % calcDirectionTuningCurveSfTfContrast will henceforth (date>30-Mar-2015)
                % also output a cell array like that.
                splitidx=splitidx+1;
                for iKK=1:numel(KK)
                    tc{iKK}{splitidx}=KK{iKK}; %#ok<AGROW>
                    tc{iKK}{splitidx}.contrast=CST{t}.test_contrastFrac(1); %#ok<AGROW>
                    tc{iKK}{splitidx}.SF=CST{t}.test_cyclesPerDeg(1);
                    tc{iKK}{splitidx}.TF=CST{t}.test_cyclesPerSecond(1);
                    tc{iKK}{splitidx}.DPS=CST{t}.test_cyclesPerSecond(1)./CST{t}.test_cyclesPerDeg(1);
                end
            end
        end
    end
    for i=1:numel(tc)
        tc{i}=dpxdMerge(tc{i});
    end
end