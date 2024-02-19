function lirePlaquesAvecInterface()

    % Charger les images disponibles dans le dossier
    imageFiles = dir('BDD\car_img\*.jpg');
    numImages = length(imageFiles);
    currentImageIndex = 1;

    % Lire la première image
    image = imread(strcat('BDD\car_img\',imageFiles(currentImageIndex).name));

    % Créer une figure pour l'interface utilisateur
    fig = figure('Name', 'Lecture de plaques d''immatriculation', 'Position', [100, 100, 800, 600]);

    % Division de l'interface en deux parties
    leftPanel = uipanel('Parent', fig, 'Position', [0, 0, 0.5, 1]);
    rightPanel = uipanel('Parent', fig, 'Position', [0.5, 0, 0.5, 1]);

    % Axes pour l'image originale (moitié gauche)
    ax1 = subplot(2, 1, 1, 'Parent', leftPanel);
    imshow(image);
    title('Image originale');

    % Axes pour l'image après traitement (moitié gauche, en dessous de l'image originale)
    ax2 = subplot(2, 1, 2, 'Parent', leftPanel);
    processedImage = [];
    imshow(processedImage);
    title('Zone de la plaque');

    % Création d'un panneau pour les boutons (moitié droite)
buttonPanel = uipanel('Parent', fig, 'Position', [0.5, 0.6, 0.5, 0.4]);


    % Bouton pour passer à la plaque suivante (moitié droite)
    uicontrol('Style', 'pushbutton', 'String', 'Plaque précédente', 'Position', [30, 80, 150, 30], 'Parent', buttonPanel, 'Callback', @prevPlate);

    % Bouton pour revenir à la plaque précédente (moitié droite)
    uicontrol('Style', 'pushbutton', 'String', 'Plaque suivante', 'Position', [230, 80, 150, 30], 'Parent', buttonPanel, 'Callback', @nextPlate);

    % Bouton pour lancer le traitement de l'image (moitié droite)
    uicontrol('Style', 'pushbutton', 'String', 'Traiter l''image', 'Position', [130, 40, 150, 30], 'Parent', buttonPanel, 'Callback', @processImageCallback);

    % Texte de la plaque lue (moitié droite)
    plateText = '';
    plateTextUI = uicontrol('Style', 'text', 'String', ['Plaque lue : ', plateText], 'Position', [10, 10, 350, 20], 'Parent', buttonPanel);

    % Texte % de complétion (moitié droite)
    percentText = '';
    percentTextUI = uicontrol('Style', 'text', 'String', ['Pourcentage de traitement complété : ', percentText, ' %'], 'Position', [10, 160, 350, 20], 'Parent', buttonPanel);

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
        display(plateText)
        if strlength(plateText)<5
            plateText = "Aucune plaque trouvée";
        end
        axes(ax2);
        imshow(processedImage);
        set(plateTextUI, 'String', ['Plaque lue : ', plateText]);
        set(percentTextUI, 'String', ['Traitement fini']);
    end

    % Fonction pour mettre à jour l'interface utilisateur
    function updateUI()
        image = imread(strcat('BDD\car_img\',imageFiles(currentImageIndex).name));
        axes(ax1);
        imshow(image);
        processedImage = [];
        axes(ax2);
        imshow(processedImage);
        plateText = '';
        set(plateTextUI, 'String', ['Plaque lue : ', plateText]);
        set(percentTextUI, 'String', ['Traitement à venir']);
    end

    % Fonction pour traiter l'image
    function processedImage = processImage(image)
        grayImage = rgb2gray(image);
        processedImage = grayImage;
    end

    % Fonction pour lire la plaque
    function plateText = readPlate(processedImage)
        ocrResults = ocr(processedImage, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-');
        plateText = ocrResults.Text;
            % Create an empty table to store plate images
        plateTable = table('Size', [0, 1], 'VariableTypes', {'uint8'});

        pattern = '[A-Z]{2}-\d{3}-[A-Z]{2}';
        matches = regexp(plateText, pattern, 'match');

        if ~isempty(matches)
            plateText = matches{1};
            return;
        else
            plateText = '';
        end
        
        edgeImage = edge(processedImage, 'Canny');
        regionProps = regionprops(edgeImage, 'BoundingBox');
        minArea = 2000;
        validRegions = [];
        for i = 1:length(regionProps)
            if regionProps(i).BoundingBox(3)*regionProps(i).BoundingBox(4) > minArea
                validRegions = [validRegions; regionProps(i).BoundingBox];
            end
        end
        for i = 1:size(validRegions, 1)
            region = round(validRegions(i, :));
            plateImage = imcrop(processedImage, region);
                    % Store the plateImage in the table
            plateTable = [plateTable; {plateImage}];

            ocrResults = ocr(plateImage);
            currentText = regexprep(ocrResults.Text, '[^A-Z0-9]', '');
            disp(['Plaque ', num2str(i), ' : ', currentText]);
            pattern = '[A-Z]{2}-\d{3}-[A-Z]{2}';
            matches = regexp(currentText, pattern, 'match');
            if ~isempty(matches)
                plateText = matches{1};
                imagePlaque = plateImage;
                %affiche l'image traitée
                figure;
                imshow(imagePlaque );
                title('Image traite');
                return;
            end
            pattern = '[A-Z]{2}\d{3}[A-Z]{2}';
            matches = regexp(currentText, pattern, 'match');
            if ~isempty(matches)
                plateText = matches{1};
                imagePlaque = plateImage;
                %affiche l'image traitée
                figure;
                imshow(imagePlaque );
                title('Image traite');
                return;
            end
            if strlength(currentText)>strlength(plateText)
                plateText = currentText;
                imagePlaque = plateImage;
            end
            percentText=i;
            set(percentTextUI, 'String', ['Pourcentage de traitement complété : ', num2str(percentText), ' %']);
            drawnow;
            if i > 90
                break;
            end
        end
        %affiche l'image traitée
        figure;
        imshow(imagePlaque );
        title('Image traite');
    end

end
