"""
Organize extracted non-receipt images into dataset structure
"""

import os
import shutil
import random
from pathlib import Path

# Paths
EXTRACTED_DIR = r'C:\Users\FerraaSara\Downloads\extracted_images\images'
TRAIN_DIR = r'../dataset/train/not_receipt'
VAL_DIR = r'../dataset/val/not_receipt'

# Create directories
os.makedirs(TRAIN_DIR, exist_ok=True)
os.makedirs(VAL_DIR, exist_ok=True)

# Get all images
all_images = list(Path(EXTRACTED_DIR).glob('**/*.jpg')) + \
             list(Path(EXTRACTED_DIR).glob('**/*.jpeg')) + \
             list(Path(EXTRACTED_DIR).glob('**/*.png'))

print(f"Found {len(all_images)} images")

# Shuffle
random.seed(42)
random.shuffle(all_images)

# Split 80/20
split_idx = int(len(all_images) * 0.8)
train_images = all_images[:split_idx]
val_images = all_images[split_idx:]

# Copy to dataset
print(f"Copying {len(train_images)} images to train...")
for i, img_path in enumerate(train_images):
    if i >= 778:  # Match number of receipt images
        break
    dest = os.path.join(TRAIN_DIR, f'img_{i:04d}{img_path.suffix}')
    shutil.copy(img_path, dest)
    if (i + 1) % 100 == 0:
        print(f"  Copied {i + 1}/{min(778, len(train_images))}")

print(f"Copying {len(val_images)} images to val...")
for i, img_path in enumerate(val_images):
    if i >= 195:  # Match number of receipt images
        break
    dest = os.path.join(VAL_DIR, f'img_{i:04d}{img_path.suffix}')
    shutil.copy(img_path, dest)

print("\n✅ Dataset organized!")
print(f"  Train not_receipt: {len(os.listdir(TRAIN_DIR))}")
print(f"  Val not_receipt: {len(os.listdir(VAL_DIR))}")
