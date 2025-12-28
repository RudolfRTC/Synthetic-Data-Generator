% =========================================================================
% AI IMAGE GENERATOR - VAE (Variational Autoencoder)
% =========================================================================
% Description: Uses VAE deep learning architecture to generate new images
%              by learning the latent distribution of your training data.
%
% Author: MATLAB AI Expert
% Date: December 2025
%
% Requirements:
%   - Deep Learning Toolbox
%   - Image Processing Toolbox
%   - GPU recommended (optional)
%
% How VAE works:
%   - Encoder compresses images into latent space distribution
%   - Decoder reconstructs images from latent space
%   - Can sample from latent space to generate new images
%   - Learns smooth interpolations between images
%
% Advantages over GAN:
%   - More stable training
%   - Better for smooth interpolations
%   - Generates variations of training data style
%
% NOTE: VAE generates images similar to training data with variations
% =========================================================================

function ai_image_generator_vae()
    %% Setup
    clear; clc; close all;
    fprintf('=== AI Image Generator (VAE) ===\n\n');

    % Configuration
    config.inputFolder = 'input_images';
    config.outputFolder = 'ai_generated_images_vae';
    config.modelFolder = 'trained_models';

    % Training parameters
    config.imageSize = [64, 64];      % Image dimensions
    config.latentDim = 128;            % Size of latent space
    config.numEpochs = 200;            % Training iterations
    config.miniBatchSize = 64;
    config.learnRate = 0.001;

    % Generation parameters
    config.numImagesToGenerate = 50;   % Number of new images to create

    %% Create output directories
    createDirectories(config);

    %% Load and preprocess dataset
    fprintf('Loading training images...\n');
    trainingImages = loadAndPreprocessImages(config);

    if isempty(trainingImages)
        error('No images loaded. Please add images to %s folder.', config.inputFolder);
    end

    fprintf('Loaded %d training images\n\n', size(trainingImages, 4));

    %% Build VAE Architecture
    fprintf('Building VAE architecture...\n');
    [encoder, decoder] = buildVAE(config);
    fprintf('  ✓ Encoder network created\n');
    fprintf('  ✓ Decoder network created\n\n');

    %% Train the VAE
    fprintf('Training VAE...\n');
    fprintf('Epochs: %d | Batch size: %d | Learn rate: %.4f\n\n', ...
        config.numEpochs, config.miniBatchSize, config.learnRate);

    [trainedEncoder, trainedDecoder] = trainVAE(encoder, decoder, trainingImages, config);

    fprintf('\n✓ Training complete!\n\n');

    %% Save trained models
    fprintf('Saving trained models...\n');
    save(fullfile(config.modelFolder, 'vae_encoder.mat'), 'trainedEncoder');
    save(fullfile(config.modelFolder, 'vae_decoder.mat'), 'trainedDecoder');
    fprintf('  ✓ Models saved to %s\n\n', config.modelFolder);

    %% Generate new synthetic images
    fprintf('Generating %d new AI images...\n', config.numImagesToGenerate);
    generateNewImages(trainedDecoder, config);

    %% Create interpolations between images
    fprintf('\nCreating smooth interpolations...\n');
    createInterpolations(trainedEncoder, trainedDecoder, trainingImages, config);

    fprintf('\n=== AI Image Generation Complete! ===\n');
    fprintf('Generated images saved to: %s\n', config.outputFolder);
    fprintf('Trained models saved to: %s\n', config.modelFolder);
end

%% Helper Functions

function createDirectories(config)
    folders = {config.outputFolder, config.modelFolder};
    for i = 1:length(folders)
        if ~exist(folders{i}, 'dir')
            mkdir(folders{i});
        end
    end
end

function images = loadAndPreprocessImages(config)
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

        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        end

        img = imresize(img, config.imageSize);
        img = single(img) / 255.0;  % Normalize to [0, 1]

        images(:, :, :, i) = img;
    end
end

