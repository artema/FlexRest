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