# AI Image Generators - Complete Guide

🤖 **Generate COMPLETELY NEW images using Artificial Intelligence!**

This toolkit provides **three powerful AI-based methods** to generate synthetic images using deep learning, not just transformations.

---

## 🎯 What's the Difference?

| Feature | Data Augmentation | AI Image Generation |
|---------|------------------|---------------------|
| **Method** | Transforms existing images | Creates NEW images from scratch |
| **AI Used** | ❌ No | ✅ Yes - Deep Learning |
| **Output** | Variations of input | Completely new content |
| **Training** | Not needed | Requires training or pretrained models |
| **Use Case** | Increase dataset size | Generate novel synthetic data |

---

## 📦 Available AI Methods

### 1. **GAN (Generative Adversarial Network)** ⚡
**File**: `ai_image_generator_gan.m`

**Best For**: Creating realistic variations of your dataset

**How it works**:
- Trains two neural networks (Generator vs Discriminator)
- Generator learns to create images that fool the Discriminator
- After training, generates completely new images

**Pros**:
- ✅ Generates very realistic images
- ✅ Completely new content (not just transforms)
- ✅ Pure MATLAB implementation

**Cons**:
- ⚠️ Requires substantial training time
- ⚠️ Needs GPU for reasonable speed
- ⚠️ Requires good dataset (50+ images minimum)

**Quick Start**:
```matlab
% Add images to input_images folder, then run:
ai_image_generator_gan()
```

---

### 2. **Stable Diffusion** 🎨 (RECOMMENDED)
**Files**: `ai_image_generator_stable_diffusion.py` + `ai_image_generator_matlab_wrapper.m`

**Best For**: Generating photorealistic images from text descriptions

**How it works**:
- Uses pretrained state-of-the-art AI model
- Generates images from text prompts
- No training needed!

**Pros**:
- ✅ Best quality results
- ✅ No training required
- ✅ Generate from text descriptions
- ✅ Photorealistic output
- ✅ Can create ANY image you describe

**Cons**:
- ⚠️ Requires Python + PyTorch installation
- ⚠️ Downloads 4GB model on first run
- ⚠️ GPU highly recommended

**Quick Start**:

**Python (Recommended)**:
```bash
# Install dependencies
pip install torch diffusers transformers pillow

# Generate images from prompts
python ai_image_generator_stable_diffusion.py --prompt "a beautiful sunset over mountains"
```

**MATLAB Wrapper**:
```matlab
% Configure Python in MATLAB first
pyenv('Version', 'path/to/python')

% Run the wrapper
ai_image_generator_matlab_wrapper()
```

---

### 3. **VAE (Variational Autoencoder)** 🔄
**File**: `ai_image_generator_vae.m`

**Best For**: Learning style from dataset and creating smooth variations

**How it works**:
- Learns compressed representation of your images
- Can generate new images from the learned distribution
- Creates smooth interpolations between images

**Pros**:
- ✅ More stable training than GAN
- ✅ Smooth interpolations between images
- ✅ Good for learning specific style
- ✅ Pure MATLAB implementation

**Cons**:
- ⚠️ Images may be blurrier than GAN
- ⚠️ Still requires training
- ⚠️ GPU recommended

**Quick Start**:
```matlab
% Add images to input_images folder, then run:
ai_image_generator_vae()
```

---

## 🚀 Installation & Setup

### For GAN and VAE (MATLAB only)

**Requirements**:
- MATLAB R2020a or later
- Deep Learning Toolbox
- Image Processing Toolbox
- GPU recommended (NVIDIA with CUDA support)

**Setup**:
1. Place training images in `input_images/` folder
2. Run the desired script
3. Find generated images in output folders

---

### For Stable Diffusion (Python + MATLAB)

**Step 1: Install Python Dependencies**
```bash
# Install PyTorch (GPU version recommended)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# Install Stable Diffusion libraries
pip install diffusers transformers accelerate pillow numpy
```

**Step 2: Configure Python in MATLAB** (for MATLAB wrapper)
```matlab
% Find your Python executable
pyenv

% If not configured, set it:
pyenv('Version', 'C:\Python311\python.exe')  % Windows example
% pyenv('Version', '/usr/bin/python3')       % Linux/Mac example
```

**Step 3: Test Installation**
```bash
# Test Python version directly
python ai_image_generator_stable_diffusion.py --prompt "a test image"
```

---

## 📖 Detailed Usage Examples

### Example 1: GAN - Generate Images Similar to Your Dataset

