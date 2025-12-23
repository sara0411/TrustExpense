"""
Dataset Preparation Script for Receipt Detection
Organizes SROIE2019 receipts and downloads non-receipt images
"""

import os
import shutil
import random
from pathlib import Path
import requests
from PIL import Image
from io import BytesIO

# Paths
SROIE_TRAIN = '../training_data/receipts/SROIE2019/train/img'
SROIE_TEST = '../training_data/receipts/SROIE2019/test/img'
DATASET_DIR = '../dataset'

# Configuration
TRAIN_SPLIT = 0.8
RANDOM_SEED = 42

def create_directory_structure():
    """Create dataset directory structure"""
    print("📁 Creating directory structure...")
    
    dirs = [
        f'{DATASET_DIR}/train/receipt',
        f'{DATASET_DIR}/train/not_receipt',
        f'{DATASET_DIR}/val/receipt',
        f'{DATASET_DIR}/val/not_receipt'
    ]
    
    for dir_path in dirs:
        os.makedirs(dir_path, exist_ok=True)
    
    print("✅ Directory structure created")

def organize_receipt_images():
    """
    Organize SROIE receipt images into train/val splits
    """
    print("\n📸 Organizing receipt images...")
    
    # Get all receipt images
    train_images = list(Path(SROIE_TRAIN).glob('*.jpg'))
    test_images = list(Path(SROIE_TEST).glob('*.jpg'))
    all_receipts = train_images + test_images
    
    print(f"   - Found {len(all_receipts)} receipt images")
    
    # Shuffle
    random.seed(RANDOM_SEED)
    random.shuffle(all_receipts)
    
    # Split
    split_idx = int(len(all_receipts) * TRAIN_SPLIT)
    train_receipts = all_receipts[:split_idx]
    val_receipts = all_receipts[split_idx:]
    
    # Copy to dataset folders
    for img_path in train_receipts:
        shutil.copy(img_path, f'{DATASET_DIR}/train/receipt/{img_path.name}')
    
    for img_path in val_receipts:
        shutil.copy(img_path, f'{DATASET_DIR}/val/receipt/{img_path.name}')
    
    print(f"✅ Receipt images organized:")
    print(f"   - Train: {len(train_receipts)}")
    print(f"   - Val: {len(val_receipts)}")
    
    return len(train_receipts), len(val_receipts)

def download_non_receipt_images(num_train, num_val):
    """
    Download random non-receipt images from Unsplash
    """
    print("\n🌐 Downloading non-receipt images...")
    print("   (This may take a few minutes...)")
    
    # Unsplash random image API
    categories = ['nature', 'people', 'animals', 'architecture', 'food', 'technology']
    
    def download_image(save_path, category):
        try:
            url = f'https://source.unsplash.com/224x224/?{category}'
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                img = Image.open(BytesIO(response.content))
                img = img.convert('RGB')
                img.save(save_path)
                return True
        except:
            pass
        return False
    
    # Download training images
    print(f"   - Downloading {num_train} training images...")
    for i in range(num_train):
        category = random.choice(categories)
        save_path = f'{DATASET_DIR}/train/not_receipt/img_{i:04d}.jpg'
        if download_image(save_path, category):
            if (i + 1) % 50 == 0:
                print(f"     Downloaded {i + 1}/{num_train}")
    
    # Download validation images
    print(f"   - Downloading {num_val} validation images...")
    for i in range(num_val):
        category = random.choice(categories)
        save_path = f'{DATASET_DIR}/val/not_receipt/img_{i:04d}.jpg'
        download_image(save_path, category)
    
    print("✅ Non-receipt images downloaded")

def verify_dataset():
    """Verify dataset is ready"""
    print("\n🔍 Verifying dataset...")
    
    counts = {
        'train/receipt': len(list(Path(f'{DATASET_DIR}/train/receipt').glob('*.jpg'))),
        'train/not_receipt': len(list(Path(f'{DATASET_DIR}/train/not_receipt').glob('*.jpg'))),
        'val/receipt': len(list(Path(f'{DATASET_DIR}/val/receipt').glob('*.jpg'))),
        'val/not_receipt': len(list(Path(f'{DATASET_DIR}/val/not_receipt').glob('*.jpg')))
    }
    
    for key, count in counts.items():
        print(f"   - {key}: {count} images")
    
    total = sum(counts.values())
    print(f"\n✅ Dataset ready with {total} total images")
    
    return counts

def main():
    print("=" * 60)
    print("Receipt Detection Dataset Preparation")
    print("=" * 60)
    
    # Create structure
    create_directory_structure()
    
    # Organize receipts
    num_train, num_val = organize_receipt_images()
    
    # Download non-receipts
    download_non_receipt_images(num_train, num_val)
    
    # Verify
    verify_dataset()
    
    print("\n✅ Dataset preparation complete!")
    print(f"   Dataset location: {DATASET_DIR}")
    print("\n📝 Next step: Run train_receipt_detector.py")

if __name__ == '__main__':
    main()
