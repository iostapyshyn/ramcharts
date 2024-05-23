from enum import IntEnum
import numpy as np

class Page(IntEnum):
    FREE     = 0
    RESERVED = 1
    ANON     = 2
    FILE     = 3
    OTHER    = 4
