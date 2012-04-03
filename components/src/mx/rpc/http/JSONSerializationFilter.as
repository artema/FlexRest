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
		
		override public function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String
		{
			operation.contentType = CONTENT_TYPE_JSON;
			return CONTENT_TYPE_JSON;
		}
	}
}