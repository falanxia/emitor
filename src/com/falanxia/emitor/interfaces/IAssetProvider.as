/*
 * Falanxia Emitor.
 *
 * Copyright (c) 2011 Falanxia (http://falanxia.com)
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

package com.falanxia.emitor.interfaces {
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;



	/**
	 * AssetProvider interface.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura / Falanxia a.s.
	 * @since 1.0
	 */
	public interface IAssetProvider extends IEventDispatcher {


		/**
		 * Destructor.
		 */
		function destroy():void;



		/**
		 * Generate description.
		 * @return Description
		 */
		function toString():String;



		/**
		 * Dispose source from memory.
		 */
		function dispose():void;



		/**
		 * Get Dictionary of Assets as Array.
		 * @return Dictionary of Assets
		 */
		function get assetsDictionary():Dictionary;



		/**
		 * Is Provider active?
		 * @return Provider active flag
		 */
		function get isActive():Boolean;



		/**
		 * Is Provider fully loaded?
		 * @return Provider loaded flag
		 */
		function get isLoaded():Boolean;



		/**
		 * Has an error happened?
		 * @return Error flag
		 */
		function get isError():Boolean;


	}
}
