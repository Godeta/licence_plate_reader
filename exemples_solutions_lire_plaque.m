%tests differentes manières de lire une plaque

close all;
clear all;
clc;

%choix de la fonction à utiliser
%exemple 1
result = detecterPlaque("BDD\car_img\101.png")
disp(['Plaque d''immatriculation détectée: ' result]);

%exemple 2
ret = numberPlateExtraction("BDD\car_img\101.png")

%exemple 3


%utilise readletter et nouvmodel.mat
function detectedPlate = detecterPlaque(imagePath)
    % Charger l'image
    img = imread(imagePath);
    
    % Convertir en niveaux de gris
    imgray = rgb2gray(img);
    
    % Binariser l'image
    BW = im2bw(imgray);
    
    % Appliquer le filtre de Prewitt pour la détection des bords
    img = edge(imgray, 'prewitt');

    % Trouver l'emplacement de la plaque d'immatriculation
    Iprops = regionprops(bwlabel(img),'BoundingBox','Area', 'Image');
    area = [Iprops.Area];
    [~, index] = max(area);
    boundingBox = Iprops(index).BoundingBox;

    % Recadrer la zone de la plaque d'immatriculation
    img = imcrop(BW, boundingBox);
    
    % Supprimer les petits objets
    img = bwareaopen(~img, 490);

    % Obtenir les dimensions de l'image
    [h, ~] = size(img);
    
    % Afficher l'image
    imshow(img);

    % Lire les lettres
    Iprops = regionprops(bwlabel(img),'BoundingBox','Area', 'Image');
    count = numel(Iprops);
    detectedPlate = ''; % Initialisation de la chaîne de la plaque d'immatriculation.

    for i = 1:count
       Ws = length(Iprops(i).Image(1,:));
       Hs = length(Iprops(i).Image(:,1));
       if Ws < (h/2) && Hs > (h/3)
           % Lire la lettre correspondant à l'image binaire
           letter = readLetter(Iprops(i).Image);
           % Ajouter chaque caractère à la variable detectedPlate
           detectedPlate = [detectedPlate letter];
       end
    end
end



function letter=readLetter(snap)

load NewTemplates 
snap=imresize(snap,[42 24]);
rec=[ ];

for n=1:length(NewTemplates)
    d=corr2(NewTemplates{1,n},snap); 
    rec=[rec d]; 
end

ind=find(rec==max(rec));
display(ind);

% Listes alphabétiques de A a Z
if ind==1 || ind==2
    letter='A';
elseif ind==3 || ind==4
    letter='B';
elseif ind==5
    letter='C';
elseif ind==6 || ind==7
    letter='D';
elseif ind==8
    letter='E';
elseif ind==9
    letter='F';
elseif ind==10
    letter='G';
elseif ind==11
    letter='H';
elseif ind==12
    letter='I';
elseif ind==13
    letter='J';
elseif ind==14
    letter='K';
elseif ind==15
    letter='L';
elseif ind==16
    letter='M';
elseif ind==17
    letter='N';
elseif ind==18
    letter='O';
elseif ind==20 || ind==21
    letter='P';
elseif ind==22 || ind==23
    letter='Q';
elseif ind==24 || ind==25
    letter='R';
elseif ind==26
    letter='S';
elseif ind==27
    letter='T';
elseif ind==28
    letter='U';
elseif ind==29
    letter='V';
elseif ind==30
    letter='W';
elseif ind==31
    letter='X';
elseif ind==32
    letter='Y';
elseif ind==33
    letter='Z';

    
% Listes de chiffres de 1 a 9
elseif ind==34
    letter='1';
elseif ind==35
    letter='2';
elseif ind==36
    letter='3';
elseif ind==37 || ind==38
    letter='4';
elseif ind==39
    letter='5';
elseif ind==40 || ind==41 || ind==42
    letter='6';
elseif ind==43
    letter='7';
elseif ind==44 || ind==45
    letter='8';
elseif ind==46 || ind==47 || ind==48
    letter='9';
elseif  ind==19
    letter='#';
else
    letter='0';
end
end

function ret = numberPlateExtraction(imgpath)
%NUMBERPLATEEXTRACTION extracts the characters from the input number plate image.

