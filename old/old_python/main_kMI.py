import numpy as np
import sys
import pyautogui

user_data = {}

# initializing function
def initialize():
    user_data['count'] = 0

    # add path
    path = 'C:/Users/UshibaLab/01-individuals/matsuyanagi'
    sys.path.append(path)

    # Tobii Calibration
    from class_knee_MI import knee_MI
    user_data['kMI'] = knee_MI()

    return user_data['count']

# postprocessing function
def post_process(stream_data_list):
    results = np.empty(0, dtype=np.float64)
    stream_data = stream_data_list[0]
    if stream_data['time_series'][0][0] == 99:
        user_data['kMI'].calibration()
    return results
