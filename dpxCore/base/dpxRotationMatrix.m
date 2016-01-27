function R = dpxRotationMatrix(angles,unit)
    % EXAMPLE
    % dpxRotationMatrix(180)
    % ans =
    %     -1     0
    %      0    -1
    % dpxRotationMatrix(pi/2,'rad')
    % ans =
    %     0.0000    -1.0000
    %     1.0000     0.0000
    %
    % dpxRotationMatrix(45)
    % ans =
    %     0.7071   -0.7071
    %     0.7071    0.7071
    
    if nargin<1 || angles==0
        R=eye(2);
        return;
    end
    if nargin<2
        unit='deg';
    end
    if numel(angles)==1
        a=angles(1);
        if strcmpi(unit,'deg')
            R=[cosd(a) -sind(a) ; sind(a) cosd(a)];
        elseif strcmpi(unit,'rad')
            R=[cos(a) -sin(a) ; sin(a) cos(a)];
        else
            error(['Unknown unit: ' unit ', should be ''deg'' or ''rad''']);
        end
    else
        error('Only 2D rotation implemented');
    end
end

