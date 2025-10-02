import tensorflow as tf
import keras
from keras import layers
from sklearn import metrics
IMG_SIZE = (48, 48)
BATCH_SIZE=32
class TFLiteModel:
    def __init__(self, model_path: str):
        self.interpreter = tf.lite.Interpreter(model_path)
        self.interpreter.resize_tensor_input(0, [BATCH_SIZE , 48, 48, 1])
        self.interpreter.allocate_tensors()

        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def predict(self, *data_args):
        assert len(data_args) == len(self.input_details)
        for data, details in zip(data_args, self.input_details):
            self.interpreter.set_tensor(details["index"], data)
        self.interpreter.invoke()
        return self.interpreter.get_tensor(self.output_details[0]["index"])



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

model = TFLiteModel("../model.tflite")

predictions = model.predict(test_img)
print(predictions)
predicted_classes = tf.argmax(predictions, axis=1)
labels = tf.argmax(test_labels, axis=1)


print ("Accuracy = ", metrics.accuracy_score(labels, predicted_classes))