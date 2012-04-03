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
package mx.rpc
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 * Asynchronous operation responder.
	 * 
	 * <p>Mimics Flex's <code>AsyncResponder</code> class, but with a different result/fault functions signatures.</p>
	 * 
	 * <p>Valid result handler signature: <code>function(valueObject:Object):void</code>.
	 * A result handler function will receive <code>ResultEvent</code>'s <code>result</code> value,
	 * so you can just set your result type in a handler: <code>function(valueObject:MyResultClass):void</code>.</p>
	 * 
	 * <p>Valid fault handler signature: <code>function(fault:Fault):void</code>.</p>
	 * 
	 * @author Artem Abashev
	 */
	final public class OperationResponder implements IResponder
	{
		/**
		 * Constructor.
		 * @param result Operation result handler.
		 * @param fault Operation fault handler.
		 */
		public function OperationResponder(result:Function=null, fault:Function=null)
		{
			_resultHandler = result;
			_faultHandler = fault;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Data
		//
		//--------------------------------------------------------------------------
		
		private var _resultHandler:Function;
		
		private var _faultHandler:Function;
		
		//--------------------------------------------------------------------------
		//
		//  IResponder implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function result(data:Object):void
		{
			try
			{
				if(_resultHandler != null) _resultHandler(ResultEvent(data).result);
			}
			catch(e:Error)
			{
				if(_faultHandler != null) 
				{
					_faultHandler(new Fault(
						"ResultHandlerError", 
						"Error calling result handler.",
						"Error calling result handler. Check if your handler function has a valid signature."
					));
				}
			}
			finally
			{
				_resultHandler = null;
				_faultHandler = null;
			}
		}
		
		/**
		 * @private
		 */
		public function fault(info:Object):void
		{
			try
			{
				if(_faultHandler != null) _faultHandler(FaultEvent(info).fault);
			}
			finally
			{
				_resultHandler = null;
				_faultHandler = null;
			}
		}
	}
}