package 
{
	import flash.errors.IllegalOperationError;
	
	import flexUnitTests.*;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class FlexRestTests
	{
		//Make sure that compiler constants are set correctly
		SETUP::LEGACY
		{
			SETUP::MODERN
			{
				static private const lock:* = function():*
				{ 
					throw new IllegalOperationError("Invalid porject setup: both SETUP::LEGACY and SETUP::MODERN are set to true.");
					return null;
				}();
			}
		}
		
		public var test1:TypeUtilTest;
		
		SETUP::MODERN
		{
			public var test2:TypeUtilModernTest;
		}
		
		public var test3:JSONUtilTest;		
	}
}