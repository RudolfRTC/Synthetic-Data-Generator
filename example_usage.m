% =========================================================================
% EXAMPLE USAGE SCRIPT
% =========================================================================
% This script demonstrates different ways to use the image augmentation tools
% =========================================================================

%% Example 1: Basic Usage with Default Settings
% This is the simplest way to use the augmentation script

fprintf('\n=== EXAMPLE 1: Basic Usage ===\n');
fprintf('Simply run the main function:\n');
fprintf('  >> image_augmentation()\n\n');

% Uncomment to run:
% image_augmentation()

%% Example 2: Verify Input Folder Exists
% Check if input folder exists before running

fprintf('=== EXAMPLE 2: Verify Setup ===\n');

if exist('input_images', 'dir')
    % Count images in input folder
    imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};
    imageFiles = [];

    for i = 1:length(imageExtensions)
        currentFiles = dir(fullfile('input_images', imageExtensions{i}));
        imageFiles = [imageFiles; currentFiles];
    end

    fprintf('Found %d images in input_images folder:\n', length(imageFiles));
    for i = 1:min(5, length(imageFiles))
        fprintf('  - %s\n', imageFiles(i).name);
    end
    if length(imageFiles) > 5
        fprintf('  ... and %d more\n', length(imageFiles) - 5);
    end
    fprintf('\nReady to run augmentation!\n');
else
    fprintf('Input folder "input_images" not found.\n');
    fprintf('Creating folder now...\n');
    mkdir('input_images');
    fprintf('Please add images to the input_images folder before running.\n');
end

%% Example 3: Custom Test with Single Image
% Demonstrates how to test transformations on a single image

fprintf('\n=== EXAMPLE 3: Test Single Image Transformation ===\n');
fprintf('This example shows how to test the augmentation on one image:\n\n');

% Create a test image if no images are available
if ~exist('input_images', 'dir') || isempty(imageFiles)
    fprintf('Creating a test image for demonstration...\n');
    testImg = imread('cameraman.tif');  % Built-in MATLAB test image

    if ~exist('input_images', 'dir')
        mkdir('input_images');
    end
    imwrite(testImg, 'input_images/test_image.tif');
    fprintf('Test image created: input_images/test_image.tif\n');
end

fprintf('\nTo visually inspect transformations before batch processing:\n');
fprintf('  1. Read your test image\n');
fprintf('  2. Apply transformations\n');
fprintf('  3. Display original and augmented side-by-side\n\n');

fprintf('Example code:\n');
fprintf('  testImg = imread(''input_images/test_image.tif'');\n');
fprintf('  augImg = applyRandomTransformations(testImg);\n');
fprintf('  figure; subplot(1,2,1); imshow(testImg); title(''Original'');\n');
fprintf('  subplot(1,2,2); imshow(augImg); title(''Augmented'');\n\n');

%% Example 4: Estimate Output Size
% Calculate expected output size before running

fprintf('=== EXAMPLE 4: Estimate Output Size ===\n');

if exist('input_images', 'dir')
    % Get total size of input images
    imageFiles = dir(fullfile('input_images', '*.*'));
    totalSizeMB = 0;

    for i = 1:length(imageFiles)
        if ~imageFiles(i).isdir
            totalSizeMB = totalSizeMB + imageFiles(i).bytes / (1024*1024);
        end
    end

    numAugmentationsPerImage = 5;
    estimatedOutputSizeMB = totalSizeMB * numAugmentationsPerImage;

    fprintf('Input folder size: %.2f MB\n', totalSizeMB);
    fprintf('Estimated output size: %.2f MB\n', estimatedOutputSizeMB);
    fprintf('Total estimated storage needed: %.2f MB\n', totalSizeMB + estimatedOutputSizeMB);

    % Check available disk space
    if ispc
        [~, diskInfo] = system('fsutil volume diskfree .');
        fprintf('\nNote: Ensure you have sufficient disk space.\n');
    else
        [~, diskInfo] = system('df -h .');
        fprintf('\nDisk space info:\n%s\n', diskInfo);
    end
end

%% Example 5: Batch Processing with Error Handling
% Demonstrates robust batch processing

fprintf('\n=== EXAMPLE 5: Robust Batch Processing ===\n');
fprintf('The main script includes error handling:\n');
fprintf('  - Skips corrupted images\n');
fprintf('  - Reports which files failed\n');
fprintf('  - Continues processing remaining images\n\n');
fprintf('Simply run: image_augmentation()\n');

%% Example 6: Compare Both Versions
% Shows when to use each version

fprintf('\n=== EXAMPLE 6: Choosing the Right Version ===\n\n');

fprintf('Standard Version (image_augmentation.m):\n');
fprintf('  ✓ No additional toolboxes required\n');
fprintf('  ✓ Maximum control over transformations\n');
fprintf('  ✓ Easy to customize\n');
fprintf('  ✓ Recommended for most users\n\n');

fprintf('Deep Learning Version (image_augmentation_deep_learning.m):\n');
fprintf('  ✓ Requires Deep Learning Toolbox\n');
fprintf('  ✓ Integrates with DL workflows\n');
fprintf('  ✓ Uses MATLAB''s imageDataAugmenter\n');
fprintf('  ✓ Good for deep learning projects\n\n');

% Check if Deep Learning Toolbox is available
if license('test', 'Neural_Network_Toolbox')
    fprintf('Deep Learning Toolbox: AVAILABLE ✓\n');
    fprintf('You can use either version.\n');
else
    fprintf('Deep Learning Toolbox: NOT AVAILABLE ✗\n');
    fprintf('Use the standard version (image_augmentation.m)\n');
end

%% Example 7: Quick Start Guide
fprintf('\n=== QUICK START GUIDE ===\n');
fprintf('Step 1: Place images in input_images/ folder\n');
fprintf('Step 2: Run: image_augmentation()\n');
fprintf('Step 3: Find augmented images in augmented_images/ folder\n');
fprintf('\nThat''s it! 🎉\n');

%% Helper Function Display
fprintf('\n=== AVAILABLE FUNCTIONS ===\n');
fprintf('Main functions:\n');
fprintf('  - image_augmentation()              : Standard version\n');
fprintf('  - image_augmentation_deep_learning(): Deep Learning version\n\n');
fprintf('Helper functions (called internally):\n');
fprintf('  - applyRandomTransformations()      : Apply all augmentations\n');
fprintf('  - applyAdditionalTransformations()  : DL version helpers\n\n');

fprintf('For more information, see README.md\n');
fprintf('='.repmat('=', 1, 60)); fprintf('\n');
