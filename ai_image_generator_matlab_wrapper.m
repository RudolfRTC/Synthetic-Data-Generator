% =========================================================================
% AI IMAGE GENERATOR - MATLAB Wrapper for Stable Diffusion
% =========================================================================
% Description: MATLAB interface to Python Stable Diffusion for generating
%              photorealistic AI images from text descriptions.
%
% Author: MATLAB AI Expert
% Date: December 2025
%
% Requirements:
%   - Python 3.8+ installed and accessible from MATLAB
%   - Python packages: diffusers, transformers, torch, pillow
%   - GPU recommended (NVIDIA CUDA)
%
% Setup Instructions:
%   1. Install Python: https://www.python.org/downloads/
%   2. Install required packages:
%      pip install torch torchvision diffusers transformers accelerate pillow
%   3. Configure Python in MATLAB:
%      pyenv('Version', 'path/to/python.exe')
%
% Features:
%   - Generate images from text descriptions
%   - Batch processing with multiple prompts
%   - Adjustable quality and style parameters
%   - Automatic Python integration
%
% NOTE: First run will download ~4GB AI model (one-time only)
% =========================================================================

function ai_image_generator_matlab_wrapper()
    %% Configuration
    clear; clc;
    fprintf('=== AI Image Generator (MATLAB + Stable Diffusion) ===\n\n');

    % Check Python environment
    checkPythonEnvironment();

    % Configuration
    config.outputFolder = 'ai_generated_images';
    config.promptsFile = 'image_prompts.txt';
    config.pythonScript = 'ai_image_generator_stable_diffusion.py';

    % Generation parameters
    config.numImagesPerPrompt = 2;  % How many variations per prompt
    config.imageWidth = 512;         % Image width (must be multiple of 8)
    config.imageHeight = 512;        % Image height (must be multiple of 8)
    config.inferenceSteps = 25;      % Quality (20-50, higher = better but slower)
    config.guidanceScale = 7.5;      % Prompt adherence (7-15 recommended)

    %% Create prompts file if it doesn't exist
    if ~exist(config.promptsFile, 'file')
        fprintf('Creating example prompts file...\n');
        createExamplePromptsFile(config.promptsFile);
        fprintf('  ✓ Created: %s\n\n', config.promptsFile);
    end

    %% Read prompts
    fprintf('Reading image prompts from: %s\n', config.promptsFile);
    prompts = readPromptsFile(config.promptsFile);
    fprintf('Found %d prompts:\n', length(prompts));
    for i = 1:min(3, length(prompts))
        fprintf('  %d. "%s"\n', i, prompts{i});
    end
    if length(prompts) > 3
        fprintf('  ... and %d more\n', length(prompts) - 3);
    end
    fprintf('\n');

    %% Generate images using Python Stable Diffusion
    fprintf('Starting AI image generation...\n');
    fprintf('Parameters:\n');
    fprintf('  Images per prompt: %d\n', config.numImagesPerPrompt);
    fprintf('  Resolution: %dx%d\n', config.imageWidth, config.imageHeight);
    fprintf('  Inference steps: %d\n', config.inferenceSteps);
    fprintf('  Guidance scale: %.1f\n\n', config.guidanceScale);

    fprintf('NOTE: First run will download AI model (~4GB, one-time only)\n');
    fprintf('This may take 10-30 minutes depending on your GPU...\n\n');

    % Build Python command
    pythonCmd = sprintf('python "%s" --prompts-file "%s" --output-dir "%s" --num-images %d --width %d --height %d --steps %d --guidance %.1f', ...
        config.pythonScript, ...
        config.promptsFile, ...
        config.outputFolder, ...
        config.numImagesPerPrompt, ...
        config.imageWidth, ...
        config.imageHeight, ...
        config.inferenceSteps, ...
        config.guidanceScale);

    % Execute Python script
    [status, output] = system(pythonCmd);

    % Display output
    fprintf('%s\n', output);

    if status == 0
        fprintf('\n=== AI Image Generation Complete! ===\n');
        fprintf('Generated images saved to: %s/\n', config.outputFolder);

        % Display generated images
        displayGeneratedImages(config.outputFolder);
    else
        error('Failed to generate images. Check Python installation and dependencies.');
    end
end

%% Helper Functions

function checkPythonEnvironment()
    % Check if Python is available in MATLAB

    fprintf('Checking Python environment...\n');

    try
        pe = pyenv;
        if pe.Status == "Loaded" || pe.Status == "NotLoaded"
            fprintf('  ✓ Python found: %s\n', char(pe.Executable));
            fprintf('  ✓ Version: %s\n\n', char(pe.Version));
        else
            error('Python not configured');
        end
    catch
        fprintf('  ✗ Python not found or not configured\n\n');
        fprintf('To configure Python in MATLAB:\n');
        fprintf('  1. Install Python 3.8+: https://www.python.org/\n');
        fprintf('  2. In MATLAB, run: pyenv(''Version'', ''path/to/python'')\n');
        fprintf('  3. Install packages: pip install torch diffusers transformers pillow\n\n');
        error('Please configure Python before running this script.');
    end
end

function createExamplePromptsFile(filename)
    % Create example prompts file with diverse image descriptions

    prompts = {
        'a beautiful landscape with mountains and a lake at sunset, photorealistic, 4k, detailed'
        'a cute golden retriever puppy playing in a garden, professional photography, bokeh effect'
        'modern minimalist office interior with large windows, natural lighting, architectural photography'
        'a bowl of fresh colorful fruits on a wooden table, food photography, vibrant colors'
        'futuristic cityscape with skyscrapers and flying vehicles, cyberpunk style, neon lights'
        'a cozy coffee shop interior with books and plants, warm lighting, inviting atmosphere'
        'abstract geometric patterns in blue and gold, digital art, symmetrical design'
        'a vintage red car on a desert highway, golden hour lighting, cinematic style'
        'tropical beach with palm trees and turquoise water, paradise, vacation destination'
        'a majestic lion portrait, wildlife photography, detailed fur, powerful gaze'
    };

    fid = fopen(filename, 'w', 'n', 'UTF-8');
    for i = 1:length(prompts)
        fprintf(fid, '%s\n', prompts{i});
    end
    fclose(fid);
end

function prompts = readPromptsFile(filename)
    % Read prompts from text file (one per line)

    fid = fopen(filename, 'r', 'n', 'UTF-8');
    prompts = {};

    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(strtrim(line))
            prompts{end+1} = strtrim(line);
        end
    end

    fclose(fid);
end

function displayGeneratedImages(outputFolder)
    % Display sample of generated images in a figure

    fprintf('\nDisplaying generated images...\n');

    % Get all generated images
    imageFiles = dir(fullfile(outputFolder, '*.png'));

    if isempty(imageFiles)
        fprintf('No images found to display.\n');
        return;
    end

    % Display up to 9 images
    numToDisplay = min(9, length(imageFiles));

    figure('Name', 'AI Generated Images', 'Position', [100, 100, 1200, 800]);

    for i = 1:numToDisplay
        img = imread(fullfile(outputFolder, imageFiles(i).name));

        subplot(3, 3, i);
        imshow(img);
        title(sprintf('Image %d', i), 'Interpreter', 'none', 'FontSize', 9);
        axis off;
    end

    sgtitle('AI Generated Images (Stable Diffusion)', 'FontSize', 14, 'FontWeight', 'bold');

    fprintf('Displaying %d of %d generated images\n', numToDisplay, length(imageFiles));
end
