% =========================================================================
% IMAGE DATA AUGMENTATION SCRIPT (Deep Learning Toolbox Version)
% =========================================================================
% Description: This script uses imageDataAugmenter from Deep Learning Toolbox
%              for efficient data augmentation on image datasets.
%
% Author: MATLAB Expert
% Date: December 2025
%
% Requirements:
%   - Deep Learning Toolbox
%   - Image Processing Toolbox
%   - Input folder: 'input_images' with .jpg, .png, etc.
%   - Output folder: 'augmented_images' (created automatically)
%
% Note: This version uses imageDataAugmenter which is optimized for
%       deep learning workflows but offers less fine-grained control
%       than the standard version. For maximum flexibility, use
%       image_augmentation.m instead.
% =========================================================================

function image_augmentation_deep_learning()
    %% Setup and Configuration
    clear; clc;
    fprintf('=== Image Data Augmentation (Deep Learning Toolbox) ===\n\n');

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

    %% Configure Image Data Augmenter
    % Create augmenter with specified transformations
    augmenter = imageDataAugmenter( ...
        'RandRotation', [-30 30], ...              % Random rotation between -30 and 30 degrees
        'RandXReflection', true, ...                % Random horizontal flipping
        'RandYReflection', true, ...                % Random vertical flipping
        'RandXScale', [0.8 1.2], ...               % Random horizontal scaling
        'RandYScale', [0.8 1.2]);                  % Random vertical scaling

    fprintf('Augmenter configured with:\n');
    fprintf('  - Rotation: -30° to 30°\n');
    fprintf('  - Horizontal & Vertical Flipping\n');
    fprintf('  - Scaling: 0.8x to 1.2x\n');
    fprintf('  - Additional: Brightness & Gaussian Noise (applied separately)\n\n');

    %% Get list of all image files
    imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    imageFiles = [];

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
            [height, width, ~] = size(originalImg);
            fprintf('[%d/%d] Processing: %s\n', imgIdx, numImages, imageFiles(imgIdx).name);

            % Generate augmented versions
            for augIdx = 1:numAugmentationsPerImage
                % Apply augmentation using imageDataAugmenter
                augmentedImg = augment(augmenter, originalImg);

                % Ensure output size matches input (crop or resize if needed)
                [augHeight, augWidth, ~] = size(augmentedImg);
                if augHeight ~= height || augWidth ~= width
                    augmentedImg = imresize(augmentedImg, [height, width], 'bilinear');
                end

                % Apply additional transformations not supported by imageDataAugmenter
                augmentedImg = applyAdditionalTransformations(augmentedImg);

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

%% Helper Function: Apply Additional Transformations
function augmentedImg = applyAdditionalTransformations(img)
    % APPLYADDITIONAL Applies transformations not available in imageDataAugmenter
    %
    % Transformations:
    %   1. Brightness adjustment
    %   2. Gaussian noise

    augmentedImg = img;

    %% Brightness Adjustment (0.7x to 1.3x)
    if rand() > 0.3  % 70% probability
        brightnessFactor = 0.7 + rand() * 0.6;

        % Convert to double for processing
        augmentedImg = im2double(augmentedImg);
        augmentedImg = augmentedImg * brightnessFactor;

        % Clip values to valid range
        augmentedImg(augmentedImg > 1) = 1;
        augmentedImg(augmentedImg < 0) = 0;

        % Convert back to original class
        if isa(img, 'uint8')
            augmentedImg = im2uint8(augmentedImg);
        elseif isa(img, 'uint16')
            augmentedImg = im2uint16(augmentedImg);
        end
    end

    %% Add Gaussian Noise
    if rand() > 0.4  % 60% probability
        if isa(augmentedImg, 'uint8')
            noiseVariance = 0.001 + rand() * 0.004;
        else
            noiseVariance = 0.001 + rand() * 0.009;
        end

        augmentedImg = imnoise(augmentedImg, 'gaussian', 0, noiseVariance);
    end
end
