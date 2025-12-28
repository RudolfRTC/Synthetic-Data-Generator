# Synthetic Data Generator

🎨 **Complete toolkit for generating synthetic images** - from basic augmentation to advanced AI generation!

This repository provides multiple approaches to create synthetic image data:
1. **Data Augmentation** - Transform existing images (fast, no training)
2. **AI Generation** - Create completely NEW images using Deep Learning (GAN, VAE, Stable Diffusion)

## 📚 Table of Contents

- [Quick Start Guide](#quick-start-guide)
- [Data Augmentation](#data-augmentation) - Traditional image transformations
- [AI Image Generation](#ai-image-generation) - Deep Learning powered (NEW! 🤖)
- [Installation](#installation)
- [Documentation](#documentation)

---

## Quick Start Guide

### Which Method Should I Use?

| Method | Best For | Training Required | Time |
|--------|----------|-------------------|------|
| **Data Augmentation** | Expanding existing datasets | ❌ No | ⚡ Instant |
| **Stable Diffusion** | Photorealistic images from text | ❌ No | ⚡ Seconds |
| **GAN** | Dataset-specific realistic images | ✅ Yes | ⏰ Hours |
| **VAE** | Style learning & interpolations | ✅ Yes | ⏰ Hours |

👉 **Most users should start with Data Augmentation or Stable Diffusion!**

---

## Data Augmentation

Transform existing images to create variations - **no AI training required!**

### Features

- **Multiple Transformation Types**: Rotation, flipping, scaling, brightness adjustment, and Gaussian noise
- **Batch Processing**: Automatically processes all images in a folder
- **Systematic Naming**: Organized output file naming (e.g., `img1_aug_1.jpg`, `img1_aug_2.jpg`)
- **Two Versions Available**: Standard and Deep Learning Toolbox versions
- **Flexible Configuration**: Easy to adjust augmentation parameters

## Requirements

### For Standard Version (`image_augmentation.m`)
- MATLAB R2019a or later
- Image Processing Toolbox

### For Deep Learning Version (`image_augmentation_deep_learning.m`)
- MATLAB R2019a or later
- Image Processing Toolbox
- Deep Learning Toolbox

## Quick Start

### 1. Prepare Your Images

Create a folder named `input_images` in the same directory as the script and add your images:

```
Synthetic-Data-Generator/
├── image_augmentation.m
├── input_images/
│   ├── image1.jpg
│   ├── image2.png
│   └── image3.jpg
└── augmented_images/  (created automatically)
```

### 2. Run the Script

Open MATLAB and navigate to the script directory, then run:

```matlab
% For standard version (recommended for most use cases)
image_augmentation()

% OR for Deep Learning Toolbox version
image_augmentation_deep_learning()
```

### 3. View Results

Augmented images will be saved in the `augmented_images` folder with systematic naming:
- `image1_aug_1.jpg`
- `image1_aug_2.jpg`
- `image1_aug_3.jpg`
- `image1_aug_4.jpg`
- `image1_aug_5.jpg`
- etc.

## Supported Image Formats

- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- BMP (`.bmp`)
- TIFF (`.tif`, `.tiff`)

## Augmentation Transformations

Both scripts apply the following transformations randomly:

### 1. **Random Rotation**
- Range: -30° to 30°
- Probability: 70%
- Prevents edge effects with bilinear interpolation and cropping

### 2. **Random Flipping**
- Types: Horizontal, Vertical, or None
- Probability: 33% for horizontal, 33% for vertical, 33% for no flip

### 3. **Random Scaling/Zooming**
- Range: 0.8x to 1.2x
- Probability: 60%
- Maintains original image dimensions through cropping or padding

### 4. **Brightness Adjustment**
- Range: 0.7x to 1.3x (darker to lighter)
- Probability: 70%
- Simulates different lighting conditions

### 5. **Gaussian Noise**
- Variance: 0.001 to 0.005 (for uint8 images)
- Probability: 60%
- Simulates sensor noise or image grain

## Configuration

You can modify the following parameters in the script:

```matlab
% Number of augmented images per original image (default: 5)
numAugmentationsPerImage = 5;

% Input and output folder names
inputFolder = 'input_images';
outputFolder = 'augmented_images';
```

### Adjusting Transformation Parameters

In the `applyRandomTransformations` function, you can modify:

```matlab
% Rotation angle range
angle = (rand() - 0.5) * 60;  % Change 60 to adjust range

% Scaling factor range
scaleFactor = 0.8 + rand() * 0.4;  % Adjust 0.8 and 0.4

% Brightness range
brightnessFactor = 0.7 + rand() * 0.6;  % Adjust 0.7 and 0.6

% Noise variance
noiseVariance = 0.001 + rand() * 0.004;  % Adjust values

% Transformation probabilities
if rand() > 0.3  % Change 0.3 to adjust probability (higher = less likely)
```

## Which Version Should I Use?

### Use `image_augmentation.m` (Standard) if:
- ✅ You want maximum control over transformations
- ✅ You need fine-tuned augmentation parameters
- ✅ You don't have Deep Learning Toolbox
- ✅ You want to customize individual transformations easily

### Use `image_augmentation_deep_learning.m` if:
- ✅ You have Deep Learning Toolbox installed
- ✅ You're working on deep learning projects
- ✅ You want to integrate with other Deep Learning Toolbox workflows
- ✅ You prefer MATLAB's built-in augmentation framework

**Recommendation**: For this specific use case, `image_augmentation.m` is recommended because it provides more flexibility and doesn't require additional toolboxes.

## Example Usage

### Basic Usage

```matlab
% Simply run the script
image_augmentation()
```

### Expected Output

```
=== Image Data Augmentation Script ===

Found 10 images in "input_images" folder
Generating 5 augmented versions per image...

[1/10] Processing: cat.jpg
  -> Generated: cat_aug_1.jpg
  -> Generated: cat_aug_2.jpg
  -> Generated: cat_aug_3.jpg
  -> Generated: cat_aug_4.jpg
  -> Generated: cat_aug_5.jpg
[2/10] Processing: dog.png
  -> Generated: dog_aug_1.png
  ...

=== Augmentation Complete ===
Original images: 10
Augmented images: 50
Total images: 60
Output location: augmented_images
```

## Performance Considerations

- **Processing Time**: Approximately 0.1-0.5 seconds per augmented image (depends on image size and transformations)
- **Memory Usage**: Minimal - processes one image at a time
- **Disk Space**: Ensure sufficient space for augmented images (approximately 5x original dataset size)

## Troubleshooting

### "Input folder does not exist" Error
**Solution**: Create an `input_images` folder in the same directory as the script and add your images.

### "No images found" Error
**Solution**: Ensure your images have supported extensions (.jpg, .png, .bmp, .tif) and are located in the `input_images` folder.

### Images Look Too Different from Originals
**Solution**: Reduce transformation probabilities or narrow the ranges for rotation, scaling, and brightness in the `applyRandomTransformations` function.

### Images Have Too Much Noise
**Solution**: Reduce the noise variance range or lower the probability of adding noise.

## Advanced Customization

### Adding New Transformations

You can add custom transformations in the `applyRandomTransformations` function:

```matlab
%% Custom Transformation Example: Color Jitter
if rand() > 0.5
    % Adjust saturation
    hsvImg = rgb2hsv(augmentedImg);
    hsvImg(:,:,2) = hsvImg(:,:,2) * (0.8 + rand() * 0.4);
    augmentedImg = hsv2rgb(hsvImg);
end
```

### Processing Specific Image Types Only

Modify the `imageExtensions` array:

```matlab
% Only process JPEG images
imageExtensions = {'*.jpg', '*.jpeg'};
```

## Performance Optimization Tips

1. **Use Solid State Drive (SSD)** for faster read/write operations
2. **Reduce Image Size** before augmentation if high resolution isn't needed
3. **Adjust `numAugmentationsPerImage`** based on your dataset size needs
4. **Parallel Processing** (advanced): Consider using `parfor` for large datasets

## License

This script is provided as-is for educational and research purposes.

## Author

Created by MATLAB Expert
Date: December 2025

## Version History

- **v1.0** (December 2025): Initial release with standard and Deep Learning Toolbox versions

## Contributing

Feel free to modify and extend this script for your specific needs. Common extensions include:
- Contrast adjustment
- Color space transformations
- Advanced geometric transformations
- Blur/sharpening filters
- Custom augmentation pipelines

---

## AI Image Generation

🤖 **Generate COMPLETELY NEW images using Artificial Intelligence!**

Unlike data augmentation which transforms existing images, AI generation creates entirely new content from scratch or from text descriptions.

### Available AI Methods

#### 1. **Stable Diffusion** (RECOMMENDED) 🎨
- **Generate photorealistic images from text prompts**
- No training required - uses pretrained models
- Highest quality output
- Examples: "a sunset over mountains", "a cute robot", etc.

```bash
# Python
python ai_image_generator_stable_diffusion.py --prompt "your text here"

# MATLAB Wrapper
ai_image_generator_matlab_wrapper()
```

**Files**: `ai_image_generator_stable_diffusion.py`, `ai_image_generator_matlab_wrapper.m`

#### 2. **GAN (Generative Adversarial Network)** ⚡
- Learns from your dataset to generate similar images
- Creates realistic variations
- Requires training on your data (2-6 hours with GPU)

```matlab
ai_image_generator_gan()
```

**File**: `ai_image_generator_gan.m`

#### 3. **VAE (Variational Autoencoder)** 🔄
- Learns image style and creates variations
- Generates smooth interpolations between images
- More stable training than GAN

```matlab
ai_image_generator_vae()
```

**File**: `ai_image_generator_vae.m`

### Setup for AI Generation

**For Stable Diffusion (Python)**:
```bash
pip install -r requirements.txt
```

**For GAN/VAE (MATLAB)**:
- Deep Learning Toolbox
- Image Processing Toolbox
- GPU recommended

### 📖 Complete AI Documentation

See **[AI_GENERATOR_README.md](AI_GENERATOR_README.md)** for:
- Detailed setup instructions
- Configuration parameters
- Prompt engineering guide
- Troubleshooting
- Hardware requirements
- Examples and tutorials

---

## Installation

### Basic Setup (Data Augmentation)
1. Install MATLAB R2019a or later
2. Install Image Processing Toolbox
3. Clone this repository
4. Add images to `input_images/` folder
5. Run `image_augmentation()`

### AI Setup (Optional)

**For Stable Diffusion**:
```bash
# Install Python dependencies
pip install -r requirements.txt

# Test installation
python ai_image_generator_stable_diffusion.py --prompt "test image"
```

**For GAN/VAE**:
- Install MATLAB Deep Learning Toolbox
- GPU with CUDA support recommended
- Add images to `input_images/` folder

---

## Documentation

### Main Documentation Files

- **[README.md](README.md)** - This file, overview and data augmentation
- **[AI_GENERATOR_README.md](AI_GENERATOR_README.md)** - Complete AI generation guide
- **[example_usage.m](example_usage.m)** - MATLAB examples and demos
- **[requirements.txt](requirements.txt)** - Python dependencies

### All Available Scripts

**Data Augmentation**:
- `image_augmentation.m` - Standard augmentation
- `image_augmentation_deep_learning.m` - Deep Learning Toolbox version
- `visualize_augmentations.m` - Preview transformations

**AI Generation**:
- `ai_image_generator_gan.m` - GAN implementation
- `ai_image_generator_vae.m` - VAE implementation
- `ai_image_generator_stable_diffusion.py` - Stable Diffusion (Python)
- `ai_image_generator_matlab_wrapper.m` - MATLAB interface to Stable Diffusion

**Utilities**:
- `example_usage.m` - Examples and tutorials

---

## Contact & Support

For issues or questions, please refer to:
- MATLAB Documentation:
  - Image Processing Toolbox: https://www.mathworks.com/help/images/
  - Deep Learning Toolbox: https://www.mathworks.com/help/deeplearning/
- Stable Diffusion: https://huggingface.co/docs/diffusers
- PyTorch: https://pytorch.org/
