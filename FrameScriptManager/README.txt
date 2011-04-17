** FrameScriptManager **
Inject ActionScript into a movieclip timeline at a specific frame number or label. Great for separating code and design.

ex.
var foo:FrameScriptManager = new FrameScriptManager(mc);
foo.setFrameScript("label1", myFunction1);
foo.setFrameScript(12, myFunction2);