f=imread(imgpath); % Reading the number plate image.
f=imresize(f,[400 NaN]); % Resizing the image keeping aspect ratio same.
g=rgb2gray(f); % Converting the RGB (color) image to gray (intensity).
g=medfilt2(g,[3 3]); % Median filtering to remove noise.
se=strel('disk',1); % Structural element (disk of radius 1) for morphological processing.
gi=imdilate(g,se); % Dilating the gray image with the structural element.
ge=imerode(g,se); % Eroding the gray image with structural element.
gdiff=imsubtract(gi,ge); % Morphological Gradient for edges enhancement.
gdiff=mat2gray(gdiff); % Converting the class to double.
gdiff=conv2(gdiff,[1 1;1 1]); % Convolution of the double image for brightening the edges.
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1); % Intensity scaling between the range 0 to 1.
B=logical(gdiff); % Conversion of the class from double to binary. 
% Eliminating the possible horizontal lines from the output image of regiongrow
% that could be edges of license plate.
er=imerode(B,strel('line',50,0));
out1=imsubtract(B,er);
% Filling all the regions of the image.
F=imfill(out1,'holes');
% Thinning the image to ensure character isolation.
H=bwmorph(F,'thin',1);
H=imerode(H,strel('line',3,90));
% Selecting all the regions that are of pixel area more than 100.
final=bwareaopen(H,100);
imshow(final)
% final=bwlabel(final); % Uncomment to make compitable with the previous versions of MATLAB®
% Two properties 'BoundingBox' and binary 'Image' corresponding to these
% Bounding boxes are acquired.
Iprops=regionprops(final,'BoundingBox','Image');
% Selecting all the bounding boxes in matrix of order numberofboxesX4;
NR=cat(1,Iprops.BoundingBox);
% Calling of controlling function.
r=controlling(NR); % Function 'controlling' outputs the array of indices of boxes required for extraction of characters.
if ~isempty(r) % If succesfully indices of desired boxes are achieved.
    I={Iprops.Image}; % Cell array of 'Image' (one of the properties of regionprops)
    noPlate=[]; % Initializing the variable of number plate string.
    for v=1:length(r)
        N=I{1,r(v)}; % Extracting the binary image corresponding to the indices in 'r'.
        letter=readLetter2(N); % Reading the letter corresponding the binary image 'N'.
        while letter=='O' || letter=='0' % Since it wouldn't be easy to distinguish
            if v<=3                      % between '0' and 'O' during the extraction of character
                letter='O';              % in binary image. Using the characteristic of plates in Karachi
            else                         % that starting three characters are alphabets, this code will
                letter='0';              % easily decide whether it is '0' or 'O'. The condition for 'if'
            end                          % just need to be changed if the code is to be implemented with some other
            break;                       % cities plates. The condition should be changed accordingly.
        end
        noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
    end
    disp(noPlate)
    ret = noPlate;
    %fid = fopen('noPlate.txt', 'wt'); % This portion of code writes the number plate
    %fprintf(fid,'%s\n',noPlate);      % to the text file, if executed a notepad file with the
    %fclose(fid);                      % name noPlate.txt will be open with the number plate written.
    %winopen('noPlate.txt')
    
%     Uncomment the portion of code below if Database is  to be organized. Since my
%     project requires database so I have written this code. DB is the .mat
%     file containing the array of structure of all entries of database.
%     load DB
%     for x=1:length(DB)
%         recordplate=getfield(DB,{1,x},'PlateNumber');
%         if strcmp(noPlate,recordplate)
%             disp(DB(x));
%             disp('*-*-*-*-*-*-*');
%         end
%     end
    
