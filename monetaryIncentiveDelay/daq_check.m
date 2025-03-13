d = daq('ni');
ch = addinput(d, 'Dev2', 'ai3', 'Voltage');

data = read(d, 1);
fprintf('AI3 Voltage: %.3f V\n', data.Dev2_ai3);
