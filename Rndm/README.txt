** Rndm **
Provides simple methods for working with random values, such as Rndm.float(min, max), and Rndm.sign(). Also includes a seeded random version.

There are three versions of the Rndm class included:

Rnd - uses Math.random() as it's generator. Not seeded. Recommended for most uses.

Rndm - seeded mathematical "random" numbers. Generally adequate for games / experiments, but not more critical uses.

RndmBmpd - uses noise in a BitmapData object to generate random values.

ex.
if (Math.boolean(0.2)) {
	foo.x = Math.sign()*Math.float(20,40);
}