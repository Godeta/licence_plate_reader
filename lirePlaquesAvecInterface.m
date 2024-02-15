function lirePlaquesAvecInterface()

    % Charger les images disponibles dans le dossier
    imageFiles = dir('BDD\car_img\*.jpg');
    numImages = length(imageFiles);
    currentImageIndex = 1;

    % Lire la première image
    image = imread(strcat('BDD\car_img\',imageFiles(currentImageIndex).name));

    % Créer une figure pour l'interface utilisateur
    fig = figure('Name', 'Lecture de plaques d''immatriculation', 'Position', [100, 100, 800, 600]);

    % Axes pour l'image originale
    ax1 = subplot(2, 2, [1, 2]);
    imshow(image);
    title('Image originale');

    % Axes pour l'image après traitement
    ax2 = subplot(2, 2, [3, 4]);
    processedImage = [];
    imshow(processedImage);
    title('Zone de la plaque');

    % Texte de la plaque lue
    plateText = '';
    plateTextUI = uicontrol('Style', 'text', 'String', ['Plaque lue : ', plateText], 'Position', [20, 20, 400, 20]);

    % Texte % de complétion
    percentText = '';
    percentTextUI = uicontrol('Style', 'text', 'String', ['Pourcentage de traitement complété : ', percentText, ' %'], 'Position', [20, 40, 400, 20]);


    % Bouton pour passer à la plaque suivante
    uicontrol('Style', 'pushbutton', 'String', 'Plaque suivante', 'Position', [250, 500, 150, 30], 'Callback', @nextPlate);

    % Bouton pour revenir à la plaque précédente
    uicontrol('Style', 'pushbutton', 'String', 'Plaque précédente', 'Position', [420, 500, 150, 30], 'Callback', @prevPlate);

    % Bouton pour lancer le traitement de l'image
    uicontrol('Style', 'pushbutton', 'String', 'Traiter l''image', 'Position', [100, 500, 150, 30], 'Callback', @processImageCallback);

    % Fonction pour afficher la plaque suivante
    function nextPlate(~, ~)
        if currentImageIndex < numImages
            currentImageIndex = currentImageIndex + 1;
            updateUI();
        end
    end

    % Fonction pour afficher la plaque précédente
    function prevPlate(~, ~)
        if currentImageIndex > 1
            currentImageIndex = currentImageIndex - 1;
            updateUI();
        end
    end

    % Fonction pour traiter l'image lors du clic sur le bouton
    function processImageCallback(~, ~)
        processedImage = processImage(image);
        plateText = readPlate(processedImage);
        % Define the characters to remove
        %charactersToRemove = {' ', '\n', '!', '''', ',', '{', ' ', '.', '_', '\','?'};
        
        % Create the regular expression pattern
        %pattern = sprintf('[%s]', strjoin(charactersToRemove, ''));
        
        % Use regexprep to remove the specified characters
        %plateText = regexprep(plateText, pattern, '');
        display(plateText)
        if strlength(plateText)<5
            plateText = "Aucune plaque trouvée";
        end
        % Mettre à jour l'affichage de l'image après traitement et du texte de la plaque
        axes(ax2);
        imshow(processedImage);
        set(plateTextUI, 'String', ['Plaque lue : ', plateText]);
        set(percentTextUI, 'String', ['Traitement fini']);
    end

    % Fonction pour mettre à jour l'interface utilisateur
    function updateUI()
        % Charger l'image
        image = imread(strcat('BDD\car_img\',imageFiles(currentImageIndex).name));
        % Afficher l'image originale
        axes(ax1);
        imshow(image);
        % Réinitialiser l'image après traitement
        processedImage = [];
        % Afficher l'image après traitement
        axes(ax2);
        imshow(processedImage);
        % Réinitialiser le texte de la plaque lue
        plateText = '';
        set(plateTextUI, 'String', ['Plaque lue : ', plateText]);
        set(percentTextUI, 'String', ['Traitement à venir']);
    end

    % Fonction pour traiter l'image
    function processedImage = processImage(image)
        % Conversion en niveaux de gris
        grayImage = rgb2gray(image);
        
        % Vous pouvez ajouter plus de traitement si nécessaire ici
        processedImage = grayImage; % Pour l'exemple, nous renvoyons simplement l'image en niveaux de gris
    end

    % Fonction pour lire la plaque
    function plateText = readPlate(processedImage)
        % Appliquer OCR sur l'image
        ocrResults = ocr(processedImage, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-');
        % Extraire le texte de l'objet OCR
        plateText = ocrResults.Text;

                % Trouver le motif AA-111-AA dans le texte de la plaque
        pattern = '[A-Z]{2}-\d{3}-[A-Z]{2}';
        matches = regexp(plateText, pattern, 'match');
        
        if ~isempty(matches)
            plateText = matches{1}; % Si une correspondance est trouvée, utiliser cette correspondance comme texte de la plaque
            return;
        else
            plateText = '';
        end
        
        % Détection des bordures de l'image
        edgeImage = edge(processedImage, 'Canny');
        % Identifier les régions candidates pour la plaque d'immatriculation
        regionProps = regionprops(edgeImage, 'BoundingBox');
        % Filtrer les régions potentielles
        minArea = 2000; % Ajustez selon la taille de la plaque d'immatriculation dans votre image
        validRegions = [];
        for i = 1:length(regionProps)
            if regionProps(i).BoundingBox(3)*regionProps(i).BoundingBox(4) > minArea
                validRegions = [validRegions; regionProps(i).BoundingBox];
            end
        end
        % Lecture du texte des plaques d'immatriculation
        for i = 1:size(validRegions, 1)
            region = round(validRegions(i, :));
            plateImage = imcrop(processedImage, region);
            ocrResults = ocr(plateImage);
            currentText = regexprep(ocrResults.Text, '[^A-Z0-9]', '');
            disp(['Plaque ', num2str(i), ' : ', currentText]);
            % Trouver le motif AA-111-AA dans le texte de la plaque
            pattern = '[A-Z]{2}-\d{3}-[A-Z]{2}';
            matches = regexp(currentText, pattern, 'match');
            if ~isempty(matches)
                plateText = matches{1}; % Si une correspondance est trouvée, utiliser cette correspondance comme texte de la plaque
                return;
            end
            pattern = '[A-Z]{2}\d{3}[A-Z]{2}';
            matches = regexp(currentText, pattern, 'match');
            if ~isempty(matches)
                plateText = matches{1}; % Si une correspondance est trouvée, utiliser cette correspondance comme texte de la plaque
                return;
            end
            if strlength(currentText)>strlength(plateText)
                plateText = currentText;
            end
            percentText=i;
            set(percentTextUI, 'String', ['Pourcentage de traitement complété : ', num2str(percentText), ' %']);
            drawnow;
            if i > 90
                break;
            end
        end
        

    end

end