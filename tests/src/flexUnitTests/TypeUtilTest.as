package flexUnitTests
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import org.flexunit.Assert;
	
	import mx.utils.TypeUtil;

	public class TypeUtilTest
	{
		[Test]
		public function testConstructor():void
		{
			try
			{
				new TypeUtil();
				
				Assert.fail("The TypeUtil class has been instantiated successfully");
			}
			catch(e:IllegalOperationError)
			{
				Assert.assertTrue(true);
			}
			catch(e:Error)
			{
				Assert.fail("Unknown exception was thrown");
			}
		}
		
		[Test]
		public function testCreateRequestObject0():void
		{
			try
			{
				Assert.assertNull(TypeUtil.createRequestObject(null));
			}
			catch(e:Error)
			{
				Assert.fail("An exception was thrown");
			}
		}
		
		[Test]
		public function testCreateRequestObject1():void
		{
			var result:Object = TypeUtil.createRequestObject(new MixedType());
			
			Assert.assertTrue(
				result.hasOwnProperty("field1"),
				!result.hasOwnProperty("field2"),
				result.field1 == null
			);
		}
		
		[Test]
		public function testCreateRequestObject2():void
		{
			var result:Object = TypeUtil.createRequestObject({name: "John", age: 25, balance: -1000.1});
			
			Assert.assertTrue(
				result != null,
				result.hasOwnProperty("name"),
				result.hasOwnProperty("age"),
				result.hasOwnProperty("balance"),
				result.name == "John",
				result.age == 25,
				result.balance == -1000.1
			);
		}
		
		[Test]
		public function testCreateRequestObject3():void
		{
			var obj:ComplexWithArray = new ComplexWithArray();
			obj.field1 = [];
			obj.field2 = ["1", "2"];
			obj.field3 = null;
			obj.field4 = [new Point(1,2), new Point(3,4)];
			
			var result:Object = TypeUtil.createRequestObject(obj);
			
			Assert.assertTrue(
				result != null,
				result.field1 is Array,
				result.field1.length = 0,
				result.field2 is Array,
				result.field1.length = 2,
				result.field3 == null,
				result.field4 is Array,
				result.field1.length = 2,
				!(result.field4[0] is Point),
				!(result.field4[1] is Point)
			);
		}
		
		[Test]
		public function testCreateTypedObject0():void
		{
			try
			{
				Assert.assertNull(TypeUtil.createTypedObject(null, Object));
			}
			catch(e:Error)
			{
				Assert.fail("An exception was thrown");
			}
			
			try
			{
				TypeUtil.createTypedObject({}, null);
				
				Assert.fail("Null argument passed successfully");
			}
			catch(e:ArgumentError)
			{
				Assert.assertTrue(true);
			}
			catch(e:Error)
			{
				Assert.fail("Unknown exception was thrown");
			}
		}
		
		[Test]
		public function testCreateTypedObject1():void
		{
			var obj:Object;
			
			obj = {};
			Assert.assertTrue(TypeUtil.createTypedObject(obj, Object) == obj);
			
			obj = {name:"John"};
			Assert.assertTrue(TypeUtil.createTypedObject(obj, Object) == obj);
		}
		
		[Test]
		public function testCreateTypedObject2():void
		{
			var obj:Object;
			
			obj = TypeUtil.createTypedObject({}, ComplexType1);
			Assert.assertTrue(obj is ComplexType1);
			
			obj = TypeUtil.createTypedObject({field1:"", field2:1}, MixedType);
			Assert.assertTrue(
				obj is MixedType, 
				obj.field1 == "", 
				obj.field2 == 1
			);
			
			obj = TypeUtil.createTypedObject({field1:null, field2:-1}, MixedType);
			Assert.assertTrue(
				obj is MixedType, 
				obj.field1 == null, 
				obj.field2 == -1
			);
		}
		
		[Test]
		public function testCreateTypedObject3():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{field1: "/Date(1325376000000)/"}, 
				ComplexWithDate
			);
			
			Assert.assertTrue(
				obj is ComplexWithDate, 
				obj.field1 is Date
			);
		}

		[Test]
		public function testCreateTypedObject4():void
		{			
			var obj:Object = TypeUtil.createTypedObject(
				{
					field1: [1, "2", null],
					field2: ["1", "2", "3"],
					field3: ["1", "2", "3"],
					field4: null
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field1 is Array,
				obj.field2 is Array,
				obj.field3 is Array,
				obj.field1.length == 3,
				obj.field2.length == 3,
				obj.field3.length == 3
			);
		}
		
		[Test]
		public function testCreateTypedObject5():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field2: null,
					field4: []
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field2 == null,
				obj.field4 is Array,
				obj.field4.length == 0
			);
		}
		
		[Test]
		public function testCreateTypedObject6():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field4: [new Point(), new Point(1,2)]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field4 is Array,
				obj.field4.length == 2,
				obj.field4[0] is Point,
				obj.field4[1] is Point,
				Point(obj.field4[1]).x == 1,
				Point(obj.field4[1]).y == 2
			);
		}
		
		[Test]
		public function testCreateTypedObject7():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field4: [new Point(), {}]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field4 is Array,
				obj.field4.length == 1,
				obj.field4[0] is Point
			);
		}
		
		[Test]
		public function testCreateTypedObject8():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field1: [[1,2], [3,4]],
					field5: [[1,2], [3,4]]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field1 is Array,
				obj.field1.length == 2,
				obj.field1[0] is Array,
				obj.field1[0].length == 2,
				obj.field1[0][0] == 1,
				obj.field1[0][1] == 2,
				obj.field1[1] is Array,
				obj.field1[1].length == 2,
				obj.field1[1][0] == 3,
				obj.field1[1][1] == 4,
				obj.field5 is Array,
				obj.field5.length == 2,
				obj.field5[0] is Array,
				obj.field5[0].length == 2,
				obj.field5[0][0] == 1,
				obj.field5[0][1] == 2,
				obj.field5[1] is Array,
				obj.field5[1].length == 2,
				obj.field5[1][0] == 3,
				obj.field5[1][1] == 4
			);
		}
		
		[Test]
		public function testCreateTypedObject9():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field6: [new Date(), new Date()]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field6 is Array,
				obj.field6.length == 2,
				obj.field6[0] is Date,
				obj.field6[1] is Date
			);
		}
		
		[Test]
		public function testCreateTypedObject10():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field6: ["/Date(1325376000000)/"]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field6 is Array,
				obj.field6.length == 1,
				obj.field6[0] is Date,
				(obj.field6[0] as Date).time == 1325376000000
			);
		}
		
		[Test]
		public function testCreateTypedObject11():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field6: ["/Date(1325376000000)/", 1325376000000]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field6 is Array,
				obj.field6.length == 1
			);
		}
		
		[Test]
		public function testCreateTypedObject12():void
		{
			var obj:Object = TypeUtil.createTypedObject(
				{
					field6: ["1325376000000", 1325376000000]
				}, 
				ComplexWithArray
			);
			
			Assert.assertTrue(
				obj is ComplexWithArray, 
				obj.field6 is Array,
				obj.field6.length == 0
			);
		}

		[Test]
		public function testIsBaseType1():void
		{
			Assert.assertTrue(TypeUtil.isBaseType(Object));
			Assert.assertTrue(TypeUtil.isBaseType(int));
			Assert.assertTrue(TypeUtil.isBaseType(uint));
			Assert.assertTrue(TypeUtil.isBaseType(Boolean));
			Assert.assertTrue(TypeUtil.isBaseType(Number));
			Assert.assertTrue(TypeUtil.isBaseType(String));
			Assert.assertTrue(TypeUtil.isBaseType(Array));
			Assert.assertTrue(TypeUtil.isBaseType(Date));
			Assert.assertTrue(TypeUtil.isBaseType(Error));
			Assert.assertTrue(TypeUtil.isBaseType(Function));
			Assert.assertTrue(TypeUtil.isBaseType(RegExp));
			Assert.assertTrue(TypeUtil.isBaseType(XML));
			Assert.assertTrue(TypeUtil.isBaseType(XMLList));
		}
		
		[Test]
		public function testIsBaseType2():void
		{
			Assert.assertFalse(TypeUtil.isBaseType(Event));
			Assert.assertFalse(TypeUtil.isBaseType(ByteArray));
		}
		
		[Test]
		public function testIsBaseType3():void
		{
			Assert.assertFalse(TypeUtil.isBaseType(ComplexType1));
			Assert.assertFalse(TypeUtil.isBaseType(ComplexType2));
		}
		
		[Test]
		public function testIsBaseTypeObject1():void
		{
			Assert.assertTrue(TypeUtil.isBaseTypeObject({}));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(1));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(-1));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(1.1));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(""));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(true));
			Assert.assertTrue(TypeUtil.isBaseTypeObject([]));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(new Date()));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(new Error()));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(function():void{}));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(new Error()));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(/d+/));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(<xml/>));
			Assert.assertTrue(TypeUtil.isBaseTypeObject(<><item/></>));
		}
		
		[Test]
		public function testIsBaseTypeObject2():void
		{
			Assert.assertFalse(TypeUtil.isBaseTypeObject(new Event(Event.COMPLETE)));
			Assert.assertFalse(TypeUtil.isBaseTypeObject(new ByteArray()));
		}
		
		[Test]
		public function testIsBaseTypeObject3():void
		{
			Assert.assertFalse(TypeUtil.isBaseTypeObject(new ComplexType1()));
			Assert.assertFalse(TypeUtil.isBaseTypeObject(new ComplexType2()));
		}
	}
}	

	//--------------------------------------------------------------------------
	//
	//  Helper classes
	//
	//--------------------------------------------------------------------------
	
	import flash.geom.Point;

	class ComplexType1
	{	
		public var field:String;
	}
	
	class ComplexType2 extends Error
	{	
		public var field:int;
	}
	
	class MixedType
	{
		public var field1:String;
		
		[Transient]
		public var field2:int;
	}
	
	class ComplexWithDate
	{
		public var field1:Date;
	}
	
	class ComplexWithArray
	{
		public var field1:Array;
		
		[ArrayElementType("String")]
		public var field2:Array;
		
		[ArrayElementType(elementType="String")]
		public var field3:Array;
		
		[ArrayElementType("flash.geom.Point")]
		public var field4:Array;
		
		[ArrayElementType("Array")]
		public var field5:Array;
		
		[ArrayElementType("Date")]
		public var field6:Array;
	}