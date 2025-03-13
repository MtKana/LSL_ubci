import tkinter as tk
import nidaqmx

class knee_MI:
    def __init__(self):
        self.window = {
            'initial_width': 600,
            'initial_height': 200,
            'width': 100,
            'height': 100,
            'gap': 20,
        }
        self.flag = 0
        self.time = 10000

        self.DIN = [
            [[0], [0], [0], [0]],
            [[5], [0], [0], [0]],
            [[0], [5], [0], [0]],
            [[0], [0], [5], [0]],
            [[0], [0], [0], [5]]
        ]   

    def send_daq(self,pat):
        with nidaqmx.Task() as task:
            task.ao_channels.add_ao_voltage_chan("Dev2/ao0:3")
            task.write(self.DIN[pat], auto_start=True)
            task.write(self.DIN[0], auto_start=True)

    def move_window(self, x, y):
        self.root.geometry("{}x{}+{}+{}".format(self.window['width'], self.window['height'], x, y))

    def change_pos(self, sec, x, y):
        self.root.after(self.time, lambda: self.move_window(x,y))
        self.time += sec

    def calibration(self):
        if self.flag == 0:
            self.flag = 1

            # initialize tk window
            self.root = tk.Tk()
            self.root.overrideredirect(True)        

            # set para
            self.screen = {
            'width': self.root.winfo_screenwidth(),
            'height': self.root.winfo_screenheight()
            }
            self.position = {
            'initial_x': (self.screen['width'] - self.window['initial_width']) // 2,
            'initial_y': (self.screen['height'] - self.window['initial_height']) // 2,
            'center_x': (self.screen['width'] - self.window['width']) // 2,
            'center_y': (self.screen['height'] - self.window['height']) // 2,
            'right_x': self.screen['width'] - self.window['width'],
            'bottom_y': self.screen['height'] - self.window['height']
            }   

            # please wait
            self.root.geometry("{}x{}+{}+{}".format(self.window['initial_width'], self.window['initial_height'], self.position['initial_x'], self.position['initial_y']))
            self.label = tk.Label(self.root, text='Please wait...', font=('Helvetica', 50), fg='white', bg='black')
            self.label.pack(fill=tk.BOTH, expand=True)

            # begin calibration
            self.root.after(self.time, lambda: self.label.destroy())

            self.canvas = tk.Canvas(self.root, width=self.window['width'], height=self.window['height'], bg='black', highlightthickness=0)
            self.circle = self.canvas.create_oval(
            self.window['gap'], self.window['gap'], self.window['width']-self.window['gap'], self.window['height']-self.window['gap'], fill='red')

            self.root.after(self.time, lambda: self.canvas.pack())
            self.change_pos(10000, self.position['center_x'], self.position['center_y']) 

            for i in range(2):  
                self.change_pos(5000, self.position['right_x'], 0)  
                self.send_daq(1)                        
                self.change_pos(5000, 0, 0)   
                self.send_daq(1)                                                    
                self.change_pos(5000, self.position['right_x'], self.position['bottom_y'])
                self.send_daq(1)      
                self.change_pos(5000, 0, self.position['bottom_y'])                          
                self.change_pos(5000, self.position['center_x'], self.position['center_y']) 

            # end calibration
            self.root.after(65000, lambda: self.root.destroy())  
            self.root.mainloop()                                                   
            