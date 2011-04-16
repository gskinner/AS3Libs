There are three versions of the Rndm class:

Rnd - uses Math.random() as it's generator. Not seeded. Recommended for most uses.

Rndm - seeded mathematical "random" numbers. Generally adequate for games / experiments, but not more critical uses.

RndmBmpd - uses noise in a BitmapData object to generate random values.