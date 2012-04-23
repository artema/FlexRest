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
			
			_fieldArrays = _fields.(@type == "Array");
			_propertyArrays = _properties.(@type == "Array");
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
		
		private var _propertyArrays:XMLList;
		
		private var _fieldArrays:XMLList;
		
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
			var node:XML, match:XML;
			
			for each(node in _fieldArrays)
			{
				if(node.@name != property) continue;
				match = node;	
			}
			
			if(match == null)
			{
				for each(node in _propertyArrays)
				{
					if(node.@name != property) continue;
					match = node;	
				}
			}
			
			if(match == null)
				return null;

			var typeNode:XML = match.metadata.(@name == "ArrayElementType")[0];
			
			if(typeNode == null) return null;
			
			var type:String = typeNode.arg.(@key == "").@value;
			
			if(type == "") 
				type = typeNode.arg.(@key == "elementType").@value;
			
			if(type == "" || type == null) return null;

			return Class(getDefinitionByName(type));
		}
	}
}