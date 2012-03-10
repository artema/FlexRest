package flexUnitTests
{
	import flash.errors.IllegalOperationError;
	
	import org.flexunit.Assert;
	
	import mx.utils.JSONUtil;

	public class JSONUtilTest
	{		
		[Test]
		public function testConstructor():void
		{
			try
			{
				new JSONUtil();
				
				Assert.fail("The JSONUtil class has been instantiated successfully");
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
		public function testDeserialize0():void
		{
			Assert.assertTrue(JSONUtil.deserialize('{}') != null);
		}
		
		[Test]
		public function testDeserialize1():void
		{
			var result:Object = JSONUtil.deserialize('{"name":"John","age":25,"balance":-1000.1}');
			
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
		public function testDeserialize2():void
		{
			var result:Object = JSONUtil.deserialize(' {	"name" : "John" , "age" : 25,		"balance"	:	-1000.1		}	');
			
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
		public function testDeserialize3():void
		{
			var result:Object = JSONUtil.deserialize('{"name":null}');
			
			Assert.assertTrue(
				result != null,
				result.hasOwnProperty("name"),
				result.name == null
			);
		}
		
		[Test]
		public function testDeserialize4():void
		{
			try
			{
				JSONUtil.deserialize('{"name":"John"');
				Assert.fail("Invalid string was parsed successfully");
				
				JSONUtil.deserialize('{"name":"John}');
				Assert.fail("Invalid string was parsed successfully");
				
				JSONUtil.deserialize('"name":"John"}');
				Assert.fail("Invalid string was parsed successfully");
				
				JSONUtil.deserialize('{name:"John"}');
				Assert.fail("Invalid string was parsed successfully");
				
				JSONUtil.deserialize('{"name"}');
				Assert.fail("Invalid string was parsed successfully");
			}
			catch(e:SyntaxError)
			{
				Assert.assertTrue(true);
			}
			catch(e:Error)
			{
				Assert.fail("Unknown exception was thrown");
			}
		}
		
		[Test]
		public function testSerialize0():void
		{
			try
			{
				JSONUtil.serialize(null);
				
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
		public function testSerialize1():void
		{
			var result:String = JSONUtil.serialize({name: "John", age: 25, balance: -1000.1});
			
			Assert.assertTrue(
				result.indexOf('"name"') != -1, 
				result.indexOf('"John"') != -1,
				result.indexOf('"age"') != -1,
				result.indexOf('25') != -1,
				result.indexOf('"balance"') != -1,
				result.indexOf('-1000.1') != -1
			);
		}
		
		[Test]
		public function testSerialize2():void
		{
			Assert.assertEquals(JSONUtil.serialize("A string"), '"A string"');
			Assert.assertEquals(JSONUtil.serialize(123), "123");
			Assert.assertEquals(JSONUtil.serialize(-123), "-123");
		}
		
		[Test]
		public function testParseDate0():void
		{
			try
			{
				JSONUtil.parseDate(null);
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
		public function testParseDate1():void
		{
			Assert.assertNull(JSONUtil.parseDate(""));
			Assert.assertNull(JSONUtil.parseDate("DATE"));
			Assert.assertNull(JSONUtil.parseDate("1234567890"));
			Assert.assertNull(JSONUtil.parseDate(new Date().toString()));
			Assert.assertNull(JSONUtil.parseDate("Date(1325376000000)"));
			Assert.assertNull(JSONUtil.parseDate("Date(1325376000000+0400)"));
			Assert.assertNull(JSONUtil.parseDate("/Date(1325376000000+0400)"));
			Assert.assertNull(JSONUtil.parseDate("Date(1325376000000+0400)/"));
			Assert.assertNull(JSONUtil.parseDate("/Date(1325376000000+10400)/"));
			Assert.assertNull(JSONUtil.parseDate("/Date(1325376000000+400)/"));
		}
		
		[Test]
		public function testParseDate2():void
		{
			Assert.assertNotNull(JSONUtil.parseDate("/Date(1325376000000)/"));
			Assert.assertNotNull(JSONUtil.parseDate("/Date(-1325376000000)/"));
			Assert.assertNotNull(JSONUtil.parseDate("/Date(1325376000000+0400)/"));
			Assert.assertNotNull(JSONUtil.parseDate("/Date(1325376000000-0400)/"));
			Assert.assertNotNull(JSONUtil.parseDate("/Date(1)/"));
			Assert.assertNotNull(JSONUtil.parseDate("/Date(1-0000)/"));
		}
		
		[Test]
		public function testParseDate3():void
		{
			var date:Date;
			
			date = JSONUtil.parseDate("/Date(1325376000000-0400)/");
			Assert.assertTrue(date.fullYearUTC == 2012 && date.hoursUTC == 0);
			
			date = JSONUtil.parseDate("/Date(-1325376000000)/");
			Assert.assertTrue(date.fullYearUTC == 1928 && date.hoursUTC == 0);
		}
		
		[Test]
		public function testSerializeDate0():void
		{
			try
			{
				JSONUtil.serializeDate(null);
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
		public function testSerializeDate1():void
		{
			Assert.assertTrue(JSONUtil.serializeDate(new Date(0)) == "/Date(0)/");
			Assert.assertTrue(JSONUtil.serializeDate(new Date(1325376000000)) == "/Date(1325376000000)/");
			Assert.assertTrue(JSONUtil.serializeDate(new Date(-1325376000000)) == "/Date(-1325376000000)/");
		}
	}
}