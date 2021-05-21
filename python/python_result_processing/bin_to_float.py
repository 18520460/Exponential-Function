import struct
import math
import matplotlib.pyplot as plt
f = open("result.txt", "r")
convert = open("final_result.txt", "w")
def bin_to_float(binary):
    return struct.unpack('!f', struct.pack('!I', int(binary, 2)))[0]

n = -105
tmp = []
case = f.readline()
while case != '':
    case = case.split()
    case[0] = bin_to_float(case[0])
    case[1] = bin_to_float(case[1])
    tmp.append(case)
    case  = f.readline()

count = 0
i_bias = 0
x_error_list = []
y_error_list = []
sum = 0
max = 0
while n != 105:
    convert.write('Range ' + str(n) +' to ' + str(n + 1) + ' :\n')
    for i in range(2370):
        error = (abs(tmp[i + i_bias][0] - tmp[i + i_bias][1]))
        sum = sum + error
        if (max < error):
            max = error
    if max == 0:
        avg = 0
    else:
        avg = sum / 2369
    convert.write('     Max error : ' + str(max) + '\n')
    convert.write('     Average error : ' + str(avg) + '\n')
    convert.write('     Test number : ' + str(2370) + '\n')
    #update error list
    x_error_list.append(avg)
    y_error_list.append(n)
    #reset
    i_bias = i_bias + 2370
    sum = 0
    max = 0
    n = n + 1

plt.plot(y_error_list, x_error_list)
plt.show()
print('done')

