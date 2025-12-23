"""
Alternative dataset downloader using Pexels API (free, no rate limit issues)
"""

import os
import requests
import time
from pathlib import Path

# Pexels API (free, get key from: https://www.pexels.com/api/)
PEXELS_API_KEY = "YOUR_API_KEY_HERE"  # Get free key from pexels.com/api

# Or use this public dataset approach
def download_from_public_datasets():
    """
    Download non-receipt images from public datasets
    """
    print("📥 Downloading from public datasets...")
    
    # Option 1: Download from a curated list
    image_urls = [
        # Add direct image URLs here
        # Example: "https://example.com/image1.jpg"
    ]
    
    # Option 2: Use Kaggle dataset (recommended)
    print("\n💡 RECOMMENDED APPROACH:")
    print("=" * 60)
    print("1. Go to: https://www.kaggle.com/datasets/ifigotin/imagenetmini-1000")
    print("2. Click 'Download' (requires free Kaggle account)")
    print("3. Extract the zip file")
    print("4. Copy ~800 random images to:")
    print(f"   {os.path.abspath('../dataset/train/not_receipt/')}")
    print("5. Copy ~200 random images to:")
    print(f"   {os.path.abspath('../dataset/val/not_receipt/')}")
    print("=" * 60)

def download_with_pexels(api_key, num_images=800):
    """
    Download images using Pexels API
    """
    if api_key == "YOUR_API_KEY_HERE":
        print("❌ Please add your Pexels API key")
        print("   Get one free at: https://www.pexels.com/api/")
        return
    
    headers = {"Authorization": api_key}
    queries = ['nature', 'people', 'animals', 'architecture', 'technology', 'food', 'city', 'abstract']
    
    os.makedirs('../dataset/train/not_receipt', exist_ok=True)
    os.makedirs('../dataset/val/not_receipt', exist_ok=True)
    
    downloaded = 0
    for query in queries:
        if downloaded >= num_images:
            break
            
        page = 1
        while downloaded < num_images:
            url = f"https://api.pexels.com/v1/search?query={query}&per_page=80&page={page}"
            response = requests.get(url, headers=headers)
            
            if response.status_code != 200:
                break
                
            data = response.json()
            photos = data.get('photos', [])
            
            if not photos:
                break
                
            for photo in photos:
                if downloaded >= num_images:
                    break
                    
                img_url = photo['src']['medium']
                try:
                    img_data = requests.get(img_url, timeout=10).content
                    
                    # 80% train, 20% val
                    folder = 'train' if downloaded < num_images * 0.8 else 'val'
                    filename = f'../dataset/{folder}/not_receipt/img_{downloaded:04d}.jpg'
                    
                    with open(filename, 'wb') as f:
                        f.write(img_data)
                    
                    downloaded += 1
                    if downloaded % 50 == 0:
                        print(f"   Downloaded {downloaded}/{num_images}")
                        
                except Exception as e:
                    print(f"   Error downloading image: {e}")
                    
            page += 1
            time.sleep(1)  # Rate limiting
    
    print(f"✅ Downloaded {downloaded} images")

if __name__ == '__main__':
    print("=" * 60)
    print("Non-Receipt Image Downloader")
    print("=" * 60)
    
    # Show manual download instructions
    download_from_public_datasets()
    
    # Or use Pexels API if you have a key
    # download_with_pexels(PEXELS_API_KEY, num_images=800)
