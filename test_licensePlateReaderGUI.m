function licensePlateReaderGUI
    % Create the main figure
    fig = figure('Name', 'License Plate Reader', 'NumberTitle', 'off', 'Position', [100, 100, 400, 200]);

    % Create components
    btnSelectImage = uicontrol('Style', 'pushbutton', 'String', 'Select Image', 'Position', [50, 150, 100, 30], 'Callback', @selectImageCallback);
    btnProcessImage = uicontrol('Style', 'pushbutton', 'String', 'Process Image', 'Position', [200, 150, 100, 30], 'Callback', @processImageCallback);
    txtTitle = uicontrol('Style', 'text', 'String', 'License Plate Reader', 'Position', [150, 180, 150, 20]);

    % Variable to store selected image path
    selectedImagePath = '';

    % Callback function for selecting an image
    function selectImageCallback(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'; '*.*', 'All Files'}, 'Select Image');
        if isequal(file, 0) || isequal(path, 0)
            return; % User canceled the operation
        end
        selectedImagePath = fullfile(path, file);
        msgbox('Image selected successfully!', 'Success', 'modal');
    end

    % Callback function for processing the selected image
    function processImageCallback(~, ~)
        if isempty(selectedImagePath)
            msgbox('Please select an image first.', 'Error', 'error', 'modal');
            return;
        end

        % Read the image
        img = imread(selectedImagePath);

        % Convert the image to grayscale
        imgGray = rgb2gray(img);

        % Use edge detection to find edges in the image
        imgEdges = edge(imgGray, 'Canny');

        % Use regionprops to find connected components (potential text regions)
        stats = regionprops(imgEdges, 'BoundingBox', 'Area');

        % Filter out small regions (adjust the threshold as needed)
        minAreaThreshold = 500;
        validRegions = stats([stats.Area] > minAreaThreshold);

        % Display rectangles on the image
        imgWithRect = insertShape(img, 'Rectangle', [validRegions.BoundingBox], 'LineWidth', 2, 'Color', 'red');

        % Display the image with rectangles
        figure;
        imshow(imgWithRect);
        title('Text Detection');

        % Initialize OCR results
        recognizedText = '';

        % Iterate over the valid text regions and perform OCR
        for i = 1:length(validRegions)
            % Crop the image to the detected text region
            textRegion = imcrop(imgGray, validRegions(i).BoundingBox);

            % Perform OCR on the text region
            ocrResults = ocr(textRegion);

            % Concatenate the recognized text
            recognizedText = [recognizedText ' ' ocrResults.Text];
        end

        % Display the recognized text
        msgbox(['License Plate: ' recognizedText], 'License Plate Detection', 'modal');
    end
end
