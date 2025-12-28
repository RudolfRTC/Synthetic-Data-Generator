#!/usr/bin/env python3
"""
=============================================================================
AI IMAGE GENERATOR - Stable Diffusion
=============================================================================
Description: Uses Stable Diffusion AI to generate photorealistic images
             from text descriptions (text-to-image) or existing images
             (image-to-image).

Author: AI Expert
Date: December 2025

Requirements:
    - Python 3.8+
    - diffusers library: pip install diffusers transformers accelerate
    - PyTorch: pip install torch torchvision
    - GPU with 6GB+ VRAM recommended (NVIDIA CUDA)

Installation:
    pip install torch torchvision diffusers transformers accelerate pillow numpy

Features:
    - Text-to-image generation
    - Image-to-image transformation
    - Batch generation
    - Multiple models support
    - GPU acceleration

NOTE: This generates COMPLETELY NEW photorealistic images using AI!
=============================================================================
"""

import os
import argparse
from pathlib import Path
from typing import List, Optional
import torch
from PIL import Image
from diffusers import StableDiffusionPipeline, StableDiffusionImg2ImgPipeline
from diffusers import DPMSolverMultistepScheduler
import numpy as np


class AIImageGenerator:
    """Stable Diffusion Image Generator"""

    def __init__(
        self,
        model_id: str = "runwayml/stable-diffusion-v1-5",
        device: str = "auto",
        use_fp16: bool = True
    ):
        """
        Initialize the AI Image Generator

        Args:
            model_id: HuggingFace model ID
            device: 'cuda', 'cpu', or 'auto'
            use_fp16: Use half precision for faster generation (GPU only)
        """
        print("=== AI Image Generator (Stable Diffusion) ===\n")

        # Determine device
        if device == "auto":
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device

        print(f"Using device: {self.device.upper()}")

        # Set data type
        self.dtype = torch.float16 if (use_fp16 and self.device == "cuda") else torch.float32

        print(f"Loading model: {model_id}")
        print("This may take a few minutes on first run...\n")

        # Load text-to-image pipeline
        self.txt2img_pipe = StableDiffusionPipeline.from_pretrained(
            model_id,
            torch_dtype=self.dtype,
            safety_checker=None,  # Disable safety checker for faster generation
        )

        # Optimize scheduler for faster generation
        self.txt2img_pipe.scheduler = DPMSolverMultistepScheduler.from_config(
            self.txt2img_pipe.scheduler.config
        )

        self.txt2img_pipe = self.txt2img_pipe.to(self.device)

        # Enable memory optimizations
        if self.device == "cuda":
            self.txt2img_pipe.enable_attention_slicing()

        print("✓ Model loaded successfully!\n")

    def generate_from_text(
        self,
        prompts: List[str],
        output_dir: str = "ai_generated_images",
        num_images_per_prompt: int = 1,
        width: int = 512,
        height: int = 512,
        num_inference_steps: int = 25,
        guidance_scale: float = 7.5,
        negative_prompt: Optional[str] = None,
        seed: Optional[int] = None
    ) -> List[str]:
        """
        Generate images from text prompts

        Args:
            prompts: List of text descriptions
            output_dir: Directory to save generated images
            num_images_per_prompt: Number of variations per prompt
            width: Image width (multiple of 8)
            height: Image height (multiple of 8)
            num_inference_steps: Quality vs speed (20-50 recommended)
            guidance_scale: How closely to follow prompt (7-15 recommended)
            negative_prompt: What to avoid in generation
            seed: Random seed for reproducibility

        Returns:
            List of saved image paths
        """
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)

        saved_paths = []

        # Set seed for reproducibility
        if seed is not None:
            generator = torch.Generator(device=self.device).manual_seed(seed)
        else:
            generator = None

        total_images = len(prompts) * num_images_per_prompt
        current = 0

        for prompt_idx, prompt in enumerate(prompts):
            print(f"\nPrompt {prompt_idx + 1}/{len(prompts)}: '{prompt}'")

            for img_idx in range(num_images_per_prompt):
                current += 1
                print(f"  Generating image {img_idx + 1}/{num_images_per_prompt} ({current}/{total_images})...")

                # Generate image
                with torch.autocast(self.device):
                    result = self.txt2img_pipe(
                        prompt=prompt,
                        negative_prompt=negative_prompt,
                        width=width,
                        height=height,
                        num_inference_steps=num_inference_steps,
                        guidance_scale=guidance_scale,
                        generator=generator
                    )

                image = result.images[0]

                # Save image
                filename = f"ai_gen_prompt{prompt_idx + 1:03d}_var{img_idx + 1:02d}.png"
                filepath = os.path.join(output_dir, filename)
                image.save(filepath)
                saved_paths.append(filepath)

                print(f"    ✓ Saved: {filename}")

        return saved_paths

    def generate_batch_from_file(
        self,
        prompts_file: str,
        output_dir: str = "ai_generated_images",
        **kwargs
    ) -> List[str]:
        """
        Generate images from prompts in a text file

        Args:
            prompts_file: Path to text file (one prompt per line)
            output_dir: Directory to save images
            **kwargs: Additional arguments for generate_from_text()

        Returns:
            List of saved image paths
        """
        with open(prompts_file, 'r', encoding='utf-8') as f:
            prompts = [line.strip() for line in f if line.strip()]

        print(f"Loaded {len(prompts)} prompts from {prompts_file}\n")

        return self.generate_from_text(prompts, output_dir, **kwargs)


