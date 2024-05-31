#!/usr/bin/env python3

import argparse
from math import ceil
import os

import numpy as np
from numba import *

from PIL import Image

from common import *

ANON_FLAG = uint32(PageFlags.ANON)
ANON_EXCL_FLAG = uint32(PageFlags.ANON_EXCL)
MOVABLE_FLAG = uint32(PageFlags.MOVABLE)
HEAD_FLAG = uint32(PageFlags.HEAD)

@njit
def colorize(types, flags, counts, height, highlight_head=False):
    total = len(types)
    imdata = np.zeros((height,ceil(total/height),3), dtype=np.uint8)

    for i in range(total):
        color = [0, 0, 0]
        if types[i] == Page.FREE:
            pass
        elif highlight_head and flags[i] & HEAD_FLAG:
            color = [255, 255, 255]
        elif types[i] == Page.RESERVED:
            color = [0, 255, 0]
        elif types[i] == Page.SLAB:
            color = [255, 0, 0]
        elif types[i] == Page.OTHER:
            color = [255, 0, 255]
        elif types[i] == Page.USER or types[i] == Page.SWAPCACHE:
            if not (flags[i] & ANON_FLAG) or types[i] == Page.SWAPCACHE:
                color = [0, 0, 255]
            else:
                color = [0, 255, 255]

            if counts[i] <= 0: # and not (flags[i] & ANON_EXCL_FLAG)
                for j in range(len(color)):
                    color[j] = int(color[j]*0.5)

        imdata[i%height][i//height] = color

    return imdata

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("input", nargs='+')
    parser.add_argument("-f", "--format", type=str, default="png")
    parser.add_argument("-p", "--prefix", type=str, default="")
    parser.add_argument("-H", "--height", type=int, default=512)
    parser.add_argument("--head", action='store_true')

    args = parser.parse_args()

    height = args.height

    for infile in args.input:
        outfile = args.prefix + os.path.splitext(infile)[0] + f".{args.format}"

        npz = np.load(infile)
        total = len(npz["types"])

        print(f'Writing {outfile} with {ceil(total/height)}x{height}')

        col_func = colorize

        im = Image.fromarray(col_func(npz["types"], npz["flags"], npz["mapcounts"], height, highlight_head=args.head), mode="RGB")
        im.save(outfile)
