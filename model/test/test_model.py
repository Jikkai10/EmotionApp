import tensorflow as tf
import keras
from keras import layers
from sklearn import metrics

IMG_SIZE = (48, 48)
BATCH_SIZE=32

validation_data_dir='../data/test/'


val_ds = keras.utils.image_dataset_from_directory(
    validation_data_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    color_mode="grayscale",
    label_mode="categorical"
)

normalization_layer = layers.Rescaling(1./255)
AUTOTUNE = tf.data.AUTOTUNE

val_ds = val_ds.map(lambda x, y: (normalization_layer(x), y)).prefetch(AUTOTUNE)

test_img, test_labels = next(iter(val_ds))

model = keras.models.load_model("../best_model.keras", compile=False)

predictions = model.predict(test_img)
predicted_classes = tf.argmax(predictions, axis=1)
labels = tf.argmax(test_labels, axis=1)


print ("Accuracy = ", metrics.accuracy_score(labels, predicted_classes))