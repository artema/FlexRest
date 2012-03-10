package flexUnitTests
{
	import flash.geom.Point;
	
	import org.flexunit.Assert;
	
	import mx.utils.TypeUtil;
	
	public class TypeUtilModernTest
	{
SETUP::MODERN
{
		[Test]
		public function testCreateTypedObject0():void
		{
			var obj:Object;
			
			obj = TypeUtil.createTypedObject(
				{
					field1: null
				}, 
				ComplexWithVector
			);
			
			Assert.assertTrue(
				obj is ComplexWithVector, 
				obj.field1 == null
			);
			
			obj = TypeUtil.createTypedObject(
				{
					field1: []
				}, 
				ComplexWithVector
			);
			
			Assert.assertTrue(
				obj is ComplexWithVector, 
				obj.field1 is Vector.<Point>,
				obj.field1.length == 0
			);
		}
		
		[Test]
		public function testCreateTypedObject1():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field2: ["/Date(1325376000000)/"]
				}, 
				ComplexWithVector
			);
			
			Assert.assertTrue(
				obj is ComplexWithVector, 
				obj.field2 is Vector.<Date>,
				obj.field2.length == 1,
				obj.field2[0] is Date,
				(obj.field2[0] as Date).time == 1325376000000
			);
		}
	
		[Test]
		public function testCreateTypedObject2():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field1: [new Point(1,2), new Point(3,4)]
				}, 
				ComplexWithVector
			);
			
			Assert.assertTrue(
				obj is ComplexWithVector, 
				obj.field1 is Vector.<Point>,
				obj.field1.length == 2,
				obj.field1[0] is Point,
				obj.field1[1] is Point
			);
		}
		
		[Test]
		public function testCreateTypedObject3():void
		{
			try
			{
				var obj:Object = TypeUtil.createTypedObject(
					{
						field1: ["", new Point(1,2)]
					}, 
					ComplexWithVector
				);
				
				Assert.fail("No exception was thrown");
			}
			catch(e:Error)
			{
				Assert.assertTrue(true);
			}
		}
		
		[Test]
		public function testCreateRequestObject3():void
		{
			var obj:ComplexWithVector = new ComplexWithVector();
			obj.field1 = new Vector.<Point>();
			obj.field1.push(new Point(1,2));
			obj.field1.push(new Point(3,4));
			
			var result:Object = TypeUtil.createRequestObject(obj);
			
			Assert.assertTrue(
				result != null,
				result.field1 is Array,
				result.field1.length = 2,
				!(result.field1[0] is Point),
				!(result.field1[1] is Point)
			);
		}
}
	}
}
	//--------------------------------------------------------------------------
	//
	//  Helper classes
	//
	//--------------------------------------------------------------------------
	
	import flash.geom.Point;

	class ComplexWithVector
	{
SETUP::MODERN
{
		public var field1:Vector.<Point>;
		
		public var field2:Vector.<Date>;
}
	}