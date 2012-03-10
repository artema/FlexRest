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
package mx.utils
{
	import flash.utils.*;

	/**
	 * Reflection helper.
	 * @author Artem Abashev
	 */
	final internal class ClassInfo
	{
		public function ClassInfo(value:*)
		{
			var raw:XML = describeType(value);
			
			_type = raw.@name;
			
			if(typeName.indexOf(VECTOR_TYPE) == 0)
			{
				var typeParam:String = typeName.substr(VECTOR_TYPE.length + 2, typeName.length - VECTOR_TYPE.length - 3);				
				_typeParameter = Class(getDefinitionByName(typeParam));
			}
		
			_fields = raw.variable;
			_properties = raw.accessor.(@access == "readwrite");
			
			_arrays = _fields.(@type == "Array");
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		static private const VECTOR_TYPE:String = "__AS3__.vec::Vector";
		
		//--------------------------------------------------------------------------
		//
		//  Data
		//
		//--------------------------------------------------------------------------

		private var _type:String;
		
		private var _typeParameter:Class;
		
		private var _fields:XMLList;
		
		private var _properties:XMLList;

		private var _propertiesNames:Array;
		
		private var _arrays:XMLList;
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		public function get typeName():String{ return _type; }
		
		public function get typeParameter():Class{ return _typeParameter; }
		
		public function get properties():Array
		{
			if(_propertiesNames == null)
			{
				_propertiesNames = [];
				var name:String;
				
				for each(name in _fields.@name)
					_propertiesNames.push(name);

				for each(name in _properties.@name)
					_propertiesNames.push(name);
			}
			
			return _propertiesNames;
		}
		
		public function getPropertyType(property:String):Class
		{
			var className:String = _fields.(@name == property).@type || _properties.(@name == property).@type;
			
			if(className == "") return null;
			
			return Class(getDefinitionByName(className));
		}
		
		public function propertyHasAttribute(property:String, attribute:String):Boolean
		{
			var node:XML;
			
			for each(node in _fields.(@name == property).metadata)
				if(node.@name == attribute) return true;
			
			for each(node in _properties.(@name == property).metadata)
				if(node.@name == attribute) return true;

			return false;
		}
		
		public function getArrayElementType(property:String):Class
		{
			var typeNode:XML;
			var type:String;
			
			for each(var node:XML in _arrays)
			{
				if(node.@name != property) continue;
				
				typeNode = node.metadata.(@name == "ArrayElementType")[0];
				
				if(typeNode == null) return null;
				
				type = typeNode.arg.(@key == "").@value;
				
				if(type == "") 
					type = typeNode.arg.(@key == "elementType").@value;
				
				if(type == "") return null;
			}

			return Class(getDefinitionByName(type));
		}
	}
}