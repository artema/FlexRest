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
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.core.mx_internal;
	import mx.utils.*;
	
	use namespace mx_internal;

	/**
	 * Abstract typed <code>SerializationFilter</code>. Methods that must be implemented in a child class:
	 * <code>createRequestObject</code>, <code>serialize</code>, <code>deserialize</code>, <code>createResultObject</code>.
	 * @author Artem Abashev
	 */
	public class TypedSerializationFilter extends SerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		final override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			if(result == null) return null;
			
			//No need to deserialize the result, it will be processed by the operation itself
			if(result == null || !(result is String) || (StringUtil.trim(String(result)) == "") ||
				(operation.resultFormat != null && (
					operation.resultFormat != AbstractOperation.RESULT_FORMAT_ARRAY &&
					operation.resultFormat != AbstractOperation.RESULT_FORMAT_OBJECT)
				)
			)
			{
				return result;
			}
			
			var rawObject:Object = deserialize(String(result));
			
			//Result is untyped
			if(operation.resultElementType == null)
			{
				if(operation.makeObjectsBindable)
				{
					if(rawObject is Array)
					{
						rawObject = new ArrayCollection(rawObject as Array);
					}
					else if(getQualifiedClassName(rawObject) == "Object")
					{
						rawObject = new ObjectProxy(rawObject);
					}
				}

				return rawObject;
			}
			
			//An array of typed objects
			if(rawObject is Array)
			{
				var resultArray:Array = [];
				
				for each(var element:Object in rawObject)
				{
					resultArray.push(createResultObject(element, operation.resultElementType));
				}
				
				if(operation.makeObjectsBindable)
				{
					return new ArrayCollection(resultArray);
				}
				
				return resultArray;
			}
			
			//A typed object
			return createResultObject(rawObject, operation.resultElementType);
		}
		
		final override public function serializeBody(operation:AbstractOperation, obj:Object):Object
		{
			if(obj == null || 
				(operation.contentType == AbstractOperation.CONTENT_TYPE_FORM || 
				operation.contentType == AbstractOperation.CONTENT_TYPE_XML)
			)
			{
				return super.serializeBody(operation, obj);
			}
			
			var request:Object = createRequestObject(obj);
			
			return serialize(request);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Abstract methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Create a request object. This method is typically used to remove properties
		 * that are marked with a Transient metatag.
		 * @param requestObject Base request object.
		 */
		protected function createRequestObject(requestObject:Object):Object
		{
			throw new Error("Method is not implemented.");
			return null;
		}
		
		/**
		 * Serialize request object.
		 */
		protected function serialize(object:Object):String
		{
			throw new Error("Method is not implemented.");
			return null;
		}
		
		/**
		 * Deserialize result object.
		 */
		protected function deserialize(data:String):Object
		{
			throw new Error("Method is not implemented.");
			return null;
		}
		
		/**
		 * Create a typed result object from a raw object passed over the wire.
		 * @param untypedObject Raw untyped object.
		 * @param resultType Type to cast an untyped object to.
		 */
		protected function createResultObject(untypedObject:Object, resultType:Class):Object
		{
			throw new Error("Method is not implemented.");
			return null;
		}
	}
}