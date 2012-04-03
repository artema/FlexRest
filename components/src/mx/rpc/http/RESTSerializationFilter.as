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
	import mx.utils.ObjectUtil;

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
			var parameters:Object = prepareParams(operation, params);
			
			if(operation.method == HTTPRequestMessage.POST_METHOD)
			{
				return parameters;
			}

			var obj:Object = new Object();
			
			if (typeof(parameters) == "object")
			{
				var classinfo:Object = ObjectUtil.getClassInfo(parameters);
				var value:Object;
				
				for each (var p:* in classinfo.properties)
				{
					value = parameters[p];
					
					if (value != null)
					{
						if (value is Array)
							obj[p] = value;
						else
							obj[p] = value.toString();
					}
				}
			}
			else
			{
				obj = parameters;
			}
			
			try
			{
				if(operation.method != HTTPRequestMessage.GET_METHOD && operation.method != HTTPRequestMessage.POST_METHOD)
				{
					obj["_method"] = operation.method
				}
			}
			catch(e:Error)
			{
				throw new Error("Invalid request object.");
			}
			
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
		
		//--------------------------------------------------------------------------
		//
		//  Helper methods
		//
		//--------------------------------------------------------------------------
		
		static private function prepareParams(operation:AbstractOperation, args:Array):Object
		{
			var params:Object = args;
			
			if(!params || (params.length == 0 && operation.request))
				params = operation.request;
			
			if(params is Array && operation.argumentNames != null)
			{
				args = params as Array;
				
				if(args.length != operation.argumentNames.length)
				{
					throw new ArgumentError("Operation called with " + operation.argumentNames.length + " argumentNames and " + args.length + " number of parameters." + 
						" When argumentNames is specified, it must match the number of arguments passed to the invocation");
				}
				else
				{
					if (operation.argumentNames.length == 1 && operation.contentType == HTTPRequestMessage.CONTENT_TYPE_XML)
					{
						params = args[0];
					}
					else
					{
						for(var i:int = 0; i < operation.argumentNames.length; i++)
							params[operation.argumentNames[i]] = args[i];
					}
				}
			}
			else if (args.length == 1) 
				params = args[0];
			else if (args.length != 0)
				throw new ArgumentError("You must set argumentNames to an array of parameter names if you use more than one parameter.");

			return params;
		}
	}
}