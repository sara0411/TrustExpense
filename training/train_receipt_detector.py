"""
Receipt Detection CNN - Training Script
Uses MobileNetV2 with transfer learning to detect receipt images

Author: TrustExpense Team
Dataset: SROIE2019 + Random non-receipt images
"""

import os
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
import matplotlib.pyplot as plt

# Configuration
IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS_INITIAL = 20
EPOCHS_FINETUNE = 10
LEARNING_RATE_INITIAL = 0.001
LEARNING_RATE_FINETUNE = 0.0001

# Paths
DATASET_DIR = '../dataset'
TRAIN_DIR = os.path.join(DATASET_DIR, 'train')
VAL_DIR = os.path.join(DATASET_DIR, 'val')
MODEL_SAVE_PATH = '../models/receipt_detector.h5'
TFLITE_SAVE_PATH = '../assets/tflite/receipt_detector.tflite'

def create_model():
    """
    Create MobileNetV2-based receipt detector
    
    Architecture:
    - MobileNetV2 (pre-trained on ImageNet) - Feature extraction
    - GlobalAveragePooling2D - Reduce spatial dimensions
    - Dense(128, ReLU) - Classification layer
    - Dropout(0.5) - Regularization
    - Dense(1, Sigmoid) - Binary output (receipt/not-receipt)
    """
    print("🏗️ Building model architecture...")
    
    # Load pre-trained MobileNetV2 (without top classification layer)
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=(IMG_SIZE, IMG_SIZE, 3)
    )
    
    # Freeze base model for initial training (transfer learning)
    base_model.trainable = False
    
    # Add custom classification head
    x = base_model.output
    x = GlobalAveragePooling2D(name='global_avg_pool')(x)
    x = Dense(128, activation='relu', name='dense_128')(x)
    x = Dropout(0.5, name='dropout')(x)
    output = Dense(1, activation='sigmoid', name='output')(x)
    
    model = Model(inputs=base_model.input, outputs=output, name='receipt_detector')
    
    print(f"✅ Model created with {model.count_params():,} parameters")
    print(f"   - Trainable: {sum([tf.keras.backend.count_params(w) for w in model.trainable_weights]):,}")
    print(f"   - Non-trainable: {sum([tf.keras.backend.count_params(w) for w in model.non_trainable_weights]):,}")
    
    return model, base_model

def create_data_generators():
    """
    Create data generators with augmentation
    
    Augmentation techniques:
    - Rotation: ±10 degrees (receipts can be slightly tilted)
    - Width/Height shift: 10% (account for cropping variations)
    - Zoom: 10% (different camera distances)
    - NO horizontal flip (receipts have orientation)
    """
    print("📊 Creating data generators...")
    
    # Training data augmentation
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=10,
        width_shift_range=0.1,
        height_shift_range=0.1,
        zoom_range=0.1,
        brightness_range=[0.8, 1.2],
        horizontal_flip=False,  # Don't flip receipts
        fill_mode='nearest'
    )
    
    # Validation data (no augmentation, only rescaling)
    val_datagen = ImageDataGenerator(rescale=1./255)
    
    # Load data from directories
    train_generator = train_datagen.flow_from_directory(
        TRAIN_DIR,
        target_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        class_mode='binary',
        shuffle=True
    )
    
    val_generator = val_datagen.flow_from_directory(
        VAL_DIR,
        target_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        class_mode='binary',
        shuffle=False
    )
    
    print(f"✅ Data generators created")
    print(f"   - Training samples: {train_generator.samples}")
    print(f"   - Validation samples: {val_generator.samples}")
    print(f"   - Classes: {train_generator.class_indices}")
    
    return train_generator, val_generator

def train_initial(model, train_gen, val_gen):
    """
    Initial training with frozen base model
    """
    print("\n🎯 Phase 1: Initial Training (frozen base)")
    
    # Compile model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE_INITIAL),
        loss='binary_crossentropy',
        metrics=['accuracy', tf.keras.metrics.Precision(), tf.keras.metrics.Recall()]
    )
    
    # Callbacks
    callbacks = [
        EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True,
            verbose=1
        ),
        ModelCheckpoint(
            MODEL_SAVE_PATH,
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=3,
            min_lr=1e-7,
            verbose=1
        )
    ]
    
    # Train
    history = model.fit(
        train_gen,
        epochs=EPOCHS_INITIAL,
        validation_data=val_gen,
        callbacks=callbacks,
        verbose=1
    )
    
    return history

