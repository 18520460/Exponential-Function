import bitstring
import math
from numpy import random
import numpy as np 

number_of_test = 500000

f = open("test_case.txt", "w")
#[-105:105]
bias = 211 / number_of_test
plus = []
tmp = -105
for i in range(number_of_test):
    plus.append(tmp)
    tmp = tmp + bias
for i in range(number_of_test):
    ref = np.float32(math.exp( plus[i]))
    b_float_mum = bitstring.pack('>f', plus[i])
    b_ref = bitstring.pack('>f', ref)
    f.write(b_float_mum.bin + '_')
    f.write(b_ref.bin + '\n')    
f.close()