import tensorflow as tf

# Carrega o modelo salvo em .keras
model = tf.keras.models.load_model("best_model.keras")

# Cria o conversor
converter = tf.lite.TFLiteConverter.from_keras_model(model)


tflite_model = converter.convert()

# Salva o modelo
with open("model.tflite", "wb") as f:
    f.write(tflite_model)