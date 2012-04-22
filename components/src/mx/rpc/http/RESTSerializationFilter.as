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
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.Base64Encoder;
	import mx.utils.JSONUtil;
	import mx.utils.ObjectUtil;
	import mx.utils.URLUtil;

	/**
	 * REST <code>SerializationFilter</code>. Can be used as <code>contentTypeProvider</code>,
	 * <code>parametersSerializer</code> and <code>urlSerializer</code>
	 * @author Artem Abashev
	 */
	public class RESTSerializationFilter extends SerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Override HTTP method using a X-HTTP-Method-Override header.
		 */
		static public const METHOD_OVERRIDE_HEADER:String = "header";
		
		/**
		 * Override HTTP method using a _method URL variable.
		 */
		static public const METHOD_OVERRIDE_URL:String = "url";
		
		/**
		 * Override HTTP method using a _method variable passed
		 * in a application/x-www-form-urlencoded request.
		 */
		static public const METHOD_OVERRIDE_VARIABLE:String = "variable";
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Custom request content type to use.
		 */
		public var requestContentType:String;

		[Inspectable(enumeration="header,url,variable", defaultValue="header", category="General")]
		/**
		 * HTTP method override type. Valid values are <code>header</code>, <code>url</code> and <code>variable</code>.
		 * The default value is <code>header</code>.
		 */
		public var methodOverride:String = "header";
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Validates and serializes parameters passed to the operation.
		 */
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			//Proccess and validate operation arguments and argument names
			var parameters:Object = prepareParams(operation, params);
			var obj:Object = new Object();
			var type:String = typeof(parameters);
			
			if(parameters is Array)
			{
				obj = parameters;
			}
			//Read properties from a typed object
			else if (type == "object")
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
						else if (value is Date)
							obj[p] = JSONUtil.serializeDate(value as Date);
						else
							obj[p] = value.toString();
					}
				}
			}
			else
			{
				obj = parameters;
			}

			var intendedMethod:String = getIntendedMethod(operation);
			
			if(intendedMethod != null && methodOverride == METHOD_OVERRIDE_VARIABLE)
			{
				obj["_method"] = intendedMethod;
			}

			return obj;
		}
		
		/**
		 * Overrides custom HTTP verbs by appending a _method variable to URLs 
		 * and replaces square bracket tokens in URLs with user-defined arguments.
		 * HTTP GET requests are overriden too if there are headers applied to the operation,
		 * since Flash Player strips all headers from GET requests.
		 */
		override public function serializeURL(operation:AbstractOperation, obj:Object, url:String):String
		{
			var p:String;
			var intendedMethod:String = getIntendedMethod(operation);

			if(operation.properties == null && intendedMethod == null) return url;
			
			//Replace URL tokens with user-defined values
			if(operation.properties != null)
			{
				for(p in operation.properties)
				{
					var value:String = operation.properties[p].toString();				
					url = url.replace("[" + p + "]", value);
				}
			}
			
			//Override request method by adding a _method variable to the URL
			if(intendedMethod != null)
			{
				switch(methodOverride)
				{
					case METHOD_OVERRIDE_HEADER:
						operation.headers["X-HTTP-Method-Override"] = intendedMethod;
						break;
						
					case METHOD_OVERRIDE_URL:
						url = appendToUrl(url, "_method=" + intendedMethod);
						break;
				}
				
				overrideRequestMethod(operation);
			}
			
			return url;
		}
		
		/**
		 * Allows to use a custom request content type.
		 */
		override public function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String
		{
			if(methodOverride == METHOD_OVERRIDE_VARIABLE && obj.hasOwnProperty("_method"))
				return HTTPRequestMessage.CONTENT_TYPE_FORM;
			
			//Override request content type with a user-defined value
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
		
		static private function getIntendedMethod(operation:AbstractOperation):String
		{
			//Override request method for custom HTTP verbs
			if(operation.method != HTTPRequestMessage.GET_METHOD && operation.method != HTTPRequestMessage.POST_METHOD)
			{
				return operation.method;
			}
			//All HTTP headers are stripped in GET requests, so we should use POST instead
			else if(operation.method == HTTPRequestMessage.GET_METHOD)
			{
				for(var p:String in operation.headers)
				{
					//Headers object contains at least one value
					return HTTPRequestMessage.GET_METHOD;
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 * Override request method for the operation and switch it back
		 * after the operation is complete.
		 * @param operation Operation to alter.
		 * @param method Request method to set for the current request.
		 */
		static private function overrideRequestMethod(operation:AbstractOperation):void
		{
			var oldMethod:String = operation.method;
			
			if(oldMethod == HTTPRequestMessage.POST_METHOD) return;
			
			var result:Function = function(e:Event):void
			{
				operation.method = oldMethod;
				operation.removeEventListener(ResultEvent.RESULT, arguments.callee);
			}
			
			var fault:Function = function(e:Event):void
			{
				operation.method = oldMethod;
				operation.removeEventListener(FaultEvent.FAULT, arguments.callee);
			}
			
			operation.addEventListener(ResultEvent.RESULT, result);				
			operation.addEventListener(FaultEvent.FAULT, fault);
			
			operation.method = HTTPRequestMessage.POST_METHOD;
		}

		/**
		 * @private
		 * Append a key-value pair to the URL.
		 * @param URL to append to.
		 * @param pair String to append to the URL.
		 * @returns New URL.
		 */
		static private function appendToUrl(url:String, pair:String):String
		{
			var urlDelimiter:String = (url.indexOf("?") != -1) ? "&" : "?";				
			return url + urlDelimiter + pair;
		}
		
		/**
		 * @private
		 * Proccess and validate operation arguments and argument names.
		 */
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