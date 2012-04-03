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
	import flash.errors.*;
	import flash.utils.*;

	/**
	 * Type utility.
	 * @author Artem Abashev
	 */
	final public class TypeUtil
	{
		/**
		 * @private
		 */
		public function TypeUtil(){ throw new IllegalOperationError(); }

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Create a typed object from an untyped object.
		 * @param untypedObject Untyped object.
		 * @param resultType Type to cast an untyped object to.
		 * @throws ArgumentError <code>null</code> resultType argument passed.
		 */
		static public function createTypedObject(untypedObject:Object, resultType:Class):Object
		{
			if(resultType == null) throw new ArgumentError("resultType");
			if(untypedObject == null) return null;
			
			//There is no need to proccess core types
			if(isBaseType(resultType))
			{
				//Parse date string
				if(untypedObject is String && resultType == Date)
					return parseDateString(String(untypedObject));
					
				return untypedObject;
			}
			
			//Object is an array
			if(untypedObject is Array)
			{
				//Result is a ByteArray
				if(resultType == ByteArray)
				{
					var bytes:ByteArray = new ByteArray();
					
					for each(var val:int in value)
						bytes.writeByte(val);
					
					return bytes;
				}
				//Array should be mapped to an array of complex types
				else if(!isBaseType(resultType))
				{
					var array:Array = [];
					
					for each(var item:Object in untypedObject)
						array.push(createTypedObject(item, resultType));
					
					return array;
				}
				
				//Array contains base type values
				return untypedObject;
			}
			
			var result:Object = new resultType();
			var classInfo:ClassInfo = new ClassInfo(result);
			
			for each(var p:String in classInfo.properties)
			{
				var value:Object = untypedObject[p];
				
				if(value == null) continue;

				//Check if there is a Transient metadata attribute set for this property
				if(classInfo.propertyHasAttribute(p, "Transient")) continue;
				
				var propertyType:Class = classInfo.getPropertyType(p);
				
				if(propertyType == null) continue;
				
				//Value is an array
				if(value is Array)
				{
					var propertyInfo:ClassInfo;
					
					//Byte arrays are passed over the wire as regular arrays
					if(propertyType == ByteArray)
					{
						var byteArray:ByteArray = new ByteArray();

						for each(var byte:int in value)
							byteArray.writeByte(byte);
						
						result[p] = byteArray;
					}
					//Value is a vector
					else if((propertyInfo = new ClassInfo(propertyType)).typeParameter != null)
					{
						var vector:* = new propertyType();
						var vectorElement:*;
						
						for each(element in value)
						{
							vectorElement = createTypedObject(element, propertyInfo.typeParameter);
							
							if(vectorElement is propertyInfo.typeParameter)
								vector.push(vectorElement);
						}
						
						result[p] = vector;
					}					
					//Value is a regular array
					else
					{
						//An empty array
						if(value.length == 0)
						{
							result[p] = value;
							continue;
						}
						
						var resultArray:Array;
						var element:Object;
						
						//If there is no metadata provided, 
						//there is no way to know what types of object an array has
						propertyType = null;

						//Check if there is an ArrayElementType metadata attribute available
						if(classInfo.propertyHasAttribute(p, "ArrayElementType"))
							propertyType = classInfo.getArrayElementType(p);
						
						//Array is not typed
						if(propertyType == null)
						{
							result[p] = value;
							continue;
						}
						
						//Array is an N-dimensional array
						if(propertyType is Array)
						{
							result[p] = createTypedObject(value, Object);
						}
						//Array contains objects of a complex type
						else if(!isBaseType(propertyType))
						{
							resultArray = [];
							
							for each(element in value)
								resultArray.push(createTypedObject(element, propertyType));
							
							result[p] = resultArray;
						}
						//Array contains date strings
						else if(propertyType == Date && value[0] is String)
						{
							resultArray = [];
							
							for each(element in value)
							{
								if(element is String)
									resultArray.push(parseDateString(String(element)));
							}
							
							result[p] = resultArray;
						}
						//Array contains objects of a base type
						else
						{
							resultArray = [];
							
							for each(element in value)
							{
								if(element is propertyType)
									resultArray.push(element);
							}
							
							result[p] = resultArray;
						}
					}					
				}
				else
				{
					//Value is a date string
					if(propertyType == Date && value is String)
					{
						result[p] = parseDateString(String(value));
					}
					else
					{
						result[p] = isBaseType(propertyType) ? 
							value : 
							createTypedObject(value, propertyType);
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Create an object that can be used in RPC operations.
		 * @param regularObject Provider object.
		 */
		static public function createRequestObject(regularObject:Object):Object
		{
			if(regularObject == null) return null;			
			if(isBaseTypeObject(regularObject)) return regularObject;
			
			var classInfo:ClassInfo = new ClassInfo(regularObject);
			var propertyInfo:ClassInfo;
			var result:Object = new Object();
			var value:Object;
			var element:Object;
			
			for each(var p:String in classInfo.properties)
			{
				//Check if there is a Transient metadata attribute set for this property
				if(classInfo.propertyHasAttribute(p, "Transient")) continue;

				value = regularObject[p];				
				
				if(value == null)
				{
					result[p] = null;
					continue;
				}
				
				//Property is an array or a vector
				if(value is Array || (propertyInfo = new ClassInfo(value)).typeParameter != null)
				{
					var array:Array = [];
					
					for each(element in value)
						array.push(createRequestObject(element));
					
					result[p] = array;
				}
				//Property has complex type
				else if(!isBaseTypeObject(value))
				{
					result[p] = createRequestObject(value);
				}
				//Property has a base type
				else
				{
					result[p] = value;
				}
			}
			
			return result;
		}
		
		//-----------------------------------------------
		//    Base types
		//-----------------------------------------------

		/**
		 * Checks if an object's type is a primitive or a core type.
		 * @throws ArgumentError <code>null</code> argument passed.
		 */
		static public function isBaseTypeObject(object:Object):Boolean
		{
			if(object == null) throw new ArgumentError("Object cannot be null");

			switch (typeof(object))
			{
				case "number":
				case "string":
				case "boolean":
				case "function":
				case "xml":
				{
					return true;
				}
					
				case "object":
				{
					var className:String = getQualifiedClassName(object);
					
					return (className == "Object") ||
						(className == "Array") || 
						(className == "Date") ||
						(className == "Error") || 
						(className == "RegExp");
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if a type is a primitive or a core type.
		 * @throws ArgumentError <code>null</code> argument passed.
		 */
		static public function isBaseType(type:Class):Boolean
		{
			if(type == null) throw new ArgumentError("Type cannot be null");
			
			switch(type)
			{			
				case Object:
				case int:
				case uint:
				case Boolean:
				case Number:
				case String:
				case Array:
				case Date:
				case Error:
				case Function:
				case RegExp:
				case XML:
				case XMLList:
					return true;
			}

			return false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Parse a date string. 
		 * Returns <code>null</code> if parsing was not successful.
		 */
		static private function parseDateString(dateString:String):Date
		{
			if(dateString == null) return null;
			
			var result:Date;
			var value:Number;
			
			//Actionscript date
			if(!isNaN(value = Date.parse(dateString)))
			{
				return new Date(value);
			}
			//JSON date
			else if((result = JSONUtil.parseDate(dateString)) != null)
			{
				return result;
			}
			
			return null;
		}
	}
}