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
DIRTY_FLAG = uint32(PageFlags.DIRTY)

@njit
def colorize(types, flags, counts, height, highlight_head=False):
    total = len(types)
    imdata = np.zeros((height,ceil(total/height),3), dtype=np.uint8)

    for i in range(total):
        color = [0, 0, 0]
        if types[i] == Page.FREE:
            pass
        if types[i] == Page.FAULT:
            color = [100,100,100]
        elif highlight_head and flags[i] & HEAD_FLAG:
            color = [255, 255, 255]
        elif types[i] == Page.RESERVED:
            color = [0, 255, 0]
        elif types[i] == Page.SLAB:
            color = [255, 0, 0]
        elif types[i] == Page.OTHER:
            color = [255, 0, 0]
        elif types[i] == Page.USER or types[i] == Page.SWAPCACHE:
            if not (flags[i] & ANON_FLAG) or types[i] == Page.SWAPCACHE:
                color = [0, 128, 255] if counts[i] > 0 else [0, 0, 255]
            else:
                color = [0, 255, 255] if counts[i] > 0 else [0, 200, 200]

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

        types = npz["types"]
        flags = npz["flags"]
        counts = npz["mapcounts"]

        empty_range = range(1536*512, 2048*512)
        types = np.delete(types, empty_range)
        flags = np.delete(flags, empty_range)
        counts = np.delete(counts, empty_range)

        total = len(types)

        print(f'Writing {outfile} with {ceil(total/height)}x{height}')

        col_func = colorize

        im = Image.fromarray(col_func(types, flags, counts, height, highlight_head=args.head), mode="RGB")
        im.save(outfile)
