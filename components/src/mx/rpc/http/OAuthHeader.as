/*
* Copyright (c) 2012
* Artem Abashev
* http://abashev.me/
*
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the GNU Lesser General Public License
* (LGPL) version 3.0 which accompanies this distribution, and is available at
* http://www.gnu.org/licenses/lgpl-3.0.html
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*/
package mx.rpc.http
{
	import mx.utils.OAuthUtil;

	/**
	 * OAuth authorization HTTP header.
	 * @author Artem Abashev
	 */
	final dynamic public class OAuthHeader
	{
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * OAuth signature method: HMAC-SHA1.
		 */
		static public const SIGNATURE_METHOD_HMAC_SHA1:String = "HMAC-SHA1";
		
		/**
		 * OAuth signature method: HMAC-MD5.
		 */
		static public const SIGNATURE_METHOD_HMAC_MD5:String = "HMAC-MD5";
		
		//--------------------------------------------------------------------------
		//
		//  Data
		//
		//--------------------------------------------------------------------------
		
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
		
		[Inspectable(enumeration="HMAC-SHA1,HMAC-MD5", defaultValue="HMAC-SHA1", category="General")]
		/**
		 * Method name used to encode the signature. Valid values are <code>HMAC-SHA1</code> and <code>RSA-MD5</code>.
		 * The default value is <code>HMAC-SHA1</code>.
		 */
		public var oauth_signature_method:String = SIGNATURE_METHOD_HMAC_SHA1;
		
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
		public var oauth_version:String = "1.0";
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		public function clone():OAuthHeader
		{
			var copy:OAuthHeader = new OAuthHeader();
			var key:String;
			
			for each(key in FIELDS) copy[key] = this[key];
			for(key in this) copy[key] = this[key];
			return copy;
		}
		
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
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		static private function getPair(key:String, value:String):String
		{
			if(value == null) value = "";
			return OAuthUtil.percentEncode(key) + '="' + OAuthUtil.percentEncode(value.toString()) + '"';
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