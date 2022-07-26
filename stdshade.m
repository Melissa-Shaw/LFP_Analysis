function [lineOut, fillOut] = stdshade(amatrix,alpha,acolor,smth,F)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assigns the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% smusall 2010/4/23
if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end
if exist('F','var')==0 || isempty(F)
    F=1:size(amatrix,2);
end
if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1; %no smoothing by default
end  
if ne(size(F,1),1)
    F=F';
end
amean = nanmean(amatrix,1); %get mean over first dimension
astd = nanstd(amatrix,[],1)/sqrt(size(amatrix,1)); %get SEM over first dimension (for std remove the '/sqrt(n)' )
if smth > 1
    %amean = boxFilter(nanmean(amatrix,1),smth); %use boxfilter to smooth data
    g = gausswin(smth); g = g/sum(g);
    amean = conv(nanmean(amatrix,1),g','same'); % use gausswin convolution to smooth data
    astd = conv(nanstd(amatrix,[],1),g','same')/sqrt(size(amatrix,1));
end

if exist('alpha','var')==0 || isempty(alpha) 
    fillOut = fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor='k';
else
    fillOut = fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none');
end
if ishold==0
    check=true; else check=false;
end
hold on;
lineOut = plot(F,amean, 'color', acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line
if check
    hold off;
end

%% Local Functions
function dataOut = boxFilter(dataIn, fWidth)
% apply 1-D boxcar filter for smoothing
fWidth = fWidth - 1 + mod(fWidth,2); %make sure filter length is odd
dataStart = cumsum(dataIn(1:fWidth-2),2);
dataStart = dataStart(1:2:end) ./ (1:2:(fWidth-2));
dataEnd = cumsum(dataIn(length(dataIn):-1:length(dataIn)-fWidth+3),2);
dataEnd = dataEnd(end:-2:1) ./ (fWidth-2:-2:1);
dataOut = conv(dataIn,ones(fWidth,1)/fWidth,'full');
dataOut = [dataStart,dataOut(fWidth:end-fWidth+1),dataEnd];
end

end