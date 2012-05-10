package mx.rpc.http
{
	/**
	 * OAuth authorization HTTP header.
	 * @author Artem Abashev
	 */
	final dynamic public class OAuthHeader
	{
		/**
		 * Consumer key that identifies which application is making the request.
		 */
		public var oauth_consumer_key:String;
		
		/**
		 * A unique token your application should generate for each unique request.
		 */
		public var oauth_nonce:String;
		
		/**
		 * Message signature.
		 */
		public var oauth_signature:String;
		
		/**
		 * Method name used to encode the signature.
		 */
		public var oauth_signature_method:String;
		
		/**
		 * The number of seconds since the Unix epoch at the point the request is generated.
		 */
		public var oauth_timestamp:uint;
		
		/**
		 * Represents a user's permission to share access to their account with your application.
		 */
		public var oauth_token:String;
		
		/**
		 * OAuth version used in this request.
		 */
		public var oauth_version:String;
		
		public function toString():String
		{
			var pairs:Vector.<String> = new Vector.<String>();
			var value:Object;			
			
			for(var p:String in this)
			{
				value = this[p] || "";
				value = escape(value.toString());
				p = escape(p);
				
				pairs.push(p + '="' + value + '"');
			}
			
			return pairs.length == 0
				? ""
				: "OAuth " + pairs.join(", ");
		}
	}
}