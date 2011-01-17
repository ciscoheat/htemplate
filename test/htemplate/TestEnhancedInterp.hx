package htemplate;

import hscript.Parser;
import htemplate.hscript.EnhancedInterp;
import utest.Assert;

class TestEnhancedInterp
{
	var parser : Parser;
	var interp : EnhancedInterp;

	public function new();
	
	public function setup()
	{
		parser = new Parser();
		interp = new EnhancedInterp();
	}
	
	public function run(template : String, ?variables : Hash<Dynamic>)
	{
		var expr = parser.parseString(template);
		if(null != variables)
			interp.variables = variables;
		return interp.execute(expr);
	}

	public function testOptionalArgumentsOnObject()
	{
		var vars = new Hash();
		vars.set("null", null);
		vars.set("sub", function(s : String, b : Int, ?len : Int) {
			if (null == len)
				return s.substr(b);
			else
				return s.substr(b, len);
		});
		// calling directly the string substr function may not be safe becase Flash considers null == 0
		Assert.equals("xe", run("sub('haxe', 2);", vars));
		Assert.equals("ha", run("sub('haxe', 0, 2);", vars));
		Assert.equals("xe", run("sub('haxe', 2, null);", vars));
	}
	
	public function testOptionalArgumentsOnFunction()
	{
		var f = function(?a : String) {
			return null == a ? "NULL" : a.toUpperCase();
		}
		var vars = new Hash();
		vars.set("f", f);
		vars.set("null", null);
		Assert.equals("HAXE", run("f('haxe');", vars));
		Assert.equals("NULL", run("f(null);", vars));
		Assert.equals("NULL", run("f();", vars));
	}
	
	public function testOptionalArgumentsOnMethod()
	{
		var vars = new Hash();
		vars.set("h", new Helper());
		Assert.equals("HAXE", run("h.f('ha','xe');", vars));
		Assert.equals("HAXE", run("h.f('haxe');", vars));
	}

	public function testCallInlineFunction()
	{
		Assert.equals("A", run("(function(){ return 'A';})();"));
		Assert.equals("A", run("var f = function(){ return 'A';};f();"));
	}
}

class Helper
{
	public function new();
	public function f(mand : String, ?opt : String)
	{
		return (mand + (null == opt ? "" : opt)).toUpperCase();
	}
}