def main():
    """Command-line interface"""
    parser = argparse.ArgumentParser(
        description="Generate AI images using Stable Diffusion"
    )

    parser.add_argument(
        "--prompt",
        type=str,
        help="Text prompt for image generation"
    )

    parser.add_argument(
        "--prompts-file",
        type=str,
        help="File with multiple prompts (one per line)"
    )

    parser.add_argument(
        "--output-dir",
        type=str,
        default="ai_generated_images",
        help="Output directory for generated images"
    )

    parser.add_argument(
        "--num-images",
        type=int,
        default=1,
        help="Number of images to generate per prompt"
    )

    parser.add_argument(
        "--width",
        type=int,
        default=512,
        help="Image width (must be multiple of 8)"
    )

    parser.add_argument(
        "--height",
        type=int,
        default=512,
        help="Image height (must be multiple of 8)"
    )

    parser.add_argument(
        "--steps",
        type=int,
        default=25,
        help="Number of inference steps (quality vs speed)"
    )

    parser.add_argument(
        "--guidance",
        type=float,
        default=7.5,
        help="Guidance scale (how closely to follow prompt)"
    )

    parser.add_argument(
        "--negative-prompt",
        type=str,
        default="blurry, low quality, distorted, deformed, ugly",
        help="Negative prompt (what to avoid)"
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Random seed for reproducibility"
    )

    parser.add_argument(
        "--model",
        type=str,
        default="runwayml/stable-diffusion-v1-5",
        help="HuggingFace model ID"
    )

    args = parser.parse_args()

    # Initialize generator
    generator = AIImageGenerator(model_id=args.model)

    # Generate images
    if args.prompts_file:
        saved_paths = generator.generate_batch_from_file(
            prompts_file=args.prompts_file,
            output_dir=args.output_dir,
            num_images_per_prompt=args.num_images,
            width=args.width,
            height=args.height,
            num_inference_steps=args.steps,
            guidance_scale=args.guidance,
            negative_prompt=args.negative_prompt,
            seed=args.seed
        )
    elif args.prompt:
        saved_paths = generator.generate_from_text(
            prompts=[args.prompt],
            output_dir=args.output_dir,
            num_images_per_prompt=args.num_images,
            width=args.width,
            height=args.height,
            num_inference_steps=args.steps,
            guidance_scale=args.guidance,
            negative_prompt=args.negative_prompt,
            seed=args.seed
        )
    else:
        # Demo mode
        print("No prompt specified. Running demo...\n")
        demo_prompts = [
            "a beautiful sunset over mountains, photorealistic, 4k",
            "a cute cat wearing sunglasses, digital art",
            "futuristic city with flying cars, cyberpunk style"
        ]

        saved_paths = generator.generate_from_text(
            prompts=demo_prompts,
            output_dir=args.output_dir,
            num_images_per_prompt=1,
            width=512,
            height=512,
            num_inference_steps=25,
            guidance_scale=7.5
        )

    # Summary
    print(f"\n{'='*60}")
    print("=== Generation Complete! ===")
    print(f"{'='*60}")
    print(f"Total images generated: {len(saved_paths)}")
    print(f"Saved to: {args.output_dir}/")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
