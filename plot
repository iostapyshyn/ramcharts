#!/usr/bin/env python3

import numpy as np
from numba import jit, typed

import sys

from PIL import Image

from math import ceil, sqrt

from common import Page

infile = sys.argv[1]

data = np.fromfile(sys.argv[1], dtype=np.uint32)

height = 512 * 4 # ceil(sqrt(total))

print(ceil(len(data)/height))

@jit(nopython=True)
def colorize(data, height):
    total = len(data)
    imdata = np.zeros((height,ceil(total/height),3), dtype=np.uint8)

    for (i, v) in enumerate(data):
        color = [255, 0,   0]
        if v == Page.FREE:
            color = [0, 0, 0]
        elif v == Page.RESERVED:
            color = [0, 255, 0]
        elif v == Page.ANON:
            color = [0, 255, 255]
        elif v == Page.FILE:
            color = [0, 0, 255]

        imdata[i%height][i//height] = color

    return imdata

im = Image.fromarray(colorize(data, height), mode="RGB")
im.save(infile+'.png')
