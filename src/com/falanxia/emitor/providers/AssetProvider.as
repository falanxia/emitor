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

package com.falanxia.emitor.providers {
	import com.falanxia.emitor.Asset;
	import com.falanxia.emitor.interfaces.IAssetProvider;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;



	/**
	 * Asset Provider template.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * @since 1.0
	 * @see Asset
	 */
	public class AssetProvider extends EventDispatcher implements IAssetProvider {


		/** Assets dictionary */
		protected var _assetsDictionary:Dictionary;

		/** Error flag */
		protected var _isError:Boolean;

		/** Active flag */
		protected var _isActive:Boolean;

		/** Loaded flag */
		protected var _isLoaded:Boolean;



		/**
		 * Constructor.
		 */
		public function AssetProvider() {
			_assetsDictionary = new Dictionary();
		}



		/**
		 * Destructor.
		 */
		public function destroy():void {
			var asset:Asset;

			if(_isActive) {
				_isActive = false;
				_isLoaded = false;
			}

			for each(asset in _assetsDictionary) {
				asset.destroy();
			}

			_assetsDictionary = null;
		}



		/**
		 * Dispose source from memory.
		 */
		public function dispose():void {
		}



		/**
		 * Get Dictionary of Assets as Array.
		 * @return Dictionary of Assets
		 */
		public function get assetsDictionary():Dictionary {
			return _assetsDictionary;
		}



		/**
		 * Has an error happened?
		 * @return Error flag
		 */
		public function get isError():Boolean {
			return _isError;
		}



		/**
		 * Is Provider active?
		 * @return Provider active flag
		 */
		public function get isActive():Boolean {
			return _isActive;
		}



		/**
		 * Is Provider fully loaded?
		 * @return Provider loaded flag
		 */
		public function get isLoaded():Boolean {
			return _isLoaded;
		}
	}
}
