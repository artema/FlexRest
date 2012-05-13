package mx.rpc.http
{
	import mx.utils.OperationUtil;

	/**
	 * Basic HTTP authentication serialization filter.
	 * @author Artem Abashev
	 */
	final public class BasicAuthenticationSerializationFilter extends CompositeSerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Username.
		 */
		public var username:String;
		
		/**
		 * Password.
		 */
		public var password:String;
		
		//--------------------------------------------------------------------------
		//
		//  SerializationFilter methods
		//
		//--------------------------------------------------------------------------
		
		override public function serializeBody(operation:AbstractOperation, obj:Object):Object
		{
			var body:Object = super.serializeBody(operation, obj);

			if(username == null) throw new ArgumentError("Username is not provided.");
			if(password == null) throw new ArgumentError("Password is not provided.");

			OperationUtil.useBasicHttpAuthorization(operation, username, password);
			
			return body;
		}
	}
}