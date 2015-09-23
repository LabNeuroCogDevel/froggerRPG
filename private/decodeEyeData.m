function [x,y] = decodeEyeData(dataStream, xBytes, yBytes, bytesPerLine)
% [x,y] = decodeEyeData(dataStream, xBytes, yBytes)

% Private Function ASL_ConvertBytePairToInteger( intMSB As integer,
% intLSB As integer ) As integer
% 
%         ' Converts a byte-pair (represented as passed MSB and LSB integers)
%         ' into a single integer.  Handles both positive and negative integers.
% 
%         ' This is an internal routine, and is performed as part of the
%         ' initialization.  We therefore do not check for initialization of
%         ' the eye tracker here.
% 
% 
%         ' Positive integers are restored quite easily.
% 
%         If intMSB < 128 Then
%                 ASL_ConvertBytePairToInteger = (intMSB * 256) + intLSB
%                 Exit Function
%         End If
% 
% 
%         ' Negative integers are restored in a similar manner, but a subtraction
%         ' is also performed to account for the twos-complement storage.  Trust me,
%         ' it works.
% 
%         Dim longMSB As long
%         Dim longLSB As long
%         Dim longValue As long
% 
%         longMSB = intMSB
%         longLSB = intLSB
% 
%         longValue = ((longMSB * 256) + longLSB) - 65536
%         ASL_ConvertBytePairToInteger = longValue

nbytes = numel(dataStream);
numLines = ceil(nbytes / bytesPerLine);

% find first 128 as starting point
startInd = find(dataStream == 128, 1, 'first');
dataStream = dataStream(startInd:end);

dataStream = dataStream(1:bytesPerLine*floor(length(dataStream)/bytesPerLine));

x1inds = xBytes(1):bytesPerLine:numel(dataStream);
x2inds = xBytes(2):bytesPerLine:numel(dataStream);

y1inds = yBytes(1):bytesPerLine:numel(dataStream);
y2inds = yBytes(2):bytesPerLine:numel(dataStream);

x_msb = dataStream(x1inds);
x_lsb = dataStream(x2inds);

y_msb = dataStream(y1inds);
y_lsb = dataStream(y2inds);

%         If intMSB < 128 Then
%                 ASL_ConvertBytePairToInteger = (intMSB * 256) + intLSB
%                 Exit Function
%         End If
x = nan*ones(size(x_msb));
y = nan*ones(size(y_msb));

if sum(x_msb < 128) > 0
    x(x_msb < 128) = x_msb(x_msb < 128)*256 + x_lsb(x_msb < 128);
end
if sum(y_msb < 128) > 0
    y(y_msb < 128) = y_msb(y_msb < 128)*256 + y_lsb(y_msb < 128);
end

%         longValue = ((longMSB * 256) + longLSB) - 65536
%         ASL_ConvertBytePairToInteger = longValue
x(x_msb >= 128) = (x_msb(x_msb >= 128)*256 + x_lsb(x_msb >= 128)) - 65536;
y(y_msb >= 128) = (y_msb(y_msb >= 128)*256 + y_lsb(y_msb >= 128)) - 65536;


x = x/10;
y = y/10;

end