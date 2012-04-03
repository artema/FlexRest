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
	SETUP::LEGACY
	{
	import com.adobe.serialization.json.JSON;
	}
	
	use namespace AS3;	
	
	import flash.errors.IllegalOperationError;

	/**
	 * JSON utility.
	 * @author Artem Abashev
	 */
	final public class JSONUtil
	{
		/**
		 * @private
		 */
		public function JSONUtil(){ throw new IllegalOperationError(); }
		
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * RegEx pattern of a JSON date string.
		 */
		static private const jsonDatePattern:RegExp = /^\/Date\((-?\d+)(([-+])(\d{4}+))?\)\/$/;
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Deserialize a JSON string into an object.
		 * @throws ArgumentError <code>null</code> argument passed.
		 * @throws SyntaxError Unable to deserialize a string.
		 */
		static public function deserialize(data:String):Object
		{
			if(data == null) throw new ArgumentError("String cannot be null.");
			
			try
			{
				SETUP::LEGACY
				{
					return com.adobe.serialization.json.JSON.decode(data);
				}
	
				SETUP::MODERN
				{
					return JSON.parse(data);
				}
			}
			catch(e:Error)
			{
				throw new SyntaxError("Unable to deserialize a string.");
			}
			
			return null;
		}
		
		/**
		 * Serialize an object into a JSON string.
		 * @throws ArgumentError <code>null</code> argument passed.
		 * @throws Error Unable to serialize an object.
		 */
		static public function serialize(object:Object):String
		{
			if(object == null) throw new ArgumentError("Object cannot be null.");
			
			try
			{
				SETUP::LEGACY
				{
					return com.adobe.serialization.json.JSON.encode(object);
				}
				
				SETUP::MODERN
				{
					return JSON.stringify(object);
				}
			}
			catch(e:Error)
			{throw e;
				throw new Error("Unable to serialize an object.");
			}
			
			return null; 
		}
		
		/**
		 * Parse a date string in JSON format.
		 * Returns <code>null</code> if parsing was not successful.
		 * @throws ArgumentError <code>null</code> reference argument.
		 */
		static public function parseDate(dateString:String):Date
		{
			if(dateString == null) throw new ArgumentError("dateString cannot be null");
			
			var matches:Array = dateString.match(jsonDatePattern);
			
			if(matches == null) return null;
			
			var time:Number = parseFloat(String(matches[1]));

			return new Date(time);
		}
		
		/**
		 * Serialize a date into a JSON date string form.
		 * @throws ArgumentError <code>null</code> reference argument.
		 */
		static public function serializeDate(date:Date):String
		{
			if(date == null) throw new ArgumentError("date cannot be null");
			
			return "/Date(" + date.time + ")/";
		}
	}
}