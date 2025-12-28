% =========================================================================
% IMAGE DATA AUGMENTATION SCRIPT
% =========================================================================
% Description: This script performs data augmentation on a dataset of images
%              to increase dataset size by applying random transformations.
%
% Author: MATLAB Expert
% Date: December 2025
%
% Requirements:
%   - Image Processing Toolbox
%   - Input folder: 'input_images' with .jpg, .png, etc.
%   - Output folder: 'augmented_images' (created automatically)
%
% Process:
%   - Reads all images from input_images folder
%   - Generates 5 augmented versions per image
%   - Applies random combinations of transformations
%   - Saves with systematic naming
% =========================================================================

function image_augmentation()
    %% Setup and Configuration
    clear; clc;
    fprintf('=== Image Data Augmentation Script ===\n\n');

    % Define input and output folders
    inputFolder = 'input_images';
    outputFolder = 'augmented_images';

    % Number of augmented images to generate per original image
    numAugmentationsPerImage = 5;

    % Check if input folder exists
    if ~exist(inputFolder, 'dir')
        error('Input folder "%s" does not exist. Please create it and add images.', inputFolder);
    end

    % Create output folder if it doesn't exist
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
        fprintf('Created output folder: %s\n', outputFolder);
    end

    %% Get list of all image files
    % Supported image formats
    imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    imageFiles = [];

    % Collect all image files with supported extensions
    for i = 1:length(imageExtensions)
        currentFiles = dir(fullfile(inputFolder, imageExtensions{i}));
        imageFiles = [imageFiles; currentFiles];
    end

    numImages = length(imageFiles);

    if numImages == 0
        error('No images found in "%s" folder.', inputFolder);
    end

    fprintf('Found %d images in "%s" folder\n', numImages, inputFolder);
    fprintf('Generating %d augmented versions per image...\n\n', numAugmentationsPerImage);

    %% Process each image
    totalAugmented = 0;

    for imgIdx = 1:numImages
        % Read the original image
        imgPath = fullfile(inputFolder, imageFiles(imgIdx).name);
        [~, imgName, imgExt] = fileparts(imageFiles(imgIdx).name);

        try
            originalImg = imread(imgPath);
            fprintf('[%d/%d] Processing: %s\n', imgIdx, numImages, imageFiles(imgIdx).name);

            % Generate augmented versions
            for augIdx = 1:numAugmentationsPerImage
                % Apply random transformations
                augmentedImg = applyRandomTransformations(originalImg);

                % Create systematic output filename
                outputFilename = sprintf('%s_aug_%d%s', imgName, augIdx, imgExt);
                outputPath = fullfile(outputFolder, outputFilename);

                % Save the augmented image
                imwrite(augmentedImg, outputPath);
                totalAugmented = totalAugmented + 1;

                fprintf('  -> Generated: %s\n', outputFilename);
            end

        catch ME
            warning('Failed to process %s: %s', imageFiles(imgIdx).name, ME.message);
        end
    end

    %% Summary
    fprintf('\n=== Augmentation Complete ===\n');
    fprintf('Original images: %d\n', numImages);
    fprintf('Augmented images: %d\n', totalAugmented);
    fprintf('Total images: %d\n', numImages + totalAugmented);
    fprintf('Output location: %s\n', outputFolder);
end

%% Helper Function: Apply Random Transformations
function augmentedImg = applyRandomTransformations(img)
    % APPLYRANDOMTRANSFORMATIONS Applies random combination of transformations
    %
    % Transformations applied (randomly):
    %   1. Random rotation (-30 to 30 degrees)
    %   2. Horizontal or vertical flipping
    %   3. Gaussian noise
    %   4. Brightness adjustment
    %   5. Random scaling/zooming

    % Start with the original image
    augmentedImg = img;

    % Store original size for reference
    [height, width, channels] = size(img);

    %% 1. Random Rotation (-30 to 30 degrees)
    if rand() > 0.3  % 70% probability to apply rotation
        angle = (rand() - 0.5) * 60;  % Random angle between -30 and 30
        augmentedImg = imrotate(augmentedImg, angle, 'bilinear', 'crop');
    end

    %% 2. Random Flipping
    flipChoice = rand();
    if flipChoice < 0.33
        % Horizontal flip
        augmentedImg = flip(augmentedImg, 2);
    elseif flipChoice < 0.66
        % Vertical flip
        augmentedImg = flip(augmentedImg, 1);
    end
    % else: no flip (33% probability)

    %% 3. Random Scaling/Zooming (0.8x to 1.2x)
    if rand() > 0.4  % 60% probability to apply scaling
        scaleFactor = 0.8 + rand() * 0.4;  % Random scale between 0.8 and 1.2

        % Resize the image
        newHeight = round(height * scaleFactor);
        newWidth = round(width * scaleFactor);
        augmentedImg = imresize(augmentedImg, [newHeight, newWidth], 'bilinear');

        % Crop or pad to maintain original size
        if scaleFactor > 1.0
            % Image is larger, crop to original size
            startRow = round((newHeight - height) / 2) + 1;
            startCol = round((newWidth - width) / 2) + 1;
            augmentedImg = augmentedImg(startRow:startRow+height-1, startCol:startCol+width-1, :);
        else
            % Image is smaller, pad to original size
            padRow = height - newHeight;
            padCol = width - newWidth;
            padTop = floor(padRow / 2);
            padBottom = ceil(padRow / 2);
            padLeft = floor(padCol / 2);
            padRight = ceil(padCol / 2);

            if channels == 1
                augmentedImg = padarray(augmentedImg, [padTop, padLeft], 0, 'pre');
                augmentedImg = padarray(augmentedImg, [padBottom, padRight], 0, 'post');
            else
                augmentedImg = padarray(augmentedImg, [padTop, padLeft], 0, 'pre');
                augmentedImg = padarray(augmentedImg, [padBottom, padRight], 0, 'post');
            end
        end
    end

    %% 4. Brightness Adjustment (0.7x to 1.3x)
    if rand() > 0.3  % 70% probability to apply brightness adjustment
        brightnessFactor = 0.7 + rand() * 0.6;  % Random factor between 0.7 and 1.3

        % Convert to double for processing
        augmentedImg = im2double(augmentedImg);
        augmentedImg = augmentedImg * brightnessFactor;

        % Clip values to valid range [0, 1]
        augmentedImg(augmentedImg > 1) = 1;
        augmentedImg(augmentedImg < 0) = 0;

        % Convert back to original class
        if isa(img, 'uint8')
            augmentedImg = im2uint8(augmentedImg);
        elseif isa(img, 'uint16')
            augmentedImg = im2uint16(augmentedImg);
        end
    end

    %% 5. Add Gaussian Noise
    if rand() > 0.4  % 60% probability to add noise
        % Adjust noise level based on image type
        if isa(augmentedImg, 'uint8')
            noiseVariance = 0.001 + rand() * 0.004;  % Variance between 0.001 and 0.005
        else
            noiseVariance = 0.001 + rand() * 0.009;  % Variance between 0.001 and 0.01
        end

        augmentedImg = imnoise(augmentedImg, 'gaussian', 0, noiseVariance);
    end

    % Ensure output has the same dimensions as input (in case of any rounding errors)
    if size(augmentedImg, 1) ~= height || size(augmentedImg, 2) ~= width
        augmentedImg = imresize(augmentedImg, [height, width], 'bilinear');
    end
end
