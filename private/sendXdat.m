% sendXdat(trigger) -- use pp from ratrix to send parallel port trigger
%  * where trigger can be 0 to 255 (8 bits)
%  * pp from https://code.google.com/p/ratrix/source/browse/classes/util/parallelPort/pp.m
%  * may need to change parallel port address "888" in future
%
% trigger is converted to binary, made into a 1/0 vector, and sent
function sendXdat(trigger)

    if ~ismac && IsWin
        outp( hex2dec('D070'), trigger);
    else
        try
           pins=9:(-1):2;
           xdatpinsbool = arrayfun( @(x) str2double(x), ...
                                    num2str(   dec2bin(trigger, 8)   )   );
           pp(uint8(pins),xdatpinsbool,false,uint8(0),uint64(888));
        catch
           warning('Failed to send xdat');
        end
    end
end

