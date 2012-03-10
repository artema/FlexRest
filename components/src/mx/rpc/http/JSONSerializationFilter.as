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
	import mx.utils.*;

	/**
	 * JSON <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	public class JSONSerializationFilter extends TypedSerializationFilter
	{
		/**
		 * Indicates that the data is encoded as application/json.
		 */
		static public const CONTENT_TYPE_JSON:String = "application/json";
		
		//--------------------------------------------------------------------------
		//
		//  Abstract methods implementation
		//
		//--------------------------------------------------------------------------
		
		override protected function createRequestObject(requestObject:Object):Object
		{
			return TypeUtil.createRequestObject(requestObject);
		}
		
		override protected function createResultObject(untypedObject:Object, resultType:Class):Object
		{
			return TypeUtil.createTypedObject(untypedObject, resultType);
		}
		
		override protected function deserialize(data:String):Object
		{
			return JSONUtil.deserialize(data);
		}

		override protected function serialize(object:Object):String
		{
			return JSONUtil.serialize(object);
		}
	}
}