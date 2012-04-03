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
	import flash.events.Event;
	
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 * REST <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	public class RESTSerializationFilter extends SerializationFilter
	{
		/**
		 * Indicates that the data is encoded as application/json.
		 */
		static public const CONTENT_TYPE_JSON:String = "application/json";
		
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
			if(operation.method == HTTPRequestMessage.POST_METHOD)
			{
				if(params.length > 1) return params;
				else if(params.length == 1) return params[0];
			}
			
			if(operation.argumentNames == null)
				operation.argumentNames = [];			
			
			var parameters:Array = [];

			if(params.length > 0 && typeof(params[0]) == "object")
			{
				var object:Object = params[0];
				
				for(var p:String in object)
				{
					operation.argumentNames.push(p);
					parameters.push(object[p]);
				}
			}

			if(operation.method != HTTPRequestMessage.GET_METHOD && operation.method != HTTPRequestMessage.POST_METHOD)
			{
				operation.argumentNames.push("_method");
				parameters.push(operation.method);
			}
			
			var obj:Object = new Object();
			for (var i:int = 0; i < operation.argumentNames.length && i < parameters.length; i++)
				obj[operation.argumentNames[i]] = parameters[i];
			
			return obj;
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
			if(operation.method != HTTPRequestMessage.GET_METHOD && operation.method != HTTPRequestMessage.POST_METHOD)
			{		
				operation.contentType = HTTPRequestMessage.CONTENT_TYPE_FORM;
				
				var method:String = operation.method;
				
				var result:Function = function(e:Event):void
				{
					operation.method = method;
					operation.removeEventListener(ResultEvent.RESULT, arguments.callee);
				}
					
				var fault:Function = function(e:Event):void
				{
					operation.method = method;
					operation.removeEventListener(FaultEvent.FAULT, arguments.callee);
				}
				
				operation.addEventListener(ResultEvent.RESULT, result);				
				operation.addEventListener(FaultEvent.FAULT, fault);
				
				operation.method = HTTPRequestMessage.POST_METHOD;
				return HTTPRequestMessage.CONTENT_TYPE_FORM;
			}
			
			contentType = requestContentType != null 
				? requestContentType
				: contentType;
			
			operation.contentType = contentType;
			return contentType;
		}
	}
}