else % If fail to extract the indexes in 'r' this line of error will be displayed.
    disp('Unable to extract the characters from the number plate.\n');
    disp('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end
end

function letter=readLetter2(snap)
%READLETTER reads the character fromthe character's binary image.
%   LETTER=READLETTER(SNAP) outputs the character in class 'char' from the
%   input binary image SNAP.

load NewTemplates % Loads the templates of characters in the memory.
snap=imresize(snap,[42 24]); % Resize the input image so it can be compared with the template's images.
comp=[ ];
for n=1:length(NewTemplates)
    sem=corr2(NewTemplates{1,n},snap); % Correlation the input image with every image in the template for best matching.
    comp=[comp sem]; % Record the value of correlation for each template's character.
end
vd=find(comp==max(comp)); % Find the index which correspond to the highest matched character.
%*-*-*-*-*-*-*-*-*-*-*-*-*-
% Accodrding to the index assign to 'letter'.
% Alphabets listings.
if vd==1 || vd==2
    letter='A';
elseif vd==3 || vd==4
    letter='B';
elseif vd==5
    letter='C';
elseif vd==6 || vd==7
    letter='D';
elseif vd==8
    letter='E';
elseif vd==9
    letter='F';
elseif vd==10
    letter='G';
elseif vd==11
    letter='H';
elseif vd==12
    letter='I';
elseif vd==13
    letter='J';
elseif vd==14
    letter='K';
elseif vd==15
    letter='L';
elseif vd==16
    letter='M';
elseif vd==17
    letter='N';
elseif vd==18 || vd==19
    letter='O';
elseif vd==20 || vd==21
    letter='P';
elseif vd==22 || vd==23
    letter='Q';
elseif vd==24 || vd==25
    letter='R';
elseif vd==26
    letter='S';
elseif vd==27
    letter='T';
elseif vd==28
    letter='U';
elseif vd==29
    letter='V';
elseif vd==30
    letter='W';
elseif vd==31
    letter='X';
elseif vd==32
    letter='Y';
elseif vd==33
    letter='Z';
    %*-*-*-*-*
% Numerals listings.
elseif vd==34
    letter='1';
elseif vd==35
    letter='2';
elseif vd==36
    letter='3';
elseif vd==37 || vd==38
    letter='4';
elseif vd==39
    letter='5';
elseif vd==40 || vd==41 || vd==42
    letter='6';
elseif vd==43
    letter='7';
elseif vd==44 || vd==45
    letter='8';
elseif vd==46 || vd==47 || vd==48
    letter='9';
else
    letter='0';
end
end
function r=controlling(NR)
%CONTROLLING determine the array of indices of Bounding boxes of interest.
%   R=CONTROLLING(NR) outputs the row vector R containing the indices of
%   the bounding boxes of interest from the matrix NR. NR is the matrix of
%   order numberofregionsx4. Numberofregions are the total number of
%   regions extracted from the function regionprops with the property
%   'BoundingBox'. To ensure the order cat(1,...) function could be used.
%   The code for this function emphasize on obtaining the indices of
%   Bounding boxes whose width along the y-dimension is nearly same. If
%   the approach of y-width doesn't work then Bounding Boxes with nearly
%   same y-coordinates are obtained.

[Q,W]=hist(NR(:,4)); % Histogram of the y-dimension widths of all boxes.
ind=find(Q==6); % Find indices from Q corresponding to frequency '6'.
% Since the number plates of cars in Karachi have six characters so
% find(Q==6) is used. If the code is to be implemented for some other plates
% the argument to the function 'find' has to be changed accordingly.
% Q is a row vector of frequency and W is the row vector of all the mid
% points of bins. Hist automatically selects the range of W from its input
% argument.

for k=1:length(NR)            % Taking the advantage of uniqueness of y-co
    C_5(k)=NR(k,2) * NR(k,4); % ordinate and y-width.
end
NR2=cat(2,NR,C_5');           % Appending new coloumn in NR.
[E,R]=hist(NR2(:,5),20);
Y=find(E==6);                 % Searching for six characters.
if length(ind)==1 % If six boxes of interest are succesfully found record
    MP=W(ind);    %  the midpoint of corresponding bin.
    binsize=W(2)-W(1); % Calculate the container size.
    container=[MP-(binsize/2) MP+(binsize/2)]; % Calculating the complete container size.
    r=takeboxes(NR,container,2);
elseif length(Y)==1
    MP=R(Y);
    binsize=R(2)-R(1);
    container=[MP-(binsize/2) MP+(binsize/2)]; % Calculating the complete container size.
    r=takeboxes(NR2,container,2.5); % Call to function takeboxes.    
elseif isempty(ind) || length(ind)>1 % If there is no vlaue of '6' in the Q vector.
    [A,B]=hist(NR(:,2),20); % Use y-coordinate approach only.
    ind2=find(A==6);
    if length(ind2)==1
        MP=B(ind2);
        binsize=B(2)-B(1);
        container=[MP-(binsize/2) MP+(binsize/2)]; % Calculating the complete container size.
        r=takeboxes(NR,container,1);
    else
        container=guessthesix(A,B,(B(2)-B(1))); % Call of function guessthesix.
        if ~isempty(container) % If guessthesix works succesfully.
            r=takeboxes(NR,container,1); % Call the function takeboxes.
        elseif isempty(container)
            container2=guessthesix(E,R,(R(2)-R(1)));
            if ~isempty(container2)
                r=takeboxes(NR2,container2,2.5);
            else
                r=[]; % Otherwise assign an empty matrix to 'r'.
            end
        end
    end
end
end
function r=takeboxes(NR,container,chk)
%TAKEBOXES helps in determining the values of indices of interested Bounding boxes.
% R=TAKEBOXES(NR,CONTAINER,CHK) outputs the value of indices corresponding
% the desired Bounding boxes. NR is the numberofregionsx4 matrix of all the
% regions' Bounding boxes. CONTAINER is the width of the bin that contain
% all the six bounding boxes of interest. CHK will determine whether
% bounding boxes are y-dimension widht's wise grouped or y-coordinate wise
% grouped. CHK=2 considers y-dimension width grouping and CHK=1 considers
% y-coordinate grouping.

takethisbox=[]; % Initialize the variable to an empty matrix.
for i=1:size(NR,1)
    if NR(i,(2*chk))>=container(1) && NR(i,(2*chk))<=container(2) % If Bounding box is among the container plus tolerence.
        takethisbox=cat(1,takethisbox,NR(i,:)); % Take that box and concatenate along first dimension.
    end
end
r=[];
for k=1:size(takethisbox,1)
    var=find(takethisbox(k,1)==reshape(NR(:,1),1,[])); % Finding the indices of the interested boxes among NR
    if length(var)==1                                  % since x-coordinate of the boxes will be unique.  
        r=[r var];                                     
    else                                               % In case if x-coordinate is not unique 
        for v=1:length(var)                            % then check which box fall under container condition. 
            M(v)=NR(var(v),(2*chk))>=container(1) && NR(var(v),(2*chk))<=container(2);
        end
        var=var(M);
        r=[r var];
    end
end
end
