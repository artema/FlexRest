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
	/**
	 * Composite <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	public class CompositeSerializationFilter extends SerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var contentTypeProvider:SerializationFilter;

		public var resultDeserializer:SerializationFilter;
		
		[ArrayElementType("mx.rpc.http.SerializationFilter")]
		public var resultDeserializers:Array;
		
		public var parametersSerializer:SerializationFilter;

		public var bodySerializer:SerializationFilter;
		
		[ArrayElementType("mx.rpc.http.SerializationFilter")]
		public var bodySerializers:Array;
		
		public var urlSerializer:SerializationFilter;

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			if (resultDeserializers != null && resultDeserializers.length > 0)
			{
				for each (var filter:SerializationFilter in resultDeserializers)
					result = filter.deserializeResult(operation, result);
				
				return result;
			}
			
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
			if (bodySerializers != null && bodySerializers.length > 0)
			{
				for each (var filter:SerializationFilter in bodySerializers)
					obj = filter.serializeBody(operation, obj);
				
				return obj;
			}
			
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