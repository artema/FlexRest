/*
* The MIT License
*
* Copyright (c) 2012
* Artem Abashev
* http://abashev.me/
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
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