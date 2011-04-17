** CollisionDetection **
Pixel-perfect shape based collision detection.

Also includes CollisionEngine, which is an untested collision detection engine which combines grid based proximity with shape based collision detection.

ex.
var intersection:Rectangle = CollisionDetection.check(foo, bar);
if (intersection) {
	trace("collision!");
}