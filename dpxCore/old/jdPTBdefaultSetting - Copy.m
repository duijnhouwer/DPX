function  def=jdPTBdefaultSetting(str)
    % DEF=jdPTBdefaultSetting(STR)
    % jacob 2015-05-26
    %
    % DO NOT EDIT THESE DEFAULTS, OVERRULE OR ADD FIELDS IN YOUR
    % EXPERIMENT'S SETTINGS FILE. YOU CAN ADD CASES (BUT DON'T ADD THEM TO
    % COMMON)
    
    def.enable=true;
    switch lower(str)
        case 'background'
            def.RGBAfrac=[0.5 0.5 0.5 1];
        case 'fixation'
            def.shape='dot';
            def.xDeg=0;
            def.yDeg=0;
            def.wDeg=.25; % width of marker, used as diam for shape 'dot'
            def.hDeg=.25; % height of marker, ignored for shape 'dot'
            def.RGBAfrac1=[1 0 0 1];
        case 'response'
            def.keys='LeftArrow,RightArrow'; % use KbName to find key-names
            def.maxReactionTimeSecs=3;
            def.endsTrial=true; % end the trial when response is given
        case 'feedback'
            def.visual.enable=true;
            def.correctResp='LeftArrow'; % a key or a num2str(probablity) randomly correct (e.g., '1' when coherence is 0 in 2AFC task)
            def.visual.diamDeg=.5;
            def.visual.correctRGBAfrac=[0 1 0 .5];
            def.correctSecs=.025;
            def.wrongSecs=.1;
            def.visual.wrongRGBAfrac=[0 0 0 .75];
            def.audio.enable=false;
            def.audio.correct=[];
            def.audio.false=[];
        case 'common'
            def.background=jdPTBdefaultSetting('background');
            def.fix=jdPTBdefaultSetting('fixation');
            def.resp=jdPTBdefaultSetting('response');
            def.resp.feedback=jdPTBdefaultSetting('feedback');
        case 'stimbasics'
            def.onSecs=.25;
            def.durSecs=.75;
            def.apert=jdPTBdefaultSetting('aperture');
        case 'aperture'
            def.shape='circle';
            def.wDeg=10;
            def.hDeg=10;
            def.xDeg=0;
            def.yDeg=0;
        case 'hardware'
            def.screen=jdPTBdefaultSetting('screen');
        case 'screen'
            def.distMm=1000;
            def.gamma=1; % to linearize luminances
            def.widHeiMm=[]; % [] triggers autodetection (may fail silently)
            def.stereoMode='mono'; % 'mono','mirror'
            def.window=[]; % [] is full screen , 'small' is small for debugging
        case 'instructions'
            def.start='Press a key, release to start.';
            def.pause.txt='I N T E R M I S S I O N\n\nPress a key, release to continue.';
            def.pause.nTrials=Inf;
        otherwise
            error(['Unknown jdPTBdefaultSetting: ' str ]);
    end
end