def fine_tune(model, base_model, train_gen, val_gen):
    """
    Fine-tuning: Unfreeze top layers and train with lower learning rate
    """
    print("\n🎯 Phase 2: Fine-tuning (unfrozen top layers)")
    
    # Unfreeze base model
    base_model.trainable = True
    
    # Freeze all layers except the last 20
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
    print(f"   - Trainable parameters: {sum([tf.keras.backend.count_params(w) for w in model.trainable_weights]):,}")
    
    # Recompile with lower learning rate
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE_FINETUNE),
        loss='binary_crossentropy',
        metrics=['accuracy', tf.keras.metrics.Precision(), tf.keras.metrics.Recall()]
    )
    
    # Fine-tune
    history_fine = model.fit(
        train_gen,
        epochs=EPOCHS_FINETUNE,
        validation_data=val_gen,
        callbacks=[
            EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True),
            ModelCheckpoint(MODEL_SAVE_PATH, monitor='val_accuracy', save_best_only=True)
        ],
        verbose=1
    )
    
    return history_fine

def convert_to_tflite(model):
    """
    Convert Keras model to TensorFlow Lite for mobile deployment
    """
    print("\n📱 Converting to TensorFlow Lite...")
    
    # Convert
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]  # Optimize for size and speed
    tflite_model = converter.convert()
    
    # Save
    os.makedirs(os.path.dirname(TFLITE_SAVE_PATH), exist_ok=True)
    with open(TFLITE_SAVE_PATH, 'wb') as f:
        f.write(tflite_model)
    
    # Get size
    size_mb = len(tflite_model) / (1024 * 1024)
    print(f"✅ TFLite model saved: {TFLITE_SAVE_PATH}")
    print(f"   - Size: {size_mb:.2f} MB")
    
    return tflite_model

def plot_training_history(history, history_fine=None):
    """
    Plot training metrics
    """
    plt.figure(figsize=(12, 4))
    
    # Accuracy
    plt.subplot(1, 2, 1)
    plt.plot(history.history['accuracy'], label='Train Accuracy')
    plt.plot(history.history['val_accuracy'], label='Val Accuracy')
    if history_fine:
        offset = len(history.history['accuracy'])
        plt.plot(range(offset, offset + len(history_fine.history['accuracy'])), 
                 history_fine.history['accuracy'], label='Fine-tune Train')
        plt.plot(range(offset, offset + len(history_fine.history['val_accuracy'])), 
                 history_fine.history['val_accuracy'], label='Fine-tune Val')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.title('Model Accuracy')
    plt.grid(True)
    
    # Loss
    plt.subplot(1, 2, 2)
    plt.plot(history.history['loss'], label='Train Loss')
    plt.plot(history.history['val_loss'], label='Val Loss')
    if history_fine:
        offset = len(history.history['loss'])
        plt.plot(range(offset, offset + len(history_fine.history['loss'])), 
                 history_fine.history['loss'], label='Fine-tune Train')
        plt.plot(range(offset, offset + len(history_fine.history['val_loss'])), 
                 history_fine.history['val_loss'], label='Fine-tune Val')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    plt.title('Model Loss')
    plt.grid(True)
    
    plt.tight_layout()
    plt.savefig('../models/training_history.png')
    print("📊 Training history saved to: ../models/training_history.png")

def main():
    """
    Main training pipeline
    """
    print("=" * 60)
    print("Receipt Detection CNN - Training Pipeline")
    print("=" * 60)
    
    # Create model
    model, base_model = create_model()
    
    # Create data generators
    train_gen, val_gen = create_data_generators()
    
    # Phase 1: Initial training
    history = train_initial(model, train_gen, val_gen)
    
    # Phase 2: Fine-tuning
    history_fine = fine_tune(model, base_model, train_gen, val_gen)
    
    # Evaluate
    print("\n📊 Final Evaluation:")
    results = model.evaluate(val_gen, verbose=0)
    print(f"   - Loss: {results[0]:.4f}")
    print(f"   - Accuracy: {results[1]:.4f}")
    print(f"   - Precision: {results[2]:.4f}")
    print(f"   - Recall: {results[3]:.4f}")
    
    # Convert to TFLite
    convert_to_tflite(model)
    
    # Plot history
    plot_training_history(history, history_fine)
    
    print("\n✅ Training complete!")
    print(f"   - Model saved: {MODEL_SAVE_PATH}")
    print(f"   - TFLite model: {TFLITE_SAVE_PATH}")

if __name__ == '__main__':
    main()
