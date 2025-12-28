% =========================================================================
% AI IMAGE GENERATOR - GAN (Generative Adversarial Network)
% =========================================================================
% Description: Uses Deep Learning to generate completely NEW synthetic images
%              based on training from existing dataset using GAN architecture.
%
% Author: MATLAB AI Expert
% Date: December 2025
%
% Requirements:
%   - Deep Learning Toolbox
%   - Image Processing Toolbox
%   - GPU recommended for faster training (optional)
%
% How it works:
%   - Trains a GAN on your image dataset
%   - Generator creates new images from random noise
%   - Discriminator learns to distinguish real from fake
%   - After training, generates completely new synthetic images
%
% NOTE: This is REAL AI - it generates NEW images, not just transforms!
% =========================================================================

function ai_image_generator_gan()
    %% Setup
    clear; clc; close all;
    fprintf('=== AI Image Generator (GAN) ===\n\n');

    % Configuration
    config.inputFolder = 'input_images';
    config.outputFolder = 'ai_generated_images';
    config.modelFolder = 'trained_models';

    % Training parameters
    config.imageSize = [64, 64];  % Image dimensions (64x64 for faster training)
    config.numLatentInputs = 100;  % Size of random noise vector
    config.numEpochs = 500;  % Training iterations
    config.miniBatchSize = 128;
    config.learnRate = 0.0002;

    % Generation parameters
    config.numImagesToGenerate = 100;  % How many AI images to create

    %% Create output directories
    createDirectories(config);

    %% Load and preprocess dataset
    fprintf('Loading training images...\n');
    trainingImages = loadAndPreprocessImages(config);

    if isempty(trainingImages)
        error('No images loaded. Please add images to %s folder.', config.inputFolder);
    end

    fprintf('Loaded %d training images\n\n', size(trainingImages, 4));

    %% Build GAN Architecture
    fprintf('Building GAN architecture...\n');
    [generator, discriminator] = buildGAN(config);
    fprintf('  ✓ Generator network created\n');
    fprintf('  ✓ Discriminator network created\n\n');

    %% Train the GAN
    fprintf('Training GAN (this may take a while)...\n');
    fprintf('Epochs: %d | Batch size: %d | Learn rate: %.4f\n\n', ...
        config.numEpochs, config.miniBatchSize, config.learnRate);

    [trainedGenerator, trainedDiscriminator] = trainGAN(generator, discriminator, trainingImages, config);

    fprintf('\n✓ Training complete!\n\n');

    %% Save trained models
    fprintf('Saving trained models...\n');
    save(fullfile(config.modelFolder, 'gan_generator.mat'), 'trainedGenerator');
    save(fullfile(config.modelFolder, 'gan_discriminator.mat'), 'trainedDiscriminator');
    fprintf('  ✓ Models saved to %s\n\n', config.modelFolder);

    %% Generate new synthetic images
    fprintf('Generating %d new AI images...\n', config.numImagesToGenerate);
    generateNewImages(trainedGenerator, config);

    fprintf('\n=== AI Image Generation Complete! ===\n');
    fprintf('Generated images saved to: %s\n', config.outputFolder);
    fprintf('Trained models saved to: %s\n', config.modelFolder);
end

%% Helper Functions

function createDirectories(config)
    % Create necessary directories
    folders = {config.outputFolder, config.modelFolder};
    for i = 1:length(folders)
        if ~exist(folders{i}, 'dir')
            mkdir(folders{i});
        end
    end
end

function images = loadAndPreprocessImages(config)
    % Load and preprocess all training images
    imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp'};
    imageFiles = [];

    for i = 1:length(imageExtensions)
        currentFiles = dir(fullfile(config.inputFolder, imageExtensions{i}));
        imageFiles = [imageFiles; currentFiles];
    end

    numImages = length(imageFiles);
    images = zeros([config.imageSize, 3, numImages], 'single');

    for i = 1:numImages
        img = imread(fullfile(config.inputFolder, imageFiles(i).name));

        % Convert grayscale to RGB
        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        end

        % Resize to target size
        img = imresize(img, config.imageSize);

        % Normalize to [-1, 1]
        img = single(img) / 127.5 - 1;

        images(:, :, :, i) = img;
    end
end

