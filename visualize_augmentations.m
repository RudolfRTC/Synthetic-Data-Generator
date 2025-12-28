% =========================================================================
% VISUALIZATION SCRIPT FOR AUGMENTATIONS
% =========================================================================
% This script helps visualize the different augmentation transformations
% applied to a single test image. Useful for understanding and tuning
% the augmentation parameters.
%
% Usage:
%   visualize_augmentations()           % Uses built-in test image
%   visualize_augmentations('path/to/image.jpg')  % Uses custom image
% =========================================================================

function visualize_augmentations(imagePath)
    %% Load Test Image
    if nargin < 1
        % Use MATLAB's built-in test image if no path provided
        fprintf('No image path provided. Using built-in test image.\n');
        img = imread('cameraman.tif');
        % Convert to RGB if grayscale
        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        end
    else
        % Load user-specified image
        try
            img = imread(imagePath);
            fprintf('Loaded image: %s\n', imagePath);
        catch ME
            error('Failed to load image: %s', ME.message);
        end
    end

    %% Generate Multiple Augmented Versions
    fprintf('Generating augmented versions...\n\n');

    % Create figure with subplots
    figure('Name', 'Image Augmentation Visualization', 'Position', [100, 100, 1200, 800]);

    % Display original image
    subplot(3, 3, 1);
    imshow(img);
    title('Original Image', 'FontWeight', 'bold', 'FontSize', 12);

    % Generate and display 8 augmented versions
    for i = 1:8
        augImg = applyRandomTransformations(img);

        subplot(3, 3, i+1);
        imshow(augImg);
        title(sprintf('Augmented #%d', i), 'FontSize', 10);
    end

    % Add overall title
    sgtitle('Image Data Augmentation Examples', 'FontSize', 14, 'FontWeight', 'bold');

    fprintf('Visualization complete!\n');
    fprintf('\nTransformations applied (randomly):\n');
    fprintf('  • Rotation (-30° to 30°)\n');
    fprintf('  • Horizontal/Vertical Flipping\n');
    fprintf('  • Scaling (0.8x to 1.2x)\n');
    fprintf('  • Brightness Adjustment (0.7x to 1.3x)\n');
    fprintf('  • Gaussian Noise\n');
end

%% Helper Function: Apply Random Transformations
function augmentedImg = applyRandomTransformations(img)
    % This is the same function from image_augmentation.m
    % Copied here for standalone visualization

    augmentedImg = img;
    [height, width, channels] = size(img);

    %% 1. Random Rotation
    if rand() > 0.3
        angle = (rand() - 0.5) * 60;
        augmentedImg = imrotate(augmentedImg, angle, 'bilinear', 'crop');
    end

    %% 2. Random Flipping
    flipChoice = rand();
    if flipChoice < 0.33
        augmentedImg = flip(augmentedImg, 2);  % Horizontal
    elseif flipChoice < 0.66
        augmentedImg = flip(augmentedImg, 1);  % Vertical
    end

    %% 3. Random Scaling
    if rand() > 0.4
        scaleFactor = 0.8 + rand() * 0.4;
        newHeight = round(height * scaleFactor);
        newWidth = round(width * scaleFactor);
        augmentedImg = imresize(augmentedImg, [newHeight, newWidth], 'bilinear');

        if scaleFactor > 1.0
            startRow = round((newHeight - height) / 2) + 1;
            startCol = round((newWidth - width) / 2) + 1;
            augmentedImg = augmentedImg(startRow:startRow+height-1, startCol:startCol+width-1, :);
        else
            padRow = height - newHeight;
            padCol = width - newWidth;
            padTop = floor(padRow / 2);
            padBottom = ceil(padRow / 2);
            padLeft = floor(padCol / 2);
            padRight = ceil(padCol / 2);

            augmentedImg = padarray(augmentedImg, [padTop, padLeft], 0, 'pre');
            augmentedImg = padarray(augmentedImg, [padBottom, padRight], 0, 'post');
        end
    end

    %% 4. Brightness Adjustment
    if rand() > 0.3
        brightnessFactor = 0.7 + rand() * 0.6;
        augmentedImg = im2double(augmentedImg);
        augmentedImg = augmentedImg * brightnessFactor;
        augmentedImg(augmentedImg > 1) = 1;
        augmentedImg(augmentedImg < 0) = 0;

        if isa(img, 'uint8')
            augmentedImg = im2uint8(augmentedImg);
        elseif isa(img, 'uint16')
            augmentedImg = im2uint16(augmentedImg);
        end
    end

    %% 5. Add Gaussian Noise
    if rand() > 0.4
        if isa(augmentedImg, 'uint8')
            noiseVariance = 0.001 + rand() * 0.004;
        else
            noiseVariance = 0.001 + rand() * 0.009;
        end
        augmentedImg = imnoise(augmentedImg, 'gaussian', 0, noiseVariance);
    end

    % Ensure correct size
    if size(augmentedImg, 1) ~= height || size(augmentedImg, 2) ~= width
        augmentedImg = imresize(augmentedImg, [height, width], 'bilinear');
    end
end
