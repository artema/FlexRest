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
	import flash.xml.*;
	
	import mx.rpc.xml.*;
	import mx.utils.*;
	
	/**
	 * XML <code>SerializationFilter</code>.
	 * @author Artem Abashev
	 */
	public class XMLSerializationFilter extends TypedSerializationFilter
	{
		/**
		 * Function used to encode a service request as XML.
		 */
		public var xmlEncode:Function;
		
		/**
		 * Function used to decode a service result from XML.
		 */
		public var xmlDecode:Function;
		
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
			var tmp:XMLDocument = new XMLDocument();
			tmp.ignoreWhite = true;
			
			try
			{
				XMLDocument(tmp).parseXML(data);
			}
			catch(e:Error)
			{
				throw new Error();
			}
			
			var decoded:Object;

			if (xmlDecode != null)
			{
				decoded = xmlDecode(data);
				
				if (decoded == null)
					throw new Error();
			}
			else
			{
				var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
				
				decoded = decoder.decodeXML(tmp.firstChild);
				
				if (decoded == null)
					throw new Error();
			}
			
			return decoded;
		}
		
		override protected function serialize(object:Object):String
		{
			if (object is String && xmlEncode == null)
			{
				return String(object);
			}
			else if (!(object is XMLNode) && !(object is XML))
			{
				if (xmlEncode != null)
				{
					var encoded:* = xmlEncode(object);
					
					if (encoded == null)
					{
						throw new Error();
					}
					else if (!(encoded is XMLNode))
					{
						throw new Error();
					}

					return XMLNode(encoded).toString();
				}
				else
				{
					var encoder:SimpleXMLEncoder = new SimpleXMLEncoder(null);                    
					var xmlDoc:XMLDocument = new XMLDocument();
					var childNodes:Array = encoder.encodeValue(object, new QName(null, "encoded"), new XMLNode(1, "top")).childNodes.concat();                    
					
					for(var i:uint=0; i<childNodes.length; i++)
						xmlDoc.appendChild(childNodes[i]);
					
					return xmlDoc.toString();
				}
			}

			return XML(object).toXMLString();
		}
	}
}