function [x] = haralickTextureFeatures(coOcMat, xFeatures)
%Calculates all Haralick Features.
%
% Function call:
%   [x] = haralickTextureFeatures(coOcMat) calculates all 14 Haralick
%   Features
%	[x] = haralickTextureFeatures(coOcMat, xFeatures) calculates the
%	Haralick Features specified by xFeatures, the rest will be return as 0.
%	Use this for better legacy
% if you do not need all Haralick Features.
%
% Source:           http://haralick.org/journals/TexturalFeatures.pdf
%
% input:
%   'coOcMat'       Co-Occurence-Matrix,  which must be a [nxm] matrix,
%                   see matlab documentation glcm
%   'xFeatures'     (optional) - Feature(s), which should be calculated
%
% output:           
%   'x' - [vector with the following feature(s):
%               x(1)  Angular Second Moment (Energy) [checked]
%               x(2)  Contrast [checked]
%               x(3)  Correlation [checked]
%               x(4)  Variance [checked]
%               x(5)  Inverse Difference Moment (Homogeneity) [checked]
%               x(6)  Sum Average [checked]
%               x(7)  Sum Variance [approxemitly (cut out zeros)]
%               x(8)  Sum Entropy [checked]
%               x(9)  Entropy [cut out zeros]
%               x(10) Difference Variance [approxemitly]
%               x(11) Difference Entropy [checked]
%               x(12) Information Measure of Correlation I [checked]
%               x(13) Information Measure of Correlation II [approxemitly]
%               x(14) Maximal Correlation Coefficient [no reference]  
%
% Notes:        If x14 Maximal Correlation Coefficient is complex then the
%               magnitude of MCC will be calculate.
%               See the haralick paper to understand the code.
%
% Author:       Rune Monzel, runemonzel(at)gmail.com
%
% See also graycomatrix, graycoprops.

% check input
if nargin == 1
    xFeatures = 1 : 14;
end

% check coOcMat for dimensions:
if ~(ismatrix(coOcMat)) %mengecek input matriks atau bukan
    error(['\coOcMatInput must be a two dimensional matrix, '...
        'dimensional was %s.',ndims(coOcMat)']); %menyebutkan dimensi matriks
end

% initialize x
x = zeros(14,1); 

% normalize glcm
coOcMat = coOcMat./sum(coOcMat(:));

%% Some pre-calculation:
% columns and rows
if sum(xFeatures == 2) == 1 | ... % Contrast
        sum(xFeatures == 3) == 1 | ... % Correlation
        sum(xFeatures == 4) == 1 | ... % Variance
        sum(xFeatures == 5) == 1 | ... % Inverse Difference Moment
        sum(xFeatures == 6) == 1 | ... % Sum Average
        sum(xFeatures == 7) == 1 | ... % Sum Variance
        sum(xFeatures == 8) == 1 | ... % Sum Entropy
        sum(xFeatures == 10) == 1 | ...% Difference Variance
        sum(xFeatures == 11) == 1 | ...% Difference Entropy
        sum(xFeatures == 14) == 1 % Maximal Correlation Coefficient
    sizecoOcMat = size(coOcMat);
    [col,row] = meshgrid(1:sizecoOcMat(1),1:sizecoOcMat(2));
end

% average and standarddeviation
if sum(xFeatures == 3) == 1 | ... % correlation
        sum(xFeatures == 10) == 1 % difference variance
    
    
    rowMean =  sum( row(:).*coOcMat(:) );
    colMean = sum( col(:).*coOcMat(:) );
    rowStd = sqrt( sum( (row(:)-rowMean).^2 .* coOcMat(:) ) );
    colStd = sqrt( sum( (col(:)-colMean).^2 .* coOcMat(:) ) );
end

% sum of rows p_y(i) und sum of columns p_x(j)
if sum(xFeatures == 12) == 1 |...% Information Measures of Correlation I
        sum(xFeatures == 13) == 1|... % Information Measures of Correlation II
        sum(xFeatures == 14) == 1 % Maximal Correlation Coefficient
    
    rowCoOcMat = sum(coOcMat,2); %sum of rows p_y(i)
    colCoOcMat = sum(coOcMat); %sum of columns p_x(i)
end

% p_x+y
if sum(xFeatures == 6)==1 |... % Sum Average
        sum(xFeatures == 7)==1 |... % Sum Variance
        sum(xFeatures == 8)==1 % Sum Entropy
 a =  sizecoOcMat(1);
 b = sizecoOcMat(2);
    start = -(sizecoOcMat(1) -1);
    stop = sizecoOcMat(1) -1;
    
    % Rotate Matrix 90�
    coOcMat90 = rot90(coOcMat);
    
    % Initilisiere p_x+y
    p_XplusY = zeros((2*sizecoOcMat(1))-1,1);
    
    k = 1;
    for index = start : stop
        p_XplusY(k) = sum( diag(coOcMat90,index) );
        k = k + 1;
    end
end

% Initialize  p_x-y
if sum(xFeatures == 10)==1 |... % Difference Variance
        sum(xFeatures == 11)==1 % Difference Entropy
    
    start = 1;
    stop = sizecoOcMat(1)-1;
    
    % Initialize p_XminusY
    p_XminusY = zeros(sizecoOcMat(1),1);
    p_XminusY(1) = sum (diag(coOcMat,0) );
    
    k = 2;
    for index = start : stop
        p_XminusY(k) = sum( [diag(coOcMat,index);
            diag(coOcMat,-index)] );
        k = k + 1;
    end
end


%% Haralick Feature Calculations
for f = xFeatures
    switch f
        case 1 % Energy (Angular Second Moment)
            x(1) = sum( coOcMat(:).^2 );
            
        case 2  % Contrast
            matrix = ( abs(row - col).^2 ) .* coOcMat;
            x(2) = sum( matrix(:) );
            
        case 3  % Correlation
            zaehler = sum ((row(:) - rowMean) .*...
                (col(:) - colMean) .*  coOcMat(:));
            denominator = rowStd * colStd;
            x(3) = zaehler/denominator;
            
        case 4 % Variance
            x(4) = sum( (row(:)-mean(coOcMat(:))).^2 .*coOcMat(:) );
            
        case 5 % Inverse Difference Moment
            x(5) = sum( coOcMat(:) ./ ( 1+ (row(:)-col(:)).^2 ) );
            
        case 6 % Sum Average
            x(6) = sum( (2:(2*sizecoOcMat(1)))' .* p_XplusY );
            
        case 7 % Sum Variance
            x(8) = - sum( p_XplusY(p_XplusY~=0) .* ...
                log(p_XplusY(p_XplusY~=0)) );
            
            x(7) = sum( ((2:(2*sizecoOcMat(1)))' -...
                x(12)).^2 .* p_XplusY  );
            
        case 8 % Sum Entropy
            if ~x(8) % if it is not calculate in case 7
                x(8) = - sum( p_XplusY(p_XplusY~=0) .*...
                    log(p_XplusY(p_XplusY~=0)) );
            end
            
        case 9 % Entropy
            x(9) = - sum( coOcMat(coOcMat~=0) .*...
                log2(coOcMat(coOcMat~=0)) );
            
        case 10 % Difference Variance
            x(10) = sum( ((0:sizecoOcMat(1)-1)' -...
                mean(p_XminusY)).^2 .* p_XminusY);
            
        case 11 % Difference Entropy
            x(11) = - sum( p_XminusY(p_XminusY~=0) .*...
                log(p_XminusY(p_XminusY~=0)) );
            
        case 12 % Information Measures of Correlation I
            
            x(9) = - sum( coOcMat(coOcMat~=0) .*...
                log2(coOcMat(coOcMat~=0)) );
            
            % Cuto out all zeros:
            logrc  = log2( rowCoOcMat*colCoOcMat ); % 256x1 * 1x256
            %Matrixmultiplication
            logrc(logrc == -Inf) = 0; % cut out Inf
            HXY1 = - sum( coOcMat(:).* logrc(:) ); %product of elements
            % between co-occurence-matrix and the logarithmetic matrix
            numerator = x(9) - HXY1;
            
            % calculate off HX, Entropy of sum of columns
            logc = log2(colCoOcMat);
            logc(logc==-Inf) = 0;
            HX = - sum( colCoOcMat .* logc );
            
            % calculate off HY, Entropy of sum of columns
            logr = log2( rowCoOcMat );
            logr(logr==-Inf) = 0;
            HY = - sum( rowCoOcMat .* logr );
            
            % max value
            denominator = max([HX HY]);
            x(12) = numerator / denominator;
            
        case 13 % Information Measures of Correlation II
            if x(9)
                x(9) = - sum( coOcMat(coOcMat~=0) .*...
                    log2(coOcMat(coOcMat~=0)) );
            end
            logrc  = log2( rowCoOcMat*colCoOcMat ); % 256x1 * 1x256
            %Matrixmultiplication
            logrc(logrc == -Inf) = 0;
            HXY2 = - sum( sum( (rowCoOcMat * colCoOcMat) .* logrc ));
            x(13) =  (  ( 1 - exp(-2*(HXY2 - x(9))) )  ).^(1/2);
            
        case 14 % Maximal Correlation Coefficient
            
            % Initialise Q
            Q = zeros(sizecoOcMat(1),sizecoOcMat(2));
            
            for i = 1 : sizecoOcMat(1)
                Q(i,:) = ( coOcMat(i,:)./rowCoOcMat(i) ) .*...
                    sum( coOcMat(i,:).*colCoOcMat );
            end
            
            % cut out nans
            Q(isnan(Q)) = 0;
            
            eigenvec = eig(Q);
            
            % Find largest eigenvec and delete
            eigenvec(eigenvec==max(eigenvec))=[];
            
            % Sqrt of second largest eigenvec
            x(14) = sqrt( max(eigenvec) );
            
            % calculate magnitude of Maximal Correlation Coefficient
            if imag(x(14))
                x(14) = abs(x(14));
            end
            
    end
end

% ===== 1 Fitur =====
%x = [x(2)]; %Kontras
%x = [x(3)]; %Korelasi
%x = [x(1)]; %Energi
%x = [x(5)]; %Homogenitas
%x = [x(4)]; %Varian 
%x = [x(6)]; %Sum Average
%x = [x(7)]; %Sum Variance

% ===== 2 Fitur =====
%x = [x(2) x(3)]; %Kontras Korelasi
%x = [x(2) x(1)]; %Kontras Energi
%x = [x(2) x(5)]; %Kontras Homogenitas
%x = [x(2) x(4)]; %Kontras Varian
%x = [x(2) x(6)]; %Kontras Sum Average
%x = [x(2) x(7)]; %Kontras Sum Variance
%x = [x(3) x(1)]; %Korelasi Energi
%x = [x(3) x(5)]; %Korelasi Homogenitas
%x = [x(3) x(4)]; %Korelasi Varian
%x = [x(3) x(6)]; %Korelasi Sum Average
%x = [x(3) x(7)]; %Korelasi Sum Variance
%x = [x(1) x(5)]; %Energi Homogenitas
%x = [x(1) x(4)]; %Energi Varian
%x = [x(1) x(6)]; %Energi Sum Average
%x = [x(1) x(7)]; %Energi Sum Variance
%x = [x(5) x(4)]; %Homogenitas Varian
%x = [x(5) x(6)]; %Homogenitas Sum Average
%x = [x(5) x(7)]; %Homogenitas Sum Variance
%x = [x(4) x(6)]; %Varian Sum Average
%x = [x(4) x(7)]; %Varian Sum Variance

% ===== 3 Fitur =====
%x = [x(2) x(3) x(1)]; %Kontras Korelasi Energi
%x = [x(2) x(3) x(5)]; %Kontras Korelasi Homogenitas
%x = [x(2) x(3) x(4)]; %Kontras Korelasi Varian
%x = [x(2) x(3) x(6)]; %Kontras Korelasi Sum Average
%x = [x(2) x(3) x(7)]; %Kontras Korelasi Sum Variance
%x = [x(2) x(1) x(5)]; %Kontras Energi Homogenitas
%x = [x(2) x(1) x(4)]; %Kontras Energi Varian
x = [x(2) x(1) x(6)]; %Kontras Energi Sum Average
%x = [x(2) x(1) x(7)]; %Kontras Energi Sum Variance
%x = [x(2) x(5) x(4)]; %Kontras Homogenitas Varian
%x = [x(2) x(5) x(6)]; %Kontras Homogenitas Sum Average
%x = [x(2) x(5) x(7)]; %Kontras Homogenitas Sum Variance
%x = [x(2) x(4) x(6)]; %Kontras Varian Sum Average
%x = [x(2) x(4) x(7)]; %Kontras Varian Sum Variance
%x = [x(2) x(6) x(7)]; %Kontras Sum Average Sum Variance

% ===== 4 Fitur =====
%x = [x(2) x(3) x(1) x(5)]; %Kontras Korelasi Energi Homogenitas
%x = [x(2) x(3) x(1) x(4)]; %Kontras Korelasi Energi Varian
%x = [x(2) x(3) x(1) x(6)]; %Kontras Korelasi Energi Sum Average
%x = [x(2) x(3) x(1) x(7)]; %Kontras Korelasi Energi Sum Variance
%x = [x(2) x(3) x(5) x(4)]; %Kontras Korelasi Homogenitas Varian
%x = [x(2) x(3) x(5) x(6)]; %Kontras Korelasi Homogenitas Sum Average
%x = [x(2) x(3) x(5) x(7)]; %Kontras Korelasi Homogenitas Sum Variance
%x = [x(2) x(1) x(5) x(4)]; %Kontras Energi Homogenitas Varian
%x = [x(2) x(1) x(5) x(6)]; %Kontras Energi Homogenitas Sum Average
%x = [x(2) x(1) x(5) x(7)]; %Kontras Energi Homogenitas Sum Variance
%x = [x(2) x(5) x(4) x(6)]; %Kontras Homogenitas Varian Sum Average
%x = [x(2) x(5) x(4) x(7)]; %Kontras Homogenitas varian Sum Variance
%x = [x(2) x(4) x(6) x(7)]; %Kontras Varian Sum Average Sum Variance
%x = [x(3) x(1) x(5) x(4)]; %Korelasi Energi Homogenitas Varian
%x = [x(3) x(1) x(5) x(6)]; %Korelasi Energi Homogenitas Sum Average
%x = [x(3) x(1) x(5) x(7)]; %Korelasi Energi Homogenitas Sum Variance
%x = [x(3) x(1) x(4) x(6)]; %Korelasi Energi Variance Sum Average
%x = [x(3) x(1) x(4) x(7)]; %Korelasi Energi Variance Sum Variance
%x = [x(3) x(5) x(4) x(6)]; %Korelasi Homogenitas Variance Sum Average
%x = [x(3) x(5) x(4) x(7)]; %Korelasi Homogenitas Variance Sum Variance
%x = [x(3) x(4) x(6) x(7)]; %Korelasi Variance Sum Average Sum Variance
%x = [x(1) x(5) x(4) x(6)]; %Energi Homogenitas Variance Sum Average
%x = [x(1) x(5) x(4) x(7)]; %Energi Homogenitas Variance Sum Variance
%x = [x(1) x(5) x(6) x(7)]; %Energi Homogenitas Sum Average Sum Variance
%x = [x(1) x(4) x(6) x(7)]; %Energi Variance Sum Average Sum Variance
%x = [x(5) x(4) x(6) x(7)]; %Homogenitas Variance Sum Average Sum Variance

% ===== 5 Fitur =====
%x = [x(2) x(3) x(1) x(5) x(4)]; %Kontras Korelasi Energi Homogenitas Varian
%x = [x(2) x(3) x(1) x(5) x(6)]; %Kontras Korelasi Energi Homogenitas Sum Average
%x = [x(2) x(3) x(1) x(5) x(7)]; %Kontras Korelasi Energi Homogenitas Sum Variance
%x = [x(2) x(3) x(1) x(4) x(6)]; %Kontras Korelasi Energi Varian Sum Average
%x = [x(2) x(3) x(1) x(4) x(7)]; %Kontras Korelasi Energi Varian Sum Variance
%x = [x(2) x(3) x(5) x(4) x(6)]; %Kontras Korelasi Homogenitas Varian Sum Average
%x = [x(2) x(3) x(5) x(4) x(7)]; %Kontras Korelasi Homogenitas Varian Sum variance
%x = [x(2) x(1) x(5) x(4) x(6)]; %Kontras Energi Homogenitas Varian Sum Average
%x = [x(2) x(1) x(5) x(4) x(7)]; %Kontras Energi Homogenitas Varian Sum Variance
%x = [x(2) x(5) x(4) x(6) x(7)]; %Kontras Homogenitas Varian Sum Average Sum Variance
%x = [x(3) x(1) x(5) x(4) x(6)]; %Korelasi Energi Homogenitas Varian Sum Average
%x = [x(3) x(1) x(5) x(4) x(7)]; %Korelasi Energi Homogenitas Varian Sum Variance
%x = [x(3) x(1) x(5) x(6) x(7)]; %Korelasi Energi Homogenitas Sum Average Sum Variance
%x = [x(3) x(1) x(4) x(6) x(7)]; %Korelasi Energi Varian Sum Average Sum Variance
%x = [x(3) x(5) x(4) x(6) x(7)]; %Korelasi Homogenitas Varian Sum Average Sum Variance
%x = [x(1) x(5) x(4) x(6) x(7)]; %Energi Homogenitas Varian Sum Average Sum Variance

% ===== 6 Fitur =====
%x = [x(2) x(3) x(1) x(5) x(4) x(6)]; %Kontras Korelasi Energi Homogenitas Varian Sum Average
%x = [x(2) x(3) x(1) x(5) x(4) x(7)]; %Kontras Korelasi Energi Homogenitas Varian Sum Variance
%x = [x(2) x(3) x(1) x(5) x(6) x(7)]; %Kontras Korelasi Energi Homogenitas Sum Average Sum Variance 
%x = [x(2) x(3) x(1) x(4) x(6) x(7)]; %Kontras Korelasi Energi Varian Sum Average Sum Variance
%x = [x(2) x(3) x(5) x(4) x(6) x(7)]; %Kontras Korelasi Homogenitas Varian Sum Average Sum Variance
%x = [x(2) x(1) x(5) x(4) x(6) x(7)]; %Kontras Energi Homogenitas Varian Sum Average Sum variance
%x = [x(3) x(1) x(5) x(4) x(6) x(7)]; %Kontras Energi Homogenitas Varian Sum Average Sum Variance

% ===== 7 Fitur =====
%x = [x(2) x(3) x(1) x(5) x(4) x(6) x(7)];
end