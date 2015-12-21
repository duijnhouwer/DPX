function varargout= subsref(d,subscript)
% function value= subsref(c,subscript)
% Subsref for Circular objects.
%
% BK  - 27.7.2001  - Last Change $Date: 2001/08/02 01:02:03 $ by $Author: bart $
% $Revision: 1.3 $
% JG - 29.7.2010 - expanding to handle array of circular objects

if length(subscript) >1
    error(d, 'Calling subsref with more than one level of subscript');
else
    varargout=cell(size(d,1),(size(d,2)));
    if ~ischar(subscript.subs)
        varargout{1}=d(subscript.subs{:});
    else
        for i =1:(size(d,1)*size(d,2))
            c=d(i);
            switch subscript.type
                case '.'
                    switch upper(subscript.subs)
                        case 'X'
                            val = pol2cart(c.phi,c.r);
                        case 'Y'
                            [~,val] = pol2cart(c.phi,c.r);
                        case {'RADIANS','RAD'}
                            val = c.phi;
                        case {'DEGREES','DEG'}
                            val = c.phi*180/pi;
                        case 'PHI'
                            if strcmpi(c.units,'deg')
                                val = c.phi*180/pi;
                            elseif strcmpi(c.units,'rad')
                                val = c.phi;
                            end
                        case 'R'
                            val   = c.r;
                        case 'MEAN'
                            val = mstd(c);
                        case 'MEDIAN'
                            val =median(c);
                        case 'N'
                            val = c.n;
                        case 'AXIAL'
                            val =c.axial;
                        otherwise
                            val=['''' subscript.subs ''' is not a public circular property.'];
                            warning(val);
                    end
                    
                    varargout{i}=val;
                    
                    
                otherwise %Not a . subscript
                    warning(['Dont know what to do with this subscript:''' subscript.subs ''''],mfilename)
            end
        end
        
    end
end
