function apObj=jdPTBcreateSound(soundName) 
    switch lower(soundName)
        case 'correct'
            apObj=audioplayer(jdPTBmakeWave(110*8,0.04,.75,12000),12000);
        case 'wrong'
            apObj=audioplayer(jdPTBmakeWave(110,0.08,0,12000),12000);
        otherwise
            error(['Unknown soundName: ' soundName]);
    end
end
        