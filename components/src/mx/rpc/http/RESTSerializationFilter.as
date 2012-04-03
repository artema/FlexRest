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
	import mx.messaging.messages.HTTPRequestMessage;

	/**
	 * REST <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	public class RESTSerializationFilter extends SerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Request content type.
		 */
		public var requestContentType:String;
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			if(operation.method != HTTPRequestMessage.GET_METHOD && operation.method != HTTPRequestMessage.POST_METHOD)
			{
				if(operation.argumentNames == null)
					operation.argumentNames = [];
				
				if(params == null)
					params = [];
				
				if(operation.argumentNames.indexOf("_method") == -1)
				{
					operation.argumentNames.push("_method");
					params.push(operation.method);
				}
			}
			
			return super.serializeParameters(operation, params);
		}
		
		override public function serializeURL(operation:AbstractOperation, obj:Object, url:String):String
		{
			if(operation.properties == null) return url;
			
			for(var p:String in operation.properties)
			{
				var value:String = operation.properties[p].toString();
				
				url = url.replace("[" + p + "]", value);
			}
			
			return url;
		}
		
		override public function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String
		{
			contentType = requestContentType != null 
				? requestContentType
				: contentType;
			
			operation.contentType = contentType;
			return contentType;
		}
	}
}