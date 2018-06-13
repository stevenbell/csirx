# Decode a binary blob from the camera into something resembling an image
# Steven Bell <sebell@stanford.edu>
# 29 December 2017

import numpy as np
import matplotlib.pyplot as plt
from IPython import embed

# Load the data
blob = np.fromfile('image4.bin', dtype=np.uint8)

# Flip the channels
ch1 = blob[0::2]
ch2 = blob[1::2]

merged = np.zeros(len(ch1) + len(ch2))
merged[1::2] = ch1
merged[0::2] = ch2

#merged = np.delete(merged, np.s_[1::5]) # Throw out the packed low 2 bits

# This looks like 1640 pixels wide
w = 1040*2; # 832*2; #832*4 # 1040 includes the low-order bits
h = len(merged) / w

im = merged[0:w*h].reshape(h, w)

#plt.imshow(im[1000:2000,0:1200])
plt.imshow(im)
plt.show()

#embed()

