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
	/**
	 * Composite <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	final public class CompositeSerializationFilter extends SerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var contentTypeProvider:SerializationFilter;
		
		public var resultDeserializer:SerializationFilter;
		
		public var parametersSerializer:SerializationFilter;
		
		public var bodySerializer:SerializationFilter;
		
		public var urlSerializer:SerializationFilter;
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			return (resultDeserializer != null) ? 
				resultDeserializer.deserializeResult(operation, result) : 
				super.deserializeResult(operation, result);
		}
		
		override public function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String
		{
			return (contentTypeProvider != null) ? 
				contentTypeProvider.getRequestContentType(operation, obj, contentType) : 
				super.getRequestContentType(operation, obj, contentType);
		}
		
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			return (parametersSerializer != null) ? 
				parametersSerializer.serializeParameters(operation, params) : 
				super.serializeParameters(operation, params);
		}
		
		override public function serializeBody(operation:AbstractOperation, obj:Object):Object
		{
			return (bodySerializer != null) ? 
				bodySerializer.serializeBody(operation, obj) : 
				super.serializeBody(operation, obj);
		}
		
		override public function serializeURL(operation:AbstractOperation, obj:Object, url:String):String
		{
			return (urlSerializer != null) ? 
				urlSerializer.serializeURL(operation, obj, url) : 
				super.serializeURL(operation, obj, url);
		}
	}
}