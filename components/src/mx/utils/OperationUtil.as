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
	import flash.errors.IllegalOperationError;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.OAuthHeader;

	/**
	 * <code>AbstractOperation</code> utility.
	 * @author Artem Abashev
	 */
	final public class OperationUtil
	{
		/**
		 * @private
		 */
		public function OperationUtil(){ throw new IllegalOperationError(); }
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Apply basic HTTP Authorization header to the operation.
		 * Note that all HTTP headers are stripped in GET requests,
		 * so you should also apply a <code>RESTSerializationFilter</code> as
		 * a <code>urlSerializer</code> to your service so that it will override your
		 * GET requests by appending a _method=GET variable to a request URL.
		 * 
		 * @param operation Operation to apply an authorization header to.
		 * @param username Username.
		 * @param password Password.
		 */
		static public function useBasicHttpAuthorization(operation:mx.rpc.AbstractOperation, username:String, password:String):void
		{
			if(operation == null) throw new ArgumentError("operation");
			var httpOperation:mx.rpc.http.AbstractOperation = operation as mx.rpc.http.AbstractOperation;
			
			if(httpOperation == null) throw new ArgumentError("Operation is not an HTTP operation.");			
			if(username == null) throw new ArgumentError("username");
			if(password == null) throw new ArgumentError("password");
			
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.insertNewLines = false;
			encoder.encode(username + ":" + password);

			if(httpOperation.headers == null) httpOperation.headers = {};				
			httpOperation.headers["Authorization"] = "Basic " + encoder.toString();
		}
		
		/**
		 * Apply OAuth HTTP Authorization header to the operation.
		 * Note that all HTTP headers are stripped in GET requests,
		 * so you should also apply a <code>RESTSerializationFilter</code> as
		 * a <code>urlSerializer</code> to your service so that it will override your
		 * GET requests by appending a _method=GET variable to a request URL.
		 * 
		 * @param operation Operation to apply an OAuth authorization header to.
		 * @param username Username.
		 * @param password Password.
		 */
		static public function useOAuthAuthorization(operation:mx.rpc.AbstractOperation, header:OAuthHeader):void
		{
			if(operation == null) throw new ArgumentError("operation");
			var httpOperation:mx.rpc.http.AbstractOperation = operation as mx.rpc.http.AbstractOperation;
			
			if(httpOperation == null) throw new ArgumentError("Operation is not an HTTP operation.");			
			if(header == null) throw new ArgumentError("header");

			var pairs:Vector.<String> = new Vector.<String>();
			var value:Object;			
			
			for(var p:String in header)
			{
				value = header[p] || "";
				value = escape(value.toString());
				p = escape(p);
				
				pairs.push(p + '="' + value + '"');
			}
			
			if(pairs.length == 0) return;
			
			if(httpOperation.headers == null) httpOperation.headers = {};
			httpOperation.headers["Authorization"] = "OAuth " + pairs.join(", ");
		}
	}
}