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
	import mx.utils.OperationUtil;

	/**
	 * Basic HTTP authentication serialization filter.
	 * @author Artem Abashev
	 */
	final public class BasicAuthenticationSerializationFilter extends CompositeSerializationFilter
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Username.
		 */
		public var username:String;
		
		/**
		 * Password.
		 */
		public var password:String;
		
		//--------------------------------------------------------------------------
		//
		//  SerializationFilter methods
		//
		//--------------------------------------------------------------------------
		
		override public function serializeBody(operation:AbstractOperation, obj:Object):Object
		{
			var body:Object = super.serializeBody(operation, obj);

			if(username == null) throw new ArgumentError("Username is not provided.");
			if(password == null) throw new ArgumentError("Password is not provided.");

			OperationUtil.useBasicHttpAuthorization(operation, username, password);
			
			return body;
		}
	}
}