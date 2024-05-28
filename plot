#!/usr/bin/env python3

import argparse
from math import ceil
import os

import numpy as np
from numba import jit

from PIL import Image

from common import Page

@jit(nopython=True)
def colorize(data, height, mapcounts=None):
    total = len(data)
    imdata = np.zeros((height,ceil(total/height),3), dtype=np.uint8)

    for (i, v) in enumerate(data):
        color = [255, 0, 0]
        if v == Page.FREE:
            color = [0, 0, 0]
        elif v == Page.RESERVED:
            color = [0, 255, 0]
        elif v == Page.ANON:
                color = [0, 255, 255]
        elif v == Page.FILE:
            if mapcounts is not None and mapcounts[i] == -1:
                color = [0, 0, 100]
            else:
                color = [0, 0, 255]

        imdata[i%height][i//height] = color

    return imdata

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("input", nargs='+')
    parser.add_argument("-f", "--format", type=str, default="png")
    parser.add_argument("-H", "--height", type=int, default=512)

    args = parser.parse_args()

    height = args.height

    for infile in args.input:
        outfile = os.path.splitext(infile)[0] + f".{args.format}"

        npz = np.load(infile)

        data = npz['pages']

        print(f'Writing {outfile} with {ceil(len(data)/height)}x{height}')

        im = Image.fromarray(colorize(data, height, mapcounts=npz.get("mapcounts", None)), mode="RGB")
        im.save(outfile)
