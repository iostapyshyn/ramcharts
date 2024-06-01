from enum import IntEnum, IntFlag, auto
import numpy as np

class Page(IntEnum):
    FREE     = 0
    RESERVED = auto()
    SLAB     = auto()
    OTHER    = auto()
    USER     = auto()
    SWAPCACHE= auto()
    FAULT    = auto()

class PageFlags(IntFlag):
    COMPOUND = auto()
    HEAD     = auto()
    ANON     = auto()
    DIRTY    = auto()
    MOVABLE  = auto()
    ANON_EXCL= auto()
