from keras.models import Sequential
from keras.layers import Dense,Dropout,Flatten, Input
from keras.layers import Conv2D,MaxPooling2D,BatchNormalization,Activation
from keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
import tensorflow as tf
import keras
from keras import layers

IMG_SIZE = (48, 48)
BATCH_SIZE=32


# data: https://www.kaggle.com/datasets/msambare/fer2013
train_data_dir='data/train/'
validation_data_dir='data/test/'

train_ds = keras.utils.image_dataset_from_directory(
    train_data_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    color_mode="grayscale",
    label_mode="categorical"  
)

val_ds = keras.utils.image_dataset_from_directory(
    validation_data_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    color_mode="grayscale",
    label_mode="categorical"
)

normalization_layer = layers.Rescaling(1./255)
AUTOTUNE = tf.data.AUTOTUNE

train_ds = train_ds.map(lambda x, y: (normalization_layer(x), y)).prefetch(AUTOTUNE)
val_ds = val_ds.map(lambda x, y: (normalization_layer(x), y)).prefetch(AUTOTUNE)

data_augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
    layers.RandomContrast(0.1),
])

model = Sequential()

model.add(Input(shape=(48, 48, 1)))
model.add(data_augmentation)
model.add(Conv2D(64,(3,3),padding = 'same'))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size = (2,2)))
model.add(Dropout(0.2))

model.add(Conv2D(128,(5,5),padding = 'same'))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size = (2,2)))
model.add(Dropout (0.2))

model.add(Conv2D(512,(3,3),padding = 'same'))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size = (2,2)))
model.add(Dropout (0.2))

model.add(Conv2D(512,(3,3), padding='same'))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.2))

model.add(Flatten())

model.add(Dense(256))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(Dropout(0.2))

model.add(Dense(512))
model.add(BatchNormalization())
model.add(Activation('relu'))
model.add(Dropout(0.2))

model.add(Dense(7, activation='softmax'))

model.compile(optimizer = "adam", loss='categorical_crossentropy', metrics=['accuracy'])

early_stopping = EarlyStopping(monitor='val_loss',
                          patience=5,
                          restore_best_weights=True
                          )

checkpoint = ModelCheckpoint(
                    filepath="best_model.keras",  
                    monitor="val_accuracy",
                    save_best_only=True,  
                    verbose=1
                )

reduce_learningrate = ReduceLROnPlateau(
                            monitor="val_loss",
                            factor=0.5,   
                            patience=3,   
                            min_lr=1e-6
                        )

callbacks_list = [early_stopping, checkpoint, reduce_learningrate]

epochs=50
    
history=model.fit(train_ds,
                epochs=epochs,
                validation_data=val_ds,
                callbacks=callbacks_list)
