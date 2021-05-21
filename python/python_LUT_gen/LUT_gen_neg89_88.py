import bitstring
import math
from numpy import random
import numpy as np 
from fxpmath import Fxp

f = open("LUT_neg89_88.txt", "w")
number_of_LUT = 256
n_frac = 23
n_int = 3
val = -103
# [-103:88]
while val != 89:
    ref = np.float32(math.exp(val))
    b_ref = bitstring.pack('>f', ref)
    f.write(b_ref.bin + '\n' )
    val = val + 1   
    print(val) 
f.close()