function [encoder, decoder] = buildVAE(config)
    % Build Encoder Network (Image -> Latent Distribution)

    imageInputSize = [config.imageSize, 3];

    % Encoder layers
    encoderLayers = [
        imageInputLayer(imageInputSize, 'Name', 'input', 'Normalization', 'none')

        % Convolutional blocks
        convolution2dLayer(3, 32, 'Padding', 'same', 'Stride', 2, 'Name', 'conv1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')

        convolution2dLayer(3, 64, 'Padding', 'same', 'Stride', 2, 'Name', 'conv2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')

        convolution2dLayer(3, 128, 'Padding', 'same', 'Stride', 2, 'Name', 'conv3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')

        convolution2dLayer(3, 256, 'Padding', 'same', 'Stride', 2, 'Name', 'conv4')
        batchNormalizationLayer('Name', 'bn4')
        reluLayer('Name', 'relu4')

        % Flatten for latent space
        fullyConnectedLayer(config.latentDim * 2, 'Name', 'fc_latent')  % Mean and log-variance
    ];

    encoder = dlnetwork(encoderLayers);

    % Build Decoder Network (Latent -> Image)

    decoderLayers = [
        featureInputLayer(config.latentDim, 'Name', 'latent_input')

        % Project back to spatial dimensions
        fullyConnectedLayer(4*4*256, 'Name', 'fc_decode')
        functionLayer(@(X) reshapeForConvolution(X, 4, 4, 256), 'Name', 'reshape', 'Formattable', true)

        % Upsampling blocks
        transposedConv2dLayer(3, 128, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv1')
        batchNormalizationLayer('Name', 'bn_d1')
        reluLayer('Name', 'relu_d1')

        transposedConv2dLayer(3, 64, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv2')
        batchNormalizationLayer('Name', 'bn_d2')
        reluLayer('Name', 'relu_d2')

        transposedConv2dLayer(3, 32, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv3')
        batchNormalizationLayer('Name', 'bn_d3')
        reluLayer('Name', 'relu_d3')

        transposedConv2dLayer(3, 16, 'Stride', 2, 'Cropping', 'same', 'Name', 'tconv4')
        batchNormalizationLayer('Name', 'bn_d4')
        reluLayer('Name', 'relu_d4')

        % Output layer
        convolution2dLayer(3, 3, 'Padding', 'same', 'Name', 'conv_out')
        sigmoidLayer('Name', 'sigmoid')
    ];

    decoder = dlnetwork(decoderLayers);
end

function X = reshapeForConvolution(X, h, w, c)
    X = reshape(X, h, w, c, []);
end

function [trainedEncoder, trainedDecoder] = trainVAE(encoder, decoder, trainingImages, config)
    % Train VAE using custom training loop

    % Initialize Adam optimizers
    avgGradEnc = [];
    avgGradSqEnc = [];
    avgGradDec = [];
    avgGradSqDec = [];

    numImages = size(trainingImages, 4);
    iterationsPerEpoch = floor(numImages / config.miniBatchSize);

    iteration = 0;
    beta = 0.5;  % Weight for KL divergence term

    % Training loop
    for epoch = 1:config.numEpochs
        % Shuffle data
        idx = randperm(numImages);
        trainingImages = trainingImages(:, :, :, idx);

        epochLoss = 0;

        for iter = 1:iterationsPerEpoch
            iteration = iteration + 1;

            % Get mini-batch
            idxBatch = (iter-1)*config.miniBatchSize+1:iter*config.miniBatchSize;
            X = trainingImages(:, :, :, idxBatch);

            % Convert to dlarray
            dlX = dlarray(X, 'SSCB');

            % Compute gradients
            [gradEnc, gradDec, loss] = dlfeval(@modelGradients, encoder, decoder, dlX, beta, config.latentDim);

            % Update networks
            [encoder, avgGradEnc, avgGradSqEnc] = adamupdate(encoder, gradEnc, avgGradEnc, avgGradSqEnc, iteration, config.learnRate);
            [decoder, avgGradDec, avgGradSqDec] = adamupdate(decoder, gradDec, avgGradDec, avgGradSqDec, iteration, config.learnRate);

            epochLoss = epochLoss + extractdata(loss);
        end

        % Display progress
        if mod(epoch, 20) == 0 || epoch == 1
            avgLoss = epochLoss / iterationsPerEpoch;
            fprintf('Epoch %d/%d - Loss: %.4f\n', epoch, config.numEpochs, avgLoss);
        end
    end

    trainedEncoder = encoder;
    trainedDecoder = decoder;
end

function [gradEnc, gradDec, loss] = modelGradients(encoder, decoder, X, beta, latentDim)
    % Forward pass through encoder
    encoded = forward(encoder, X);

    % Split into mean and log-variance
    mu = encoded(1:latentDim, :);
    logVar = encoded(latentDim+1:end, :);

    % Reparameterization trick: z = mu + sigma * epsilon
    epsilon = randn(size(mu), 'like', mu);
    sigma = exp(0.5 * logVar);
    z = mu + sigma .* epsilon;

    % Forward pass through decoder
    reconstructed = forward(decoder, z);

    % Calculate losses
    % Reconstruction loss (MSE)
    reconstructionLoss = mean((X - reconstructed).^2, 'all');

    % KL divergence loss
    klLoss = -0.5 * mean(1 + logVar - mu.^2 - exp(logVar), 'all');

    % Total loss
    loss = reconstructionLoss + beta * klLoss;

    % Compute gradients
    [gradEnc, gradDec] = dlgradient(loss, encoder.Learnables, decoder.Learnables);
end

function generateNewImages(decoder, config)
    % Generate new images by sampling from latent space

    for i = 1:config.numImagesToGenerate
        % Sample from standard normal distribution
        z = randn(config.latentDim, 1, 'single');
        dlZ = dlarray(z, 'CB');

        % Generate image
        dlGeneratedImage = forward(decoder, dlZ);
        generatedImage = extractdata(dlGeneratedImage);

        % Convert to uint8
        generatedImage = uint8(generatedImage * 255);

        % Ensure correct size
        if size(generatedImage, 1) ~= config.imageSize(1) || size(generatedImage, 2) ~= config.imageSize(2)
            generatedImage = imresize(generatedImage, config.imageSize);
        end

        % Save image
        outputFilename = sprintf('vae_generated_%04d.png', i);
        imwrite(generatedImage, fullfile(config.outputFolder, outputFilename));

        if mod(i, 10) == 0
            fprintf('  Generated %d/%d images\n', i, config.numImagesToGenerate);
        end
    end
end

function createInterpolations(encoder, decoder, trainingImages, config)
    % Create smooth interpolations between two random images

    numInterpolations = 5;
    stepsPerInterpolation = 10;

    for interpIdx = 1:numInterpolations
        % Pick two random images
        idx1 = randi(size(trainingImages, 4));
        idx2 = randi(size(trainingImages, 4));

        img1 = trainingImages(:, :, :, idx1);
        img2 = trainingImages(:, :, :, idx2);

        % Encode to latent space
        dlImg1 = dlarray(img1, 'SSCB');
        dlImg2 = dlarray(img2, 'SSCB');

        encoded1 = forward(encoder, dlImg1);
        encoded2 = forward(encoder, dlImg2);

        z1 = encoded1(1:config.latentDim, :);
        z2 = encoded2(1:config.latentDim, :);

        % Create interpolation
        for step = 1:stepsPerInterpolation
            alpha = (step - 1) / (stepsPerInterpolation - 1);
            zInterp = (1 - alpha) * z1 + alpha * z2;

            % Decode
            dlGenerated = forward(decoder, zInterp);
            generated = extractdata(dlGenerated);
            generated = uint8(generated * 255);

            % Save
            filename = sprintf('vae_interp_%02d_step_%02d.png', interpIdx, step);
            imwrite(generated, fullfile(config.outputFolder, filename));
        end
    end

    fprintf('  Created %d interpolation sequences\n', numInterpolations);
end
