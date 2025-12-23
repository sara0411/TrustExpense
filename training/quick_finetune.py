"""
Quick fine-tuning and TFLite conversion script
Uses the best model from Phase 1 and does quick fine-tuning
"""

import os
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# Configuration
IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS_FINETUNE = 5  # Reduced for speed
LEARNING_RATE = 0.0001

# Paths
MODEL_PATH = '../models/receipt_detector.h5'
TFLITE_PATH = '../assets/tflite/receipt_detector.tflite'
TRAIN_DIR = '../dataset/train'
VAL_DIR = '../dataset/val'

print("=" * 60)
print("Quick Fine-tuning and TFLite Conversion")
print("=" * 60)

# Check if model exists
if not os.path.exists(MODEL_PATH):
    print("❌ No saved model found. Using MobileNetV2 directly...")
    from tensorflow.keras.applications import MobileNetV2
    from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout
    from tensorflow.keras.models import Model
    
    base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(IMG_SIZE, IMG_SIZE, 3))
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(128, activation='relu')(x)
    x = Dropout(0.5)(x)
    output = Dense(1, activation='sigmoid')(x)
    model = Model(inputs=base_model.input, outputs=output)
else:
    print("✅ Loading saved model...")
    model = load_model(MODEL_PATH)

# Prepare data
print("\n📊 Loading data...")
train_datagen = ImageDataGenerator(rescale=1./255)
val_datagen = ImageDataGenerator(rescale=1./255)

train_gen = train_datagen.flow_from_directory(
    TRAIN_DIR, target_size=(IMG_SIZE, IMG_SIZE), batch_size=BATCH_SIZE, class_mode='binary'
)
val_gen = val_datagen.flow_from_directory(
    VAL_DIR, target_size=(IMG_SIZE, IMG_SIZE), batch_size=BATCH_SIZE, class_mode='binary'
)

# Evaluate current performance
print("\n📊 Evaluating current model...")
results = model.evaluate(val_gen, verbose=0)
print(f"   - Validation Loss: {results[0]:.4f}")
print(f"   - Validation Accuracy: {results[1]:.4f}")

if results[1] >= 0.95:
    print("\n✅ Model already performing excellently (>95% accuracy)!")
    print("   Skipping fine-tuning, proceeding to TFLite conversion...")
else:
    print(f"\n🎯 Fine-tuning for {EPOCHS_FINETUNE} epochs...")
    
    # Unfreeze and compile
    for layer in model.layers:
        layer.trainable = True
    
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    
    # Quick fine-tune
    model.fit(train_gen, epochs=EPOCHS_FINETUNE, validation_data=val_gen, verbose=1)
    
    # Save
    model.save(MODEL_PATH)
    print(f"✅ Model saved to {MODEL_PATH}")

# Convert to TFLite
print("\n📱 Converting to TensorFlow Lite...")
os.makedirs(os.path.dirname(TFLITE_PATH), exist_ok=True)

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open(TFLITE_PATH, 'wb') as f:
    f.write(tflite_model)

size_mb = len(tflite_model) / (1024 * 1024)
print(f"✅ TFLite model saved: {TFLITE_PATH}")
print(f"   - Size: {size_mb:.2f} MB")

print("\n✅ Training complete!")
print(f"   - Model: {MODEL_PATH}")
print(f"   - TFLite: {TFLITE_PATH}")
print("\n📝 Next: Integrate into Flutter app and test!")
