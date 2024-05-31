from enum import IntEnum, IntFlag, auto
import numpy as np

class Page(IntEnum):
    FREE     = 0
    RESERVED = auto()
    SLAB     = auto()
    OTHER    = auto()
    USER     = auto()
    SWAPCACHE= auto()

class PageFlags(IntFlag):
    COMPOUND = auto()
    HEAD     = auto()
    ANON     = auto()
    MOVABLE  = auto()
    ANON_EXCL= auto()