function [generator, discriminator] = buildGAN(config)
    % Build Generator Network
    % Takes random noise and generates images

    filterSize = 5;
    numFilters = 64;

    layersGenerator = [
        featureInputLayer(config.numLatentInputs, 'Name', 'in')

        % Project and reshape
        fullyConnectedLayer(4*4*512, 'Name', 'fc')
        functionLayer(@(X) reshapeForConvolution(X), 'Name', 'reshape', ...
            'Formattable', true)

        % Upsampling blocks
        transposedConv2dLayer(4, 256, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')

        transposedConv2dLayer(4, 128, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')

        transposedConv2dLayer(4, 64, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')

        transposedConv2dLayer(4, 32, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv4')
        batchNormalizationLayer('Name', 'bn4')
        reluLayer('Name', 'relu4')

        % Output layer
        convolution2dLayer(filterSize, 3, 'Padding', 'same', 'Name', 'conv_out')
        tanhLayer('Name', 'tanh')
    ];

    generator = dlnetwork(layersGenerator);

    % Build Discriminator Network
    % Classifies images as real or fake

    layersDiscriminator = [
        imageInputLayer([config.imageSize, 3], 'Name', 'in', 'Normalization', 'none')

        % Downsampling blocks
        convolution2dLayer(4, 64, 'Stride', 2, 'Padding', 'same', 'Name', 'conv1')
        leakyReluLayer(0.2, 'Name', 'lrelu1')
        dropoutLayer(0.3, 'Name', 'drop1')

        convolution2dLayer(4, 128, 'Stride', 2, 'Padding', 'same', 'Name', 'conv2')
        batchNormalizationLayer('Name', 'bn2')
        leakyReluLayer(0.2, 'Name', 'lrelu2')
        dropoutLayer(0.3, 'Name', 'drop2')

        convolution2dLayer(4, 256, 'Stride', 2, 'Padding', 'same', 'Name', 'conv3')
        batchNormalizationLayer('Name', 'bn3')
        leakyReluLayer(0.2, 'Name', 'lrelu3')
        dropoutLayer(0.3, 'Name', 'drop3')

        convolution2dLayer(4, 512, 'Stride', 2, 'Padding', 'same', 'Name', 'conv4')
        batchNormalizationLayer('Name', 'bn4')
        leakyReluLayer(0.2, 'Name', 'lrelu4')

        % Classifier
        convolution2dLayer(4, 1, 'Name', 'conv_out')
        sigmoidLayer('Name', 'sigmoid')
    ];

    discriminator = dlnetwork(layersDiscriminator);
end

function X = reshapeForConvolution(X)
    % Reshape for convolutional layers
    X = reshape(X, 4, 4, 512, []);
end

function [trainedGenerator, trainedDiscriminator] = trainGAN(generator, discriminator, trainingImages, config)
    % Train the GAN using custom training loop

    % Initialize optimizers
    avgGradG = [];
    avgGradSqG = [];
    avgGradD = [];
    avgGradSqD = [];

    numImages = size(trainingImages, 4);
    iterationsPerEpoch = floor(numImages / config.miniBatchSize);

    iteration = 0;

    % Training loop
    for epoch = 1:config.numEpochs
        % Shuffle data
        idx = randperm(numImages);
        trainingImages = trainingImages(:, :, :, idx);

        for iter = 1:iterationsPerEpoch
            iteration = iteration + 1;

            % Get mini-batch
            idxBatch = (iter-1)*config.miniBatchSize+1:iter*config.miniBatchSize;
            realImages = trainingImages(:, :, :, idxBatch);

            % Generate random noise
            Z = randn(config.numLatentInputs, config.miniBatchSize, 'single');

            % Convert to dlarray
            dlZ = dlarray(Z, 'CB');
            dlRealImages = dlarray(realImages, 'SSCB');

            % Evaluate gradients and update networks
            [gradG, gradD] = dlfeval(@modelGradients, generator, discriminator, dlRealImages, dlZ);

            % Update generator
            [generator, avgGradG, avgGradSqG] = adamupdate(generator, gradG, avgGradG, avgGradSqG, iteration, config.learnRate);

            % Update discriminator
            [discriminator, avgGradD, avgGradSqD] = adamupdate(discriminator, gradD, avgGradD, avgGradSqD, iteration, config.learnRate);
        end

        % Display progress
        if mod(epoch, 50) == 0 || epoch == 1
            fprintf('Epoch %d/%d - Training in progress...\n', epoch, config.numEpochs);
        end
    end

    trainedGenerator = generator;
    trainedDiscriminator = discriminator;
end

function [gradG, gradD] = modelGradients(generator, discriminator, realImages, Z)
    % Calculate gradients for both networks

    % Generate fake images
    fakeImages = forward(generator, Z);

    % Discriminator predictions
    predReal = forward(discriminator, realImages);
    predFake = forward(discriminator, fakeImages);

    % Calculate losses
    lossReal = -mean(log(predReal + 1e-8));
    lossFake = -mean(log(1 - predFake + 1e-8));
    lossD = lossReal + lossFake;

    lossG = -mean(log(predFake + 1e-8));

    % Calculate gradients
    gradG = dlgradient(lossG, generator.Learnables);
    gradD = dlgradient(lossD, discriminator.Learnables);
end

function generateNewImages(generator, config)
    % Generate and save new synthetic images

    for i = 1:config.numImagesToGenerate
        % Generate random noise
        Z = randn(config.numLatentInputs, 1, 'single');
        dlZ = dlarray(Z, 'CB');

        % Generate image
        dlGeneratedImage = forward(generator, dlZ);
        generatedImage = extractdata(dlGeneratedImage);

        % Denormalize from [-1, 1] to [0, 1]
        generatedImage = (generatedImage + 1) / 2;

        % Convert to uint8
        generatedImage = uint8(generatedImage * 255);

        % Save image
        outputFilename = sprintf('ai_generated_%04d.png', i);
        imwrite(generatedImage, fullfile(config.outputFolder, outputFilename));

        if mod(i, 10) == 0
            fprintf('  Generated %d/%d images\n', i, config.numImagesToGenerate);
        end
    end
end
