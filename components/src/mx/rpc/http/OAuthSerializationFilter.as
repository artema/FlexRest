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
	import com.adobe.net.URI;

	import flash.errors.IllegalOperationError;
	import flash.utils.*;
	
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.utils.*;

	/**
	 * OAuth serialization filter.
	 * @author Artem Abashev
	 */
	public class OAuthSerializationFilter extends CompositeSerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * OAuth header to use.
		 */
		public var oauthData:OAuthHeader;
		
		/**
		 * Consumer's key secret.
		 */
		public var keySecret:String;
		
		/**
		 * Token's secret.
		 */
		public var tokenSecret:String;
		
		//--------------------------------------------------------------------------
		//
		//  Data
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Original HTTP method.
		 */
		private var _method:String;
		
		//--------------------------------------------------------------------------
		//
		//  SerializationFilter methods
		//
		//--------------------------------------------------------------------------
		
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			//Store original HTTP method
			if(_method == null)
				_method = operation.method;
			
			return super.serializeParameters(operation, params);
		}
		
		override public function serializeURL(operation:AbstractOperation, obj:Object, url:String):String
		{
			//Store original HTTP method
			if(_method == null)
				_method = operation.method;
			
			return super.serializeURL(operation, obj, url);
		}
		
		override public function serializeBody(operation:AbstractOperation, obj:Object):Object
		{
			//Reset saved method
			var method:String = _method || operation.method;
			_method = null;
			
			var body:Object = super.serializeBody(operation, obj);	

			if(oauthData == null) return body;
			if(oauthData.oauth_consumer_key == null) throw new ArgumentError("OAuth consumer key is not provided.");
			if(oauthData.oauth_signature_method == null) throw new ArgumentError("OAuth signature method is not provided.");
			if(oauthData.oauth_version == null) throw new ArgumentError("OAuth version number is not provided.");

			if(keySecret == null || keySecret == "") throw new ArgumentError("keySecret is not provided");
			if(tokenSecret == null || tokenSecret == "") throw new ArgumentError("tokenSecret is not provided");
			
			var signingKey:String = OAuthUtil.percentEncode(keySecret) + "&" + OAuthUtil.percentEncode(tokenSecret);
			
			//Generate timestamp and nonce
			var nonce:String = oauthData.oauth_nonce || OAuthUtil.generateNonce();
			var timestamp:uint = oauthData.oauth_timestamp || OAuthUtil.getTimestamp();

			//Parse the URL
			var uri:URI = new URI(operation.url);
			var queryParams:Object = uri.getQueryByMap();
			var baseUrl:String = operation.url;
			
			var params:Dictionary = new Dictionary();
			
			//HTTP body contains a key-value parameters string
			if(operation.contentType == HTTPRequestMessage.CONTENT_TYPE_FORM)
			{
				//Get values from OAuth data and the request object
				OAuthUtil.getParams(params, oauthData, obj);
			}
			//HTTP body contains a serialized value
			else
			{
				var content:String = body != null 
					? body.toString()
					: "";
				
				//Get values from OAuth data
				OAuthUtil.getParams(params, oauthData);
				
				//Calculate the body hash
				params["oauth_body_hash"] = oauthData["oauth_body_hash"] = OAuthUtil.calculateHash(content, signingKey, oauthData.oauth_signature_method);				
			}
			
			var hasQueryParams:Boolean;
			
			//Append query params
			for(var key:String in queryParams)
			{
				hasQueryParams = true;
				params[key] = queryParams[key];
			}
			
			//Remove query part of the URL
			if(hasQueryParams)
				baseUrl = baseUrl.substr(0, baseUrl.indexOf("?"));

			//Create a signature base string
			var baseString:String = method.toUpperCase() + "&" + OAuthUtil.percentEncode(baseUrl) + "&" + OAuthUtil.percentEncode(OAuthUtil.createBaseString(params));
			
			//Finally, calculate the message signature
			oauthData.oauth_signature = OAuthUtil.calculateHash(baseString, signingKey, oauthData.oauth_signature_method);
			
			//Append an OAuth header
			OperationUtil.useOAuthAuthorization(operation, oauthData);

			//Reset values
			oauthData.oauth_timestamp = 0;
			oauthData.oauth_nonce = null;
			oauthData.oauth_signature = null;
			
			return body;
		}
	}
}