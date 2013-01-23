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
package mx.utils
{
	import com.adobe.crypto.*;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.*;
	
	import mx.rpc.http.OAuthHeader;

	/**
	 * OAuth utility.
	 * @author Artem Abashev
	 */
	final public class OAuthUtil
	{
		/**
		 * @private
		 */
		public function OAuthUtil(){ throw new IllegalOperationError(); }
		
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Unescaped characters.
		 */
		static private const UNESCAPED_CHARACTERS:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._~";
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Percent encode a string value.
		 */
		static public function percentEncode(value:String):String
		{
			if(value == null || value == "") return value;
			
			var char:String, content:String = "", encoded:String = "";
			var i:uint, length:uint, code:Number;
			
			length = value.length;
			
			//Prepare unicode characters.
			//Only encode single UTF-16 pair values, the Basic Multilingual Plane,
			//which contains code points from U+0000 to U+FFFF (2^16).
			for(i=0 ; i<length; i++)
			{
				code = value.charCodeAt(i);

				//U+0000 - U+007F
				if(code < 128)
				{
					content += value.charAt(i);
					continue;
				}
				
				//U+0080 - U+07FF
				if(code >= 128 && code < 2048)
				{
					content += 
						String.fromCharCode(code >> 6 | 192) + //11000000
						String.fromCharCode(code & 63 | 128);  //10000000
					continue;
				}
				
				//U+0800 - U+FFFF
				if(code >= 2048 && code < 65536)
				{
					content += String.fromCharCode(code >> 12 | 224) + //11100000
						String.fromCharCode(code >> 6 & 63 | 128) +    //00111111 | 10000000
						String.fromCharCode(code & 63 | 128);          //00111111 | 10000000
					continue;
				}
			}
			
			length = content.length;
			
			//Percent-encode a string
			for(i=0 ; i<length; i++)
			{
				char = value.charAt(i);
				
				//Skip characters that do need to be escaped
				if(UNESCAPED_CHARACTERS.indexOf(char) != -1)
				{
					encoded += char;
					continue;
				}
				
				//Write two characters representing the uppercase 
				//ASCII-encoded hex value of the current byte
				encoded += "%" + char.charCodeAt().toString(16).toUpperCase();
			}
			
			return encoded;
		}
		
		/**
		 * Generate a random nonce.
		 */
		static public function generateNonce():String
		{
			return UIDUtil.createUID();
		}
		
		/**
		 * Get a timestamp.
		 */
		static public function getTimestamp():uint
		{
			return new Date().time * 0.001;
		}
		
		/**
		 * Get parameters for OAuth signatury base string.
		 */
		static public function getParams(params:Dictionary, oauthHeader:OAuthHeader, request:Object=null):void
		{
			//Add OAuth header values
			params["oauth_consumer_key"] = oauthHeader.oauth_consumer_key;
			params["oauth_nonce"] = oauthHeader.oauth_nonce;
			params["oauth_signature_method"] = oauthHeader.oauth_signature_method;
			params["oauth_timestamp"] = oauthHeader.oauth_timestamp;
			params["oauth_token"] = oauthHeader.oauth_token;
			params["oauth_version"] = oauthHeader.oauth_version;
			
			//Add request values
			if(request != null)
			{
				for(var key:String in request)
					params[key] = request[key];
			}
		}
		
		/**
		 * Calculate base string.
		 */
		static public function createBaseString(params:Dictionary):String
		{
			var pairs:Array = [];
			var value:String;
			
			//Percent encode key-value pairs
			for(var key:String in params)
			{
				value = OAuthUtil.percentEncode(params[key] || "");
				pairs.push(OAuthUtil.percentEncode(key) + "=" + value);
			}
			
			//Sort pairs alphabetically
			pairs.sort();
			
			return pairs.join("&");
		}
		
		/**
		 * Calculate data hash using the provided hash method and signing key.
		 * @param data Data to hash.
		 * @param signingKey Signing key.
		 * @param hashMethod Hash method to use.
		 */
		static public function calculateHash(data:String, signingKey:String, hashMethod:String):String
		{
			if(signingKey == null) throw new ArgumentError("signingKey");
			if(data == null) data = "";
			
			var result:String;

			switch(hashMethod)
			{
				case OAuthHeader.SIGNATURE_METHOD_HMAC_SHA1:
				{
					result = HMAC.hash(signingKey, SHA1.hash(data));
					break;
				}
					
				case OAuthHeader.SIGNATURE_METHOD_HMAC_MD5:
				{
					result = HMAC.hash(signingKey, MD5.hash(data));
					break;
				}
					
				default:
					throw new ArgumentError("Invalid hash method: " + hashMethod);
			}

			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeUTFBytes(result)

			return encoder.toString();
		}
	}
}