```matlab
% 1. Prepare dataset
%    Place 50-200 images in input_images/
%    (more images = better results)

% 2. Run training and generation
ai_image_generator_gan()

% 3. Results will be in ai_generated_images/
%    - 100 completely new synthetic images
%    - Trained model saved for future use

% 4. To generate more images later:
%    Load the saved model and call generateNewImages()
```

**Training Time**: 2-6 hours (GPU), 20-50 hours (CPU)
**Output**: Images similar in style to your training data

---

### Example 2: Stable Diffusion - Text to Image

**Create a prompts file** (`image_prompts.txt`):
```
a beautiful mountain landscape at sunset, photorealistic, 4k
a cute robot holding flowers, digital art, kawaii style
modern architecture building, glass facade, urban photography
a bowl of ramen with vegetables, food photography, detailed
```

**Generate from command line**:
```bash
python ai_image_generator_stable_diffusion.py \
    --prompts-file image_prompts.txt \
    --num-images 3 \
    --width 768 \
    --height 768 \
    --steps 30
```

**Or use MATLAB wrapper**:
```matlab
ai_image_generator_matlab_wrapper()
```

**Generation Time**: 5-15 seconds per image (GPU), 2-5 minutes (CPU)
**Output**: Photorealistic images matching your text descriptions

---

### Example 3: VAE - Learn and Generate

```matlab
% 1. Prepare dataset (30-100 images minimum)
%    VAE works well with smaller datasets than GAN

% 2. Train and generate
ai_image_generator_vae()

% 3. Check output folders:
%    - vae_generated_XXXX.png: New synthetic images
%    - vae_interp_XX_step_XX.png: Smooth transitions between images

% 4. The interpolations show smooth morphing between images
%    Great for understanding the latent space!
```

**Training Time**: 1-3 hours (GPU), 10-30 hours (CPU)
**Output**: Style-matched images + interpolations

---

## 🎛️ Configuration & Parameters

### GAN Configuration

Located in `ai_image_generator_gan.m`:

```matlab
config.imageSize = [64, 64];          % Image resolution (higher = slower)
config.numLatentInputs = 100;         % Noise vector size
config.numEpochs = 500;               % Training iterations (more = better quality)
config.miniBatchSize = 128;           % Batch size (GPU memory dependent)
config.learnRate = 0.0002;            % Learning rate
config.numImagesToGenerate = 100;     % How many images to create
```

**Tuning Tips**:
- Start with 64x64 images for faster experimentation
- Increase `numEpochs` if images look unrealistic
- Reduce `miniBatchSize` if GPU runs out of memory

---

### Stable Diffusion Parameters

**Quality vs Speed**:
```bash
# Fast (lower quality) - 10 seconds per image
--steps 20 --guidance 6

# Balanced (recommended) - 15 seconds per image
--steps 25 --guidance 7.5

# High quality - 30 seconds per image
--steps 50 --guidance 10
```

**Resolution Options**:
```bash
# Standard
--width 512 --height 512

# Portrait
--width 512 --height 768

# Landscape
--width 768 --height 512

# High-res (slower, more VRAM)
--width 1024 --height 1024
```

**Negative Prompts** (what to avoid):
```bash
--negative-prompt "blurry, low quality, distorted, deformed, ugly, watermark"
```

---

### VAE Configuration

Located in `ai_image_generator_vae.m`:

```matlab
config.imageSize = [64, 64];          % Image dimensions
config.latentDim = 128;               % Latent space size (complexity)
config.numEpochs = 200;               % Training iterations
config.miniBatchSize = 64;            % Batch size
config.learnRate = 0.001;             % Learning rate
config.numImagesToGenerate = 50;      % Output count
```

---

## 💻 Hardware Requirements

### Minimum Requirements
- **CPU**: Modern multi-core processor
- **RAM**: 8GB+
- **Storage**: 10GB free space
- **OS**: Windows 10+, Linux, macOS

### Recommended for GAN/VAE
- **GPU**: NVIDIA GTX 1060 (6GB VRAM) or better
- **RAM**: 16GB+
- **CUDA**: Version 11.0+

### Recommended for Stable Diffusion
- **GPU**: NVIDIA RTX 3060 (12GB VRAM) or better
- **RAM**: 16GB+
- **CUDA**: Version 11.7+
- **Storage**: 20GB+ (for models)

### CPU-Only Mode
All methods work on CPU, but expect:
- **GAN/VAE**: 10-50x slower training
- **Stable Diffusion**: 10-20x slower generation

---

## 🎨 Prompt Engineering for Stable Diffusion

**Anatomy of a Good Prompt**:
```
[Subject] [Action] [Style/Quality] [Details]

Example:
"a red dragon flying over castle, digital art, highly detailed, dramatic lighting"
```

