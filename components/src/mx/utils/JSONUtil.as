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