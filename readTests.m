clear all
clc
% Spécifiez le chemin complet du fichier Excel
nomFichierExcel = 'BDD/BDD.xlsx'; 
% Spécifiez la feuille à lire (si nécessaire)
nomFeuille = 'Feuil1'; % Remplacez par le nom de votre feuille
% Utilisez la fonction xlsread pour récupérer les données
[data, texte, raw] = xlsread(nomFichierExcel, nomFeuille);
% Affichez les données récupérées
%disp(data);
% Vous pouvez également afficher le texte et les données brutes si nécessaire
%disp(texte);

for i=1:25
path = sprintf( 'BDD/BDD/%d.PNG', i );
text = regexprep(readCharacter(path), '\s', '');
%findName(text, texte)
findCrime(text,texte)
%readCharacter('BDD/BDD/'+toString(i)+'1.PNG') %'BDD/BDD/1.PNG' 'test_plate.jpg'
end
function recognizedText=readCharacter(path)
    I = imread(path);
    %figure;
    %imshow(I)
    I=filter(I);
    %figure;
    %imshow(I)
    %h = drawrectangle(gca,'Position',[100 230 630 150]); %300 20 2400 600
    %pos = h.Position
    %roi=round(pos)
    ocrResults = ocr(I, 'TextLayout','Line');
    recognizedText = ocrResults.Text;
    %rectangle('Position',[300 20 2200 600],'FaceColor','r','EdgeColor','b')
    text(60,350,recognizedText,BackgroundColor=[1 1 1],FontSize=10);
end

function im_2=filter(im_1)
    im_2=0*im_1;
    Seuil1=0;
    Seuil2=0;
    Seuil3=0;
    [M,N, channel] = size(im_1);
    for i=1:M
        for j=1:N
    
            % Composante R
            if(im_1(i,j,1)>Seuil1)
                im_2(i,j,1)=255;
            end;
    
            % Composante G
            if(im_1(i,j,2)>Seuil2)
                im_2(i,j,2)=255;
            end;
    
            % Composante B
            if(im_1(i,j,3)>Seuil3)
                im_2(i,j,3)=255;
            end;
        end;
    end;
end

function name = findName(id, texte)
    % Check if the string is inside the table
    [isStringPresent, index] = ismember(id, texte(:,1));
    if(isStringPresent>0)
        name = texte(index,2);
    else
        name = 'Not found';
    end;
end

function name = findCrime(id, texte)
    % Check if the string is inside the table
    [isStringPresent, index] = ismember(id, texte(:,1));
    if(isStringPresent>0 && strcmp(texte(index,3),'NOK'))
        name = strcat(texte(index,2), ' ', texte(index,4));
    else
        name = '';
    end;
end