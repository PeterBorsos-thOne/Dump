# The example function below keeps track of the opponent's history and plays whatever the opponent played two plays ago. It is not a very good player so you will need to change the code to pass the challenge.

import tensorflow as tf
import random

  # Build the model, a function for this would have been nice or at least a loop... Self critique ;) I'm not lazy, just energy efficient!
def build_model():
      # Model 1
  model_1 = tf.keras.Sequential([
      tf.keras.layers.Dense(1024, activation='relu'),
      tf.keras.layers.Dense(1024, activation='relu'),
      tf.keras.layers.Dense(496, activation='relu'),
      tf.keras.layers.Dense(248, activation='relu'),
      tf.keras.layers.Dense(3)])

      # Model 2
  model_2 = tf.keras.Sequential([
      tf.keras.layers.Dense(1024, activation='relu'),
      tf.keras.layers.Dense(1024, activation='relu'),
      tf.keras.layers.Dense(496, activation='relu'),
      tf.keras.layers.Dense(248, activation='relu'),
      tf.keras.layers.Dense(3)])

    # Compile the models, a function for this would have been nice or at least a loop...
  learning_rate_ = 0.0002

      # Model 1
  model_1.compile(
                optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate_),
                loss='mean_absolute_error',
                metrics=['accuracy'])

      # Model 2
  model_2.compile(
                optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate_),
                loss='mean_absolute_error',
                metrics=['accuracy'])



  # Convert between str and int
def num(input):
  category = ["R", "P", "S"]
  num = [0, 1, 2]
  if input in category:
    return int(num[category.index(input)])
  elif type(input) == int:
    if input >= 3:
      input = input % 3
    return category[int(input)]
  else:
    return print(f"Error invalid in: {input, type(input)}") # Why not


 # The shit
loops = 0
prev_guess = ''
def player(prev_play,
           opponent_history=[], 
           player_history=[],
           ):
  global prev_guess, loops, acc, sett, uccurency
  
    # Iniciate the game with:
  if prev_play == '' or prev_guess == '' or loops == 0:
    prev_play = 'R'
    prev_guess = 'R'
    build_model()


    # Update history
  opponent_history.append(num(prev_play))
  player_history.append(num(prev_guess))

    # ...yes, what can I say?
#__________________#
  prediction = 'R' #
#__________________#


  # Getting training data. Nope! Just random isn't enough.
  num_train_data = 200
  if loops < num_train_data:
    #prediction = random.randint(0,2)
    if loops < num_train_data*(2.5/10):
      prediction = random.randint(0,2)
    elif loops < num_train_data*(7/10):
      pattern = [0, 1, 2]
      prediction = pattern[loops % 3]
    else:
      pattern = [0, 2, 1, 0, 0 , 2, 1, 2, 1]
      prediction = pattern[loops % 9]


  # Trainig
  elif loops == num_train_data:
    print('Work, work!')

     # Collecting and processing data 
    ds_1 = []
    ds_2 = []
    ds_y = []
    sett = 3

    for n in range(len(opponent_history)-sett):
      ds_1.append(opponent_history[n:sett+n])
      ds_2.append(player_history[n:sett+n])
      ds_y.append(opponent_history[sett+n])

      # Shaping the features and labels
    ds_1 = tf.Variable(ds_1)
    ds_2 = tf.Variable(ds_2)
    ds_y = tf.Variable(ds_y)

    y = ds_y[:num_train_data - sett]
    y = tf.one_hot(y, depth=3)

      # Fitting model_1
    X = ds_1[:num_train_data - sett]
    model_1.fit(X, y, epochs=20, verbose=0)    # validation_split = 0.2,  tf.expand_dims(y, axis=-1)

      # Fitting model_2
    X = ds_2[:num_train_data - sett]
    model_2.fit(X, y, epochs=20, verbose=0) 



    # Predicting
  if loops >= num_train_data:
    
      #Model_1
    ds_1 = [opponent_history[-sett:]]
    X_1 = tf.constant(ds_1)
    prediction_1 = model_1.predict(X_1, verbose = 0)
    prediction_1 = tf.Variable(prediction_1).numpy().tolist()
   
      #Model_2
    ds_2 = [player_history[-sett:]]
    X_2 = tf.constant(ds_2)
    prediction_2 = model_2.predict(X_2, verbose = 0)
    prediction_2 = tf.Variable(prediction_2).numpy().tolist()


      # Average modell outputs
    prediction = []
    for n in range(3):
      prediction.append(((prediction_1[0][n])*1 + (prediction_2[0][n])*1.2)/2)


      # Pick the most likely opponent move
    prediction = tf.Variable(prediction).numpy().tolist()
    prediction = prediction.index(max(prediction))
  
    # Get the ideal responce for the prediction
  ideal_response = {'P': 'S', 'R': 'P', 'S': 'R'}
  prediction = ideal_response[num(prediction)]

    # Uppdate variables
  loops += 1
  prev_guess = prediction



    # Pure lazyness, I could have checked the Accuracy of the model every call. If this work than I 'aint gonna fix it.
  if loops == 1000:
    loops = 0
    player_history.clear()
    opponent_history.clear()
    print(opponent_history)

  return prediction