**Quality Boosters**:
- Add: `4k`, `8k`, `highly detailed`, `photorealistic`
- Add: `professional photography`, `award winning`
- Add: `trending on artstation`, `octane render`

**Style Keywords**:
- Photorealistic: `photograph`, `DSLR`, `bokeh`, `natural lighting`
- Digital Art: `digital painting`, `concept art`, `illustration`
- 3D: `3d render`, `octane render`, `cinema 4d`, `blender`
- Artistic: `oil painting`, `watercolor`, `impressionism`

**Common Negative Prompts**:
```
blurry, low quality, distorted, deformed, ugly, duplicate, mutated,
extra limbs, bad anatomy, poorly drawn, watermark, text, signature
```

---

## 📊 Comparison Matrix

| Method | Quality | Speed | Training | Ease of Use | Flexibility |
|--------|---------|-------|----------|-------------|-------------|
| **GAN** | ⭐⭐⭐⭐ | ⭐⭐ | Required (hours) | ⭐⭐⭐ | ⭐⭐⭐ |
| **Stable Diffusion** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Not needed | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **VAE** | ⭐⭐⭐ | ⭐⭐⭐ | Required (hours) | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🔧 Troubleshooting

### GAN Issues

**Problem**: Generated images are noisy/unrealistic
**Solution**: Train for more epochs, increase dataset size

**Problem**: Out of memory error
**Solution**: Reduce `miniBatchSize` or `imageSize`

**Problem**: Training is very slow
**Solution**: Use GPU, reduce image size, or use fewer epochs

---

### Stable Diffusion Issues

**Problem**: `No module named 'diffusers'`
**Solution**:
```bash
pip install diffusers transformers torch
```

**Problem**: Out of VRAM
**Solution**: Reduce image size or use `--fp16` for half precision

**Problem**: Slow generation on CPU
**Solution**: Install CUDA-enabled PyTorch or use smaller steps

**Problem**: Python not found in MATLAB
**Solution**:
```matlab
pyenv('Version', 'full/path/to/python.exe')
```

---

### VAE Issues

**Problem**: Images are blurry
**Solution**: Increase `latentDim`, train longer, or use GAN instead

**Problem**: Images don't look like training data
**Solution**: Increase `numEpochs` or dataset size

---

## 📚 Additional Resources

### Learning Materials
- **GANs**: [Deep Learning Specialization](https://www.coursera.org/learn/generative-adversarial-networks-gans)
- **Stable Diffusion**: [HuggingFace Documentation](https://huggingface.co/docs/diffusers)
- **VAE**: [Tutorial on VAEs](https://arxiv.org/abs/1606.05908)

### Model Repositories
- **Stable Diffusion Models**: [HuggingFace Hub](https://huggingface.co/models?pipeline_tag=text-to-image)
- **Pretrained GANs**: [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/)

---

## 🎓 When to Use Each Method?

### Use **GAN** when:
- You have a specific dataset you want to expand
- You need images similar to your training data
- You want full control in MATLAB
- You have 50+ training images

### Use **Stable Diffusion** when:
- You want the BEST quality results
- You need diverse, creative images
- You can describe what you want in text
- You don't have training data
- **This is the BEST option for most users!**

### Use **VAE** when:
- You want smooth interpolations
- You have a smaller dataset (30+ images)
- Training stability is important
- You want to explore latent space

---

## 🚦 Quick Decision Guide

```
START HERE
    ↓
Do you have training images?
    ├─ NO  → Use Stable Diffusion (text-to-image)
    ↓
   YES
    ↓
Do you want photorealistic quality?
    ├─ YES → Use Stable Diffusion (image-to-image)
    ↓
   NO (or want MATLAB-only solution)
    ↓
Is training time a concern?
    ├─ YES → Use VAE (faster, more stable)
    ├─ NO  → Use GAN (better quality)
```

---

## 📝 License & Citation

This toolkit is provided for educational and research purposes.

If you use Stable Diffusion, please cite:
```
@InProceedings{Rombach_2022_CVPR,
    author    = {Rombach, Robin and Blattmann, Andreas and Lorenz, Dominik and Esser, Patrick and Ommer, Bj\"orn},
    title     = {High-Resolution Image Synthesis With Latent Diffusion Models},
    booktitle = {Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR)},
    year      = {2022}
}
```

---

## 🤝 Support

For issues:
1. Check the Troubleshooting section above
2. Verify all requirements are installed
3. Check MATLAB/Python versions
4. Review console error messages

**Happy AI Image Generation! 🎨🤖**
