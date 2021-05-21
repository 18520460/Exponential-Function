import bitstring
import math
from numpy import random
import numpy as np 
from fxpmath import Fxp

f = open("LUT_1_0.txt", "w")
number_of_LUT = 256
n_frac = 23
n_int = 3

val = 1
#list_of_input = random.random_sample((number_of_test,))
#plus = random.randint(100, size=(number_of_test))
for i in range(number_of_LUT):
    D_x = Fxp(val, signed=True, n_word=n_int + n_frac, n_frac=n_frac)
    x = Fxp(math.exp(val), signed=True, n_word=n_int + n_frac, n_frac=n_frac)
    a = hex(int(D_x.bin()[3:11], 2))[2:]
    if(len(a) == 1):
        a= '0'+a
    print(str(val) +  "   " +a  + "    "+ str(D_x.bin()[3:11]))    

    val = val - 1/number_of_LUT
    
    #ref = np.float32(math.exp(list_of_input[i] + plus[i]))
    #b_float_mum = bitstring.pack('>f', list_of_input[i] + plus[i])
    #b_ref = bitstring.pack('>f', ref)
    #f.write(b_float_mum.bin + ' ')
    f.write('@' + a + '\n' + x.bin() + '\n' )   
    #print(i) 
f.close()