package mx.rpc.http
{
	import flash.utils.describeType;

	/**
	 * OAuth authorization HTTP header.
	 * @author Artem Abashev
	 */
	final dynamic public class OAuthHeader extends Object
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
			var key:String;
			var value:Object;	
			var pairs:Vector.<String> = new Vector.<String>();					
			
			for each(key in FIELDS) pairs.push(getPair(key, this[key]));			
			for(key in this) pairs.push(getPair(key, this[key]));
			
			return pairs.length == 0
				? ""
				: "OAuth " + pairs.join(", ");
		}
		
		static private function getPair(key:String, value:String):String
		{
			if(value == null) value = "";
			return escape(key) + '="' + escape(value.toString()) + '"';
		}
		
		static private const FIELDS:Array = [
			"oauth_consumer_key",
			"oauth_nonce",
			"oauth_signature",
			"oauth_signature_method",
			"oauth_timestamp",
			"oauth_token",
			"oauth_version"
		];
	}
}