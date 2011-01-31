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

package com.falanxia.emitor {
	import com.falanxia.emitor.interfaces.IAssetProvider;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;



	/**
	 * Asset collection holds assets.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura / Falanxia a.s.
	 */
	public class AssetCollection extends EventDispatcher {


		private var _provider:IAssetProvider;
		private var _id:String;



		/**
		 * Create an instance of AssetCollection and attach a Provider.
		 * @param id AssetCollection ID
		 * @param provider Provider to be attached
		 * @see IAssetProvider
		 */
		public function AssetCollection(id:String, provider:IAssetProvider) {
			_id = id;
			_provider = provider;
		}



		/**
		 * Destructor.
		 */
		public function destroy():void {
			_provider.destroy();
			_id = null;
		}



		/**
		 * Get an Asset.
		 * @param id Asset ID
		 * @return Asset (if defined, null if not)
		 * @throws Error if Asset provider not attached
		 */
		public function getAsset(id:String):Asset {
			if(_provider == null) {
				throw new Error("Asset provider not attached");
			}

			return _provider.assetsDictionary[id];
		}



		/**
		 * Generate AssetCollection description.
		 * @return AssetCollection description
		 */
		override public function toString():String {
			var out:String;

			if(_provider == null) {
				out = "AssetCollection: Provider not attached";
			}

			else {
				// create list of assets
				var list:String = "";
				var i:Asset;

				for each(i in _provider.assetsDictionary) {
					list += i.id + ", ";
				}

				// strip trailing ", "
				list = list.substr(0, list.length - 2);

				var ps:String = _provider.toString();

				out = "AssetCollection:\n  provider=" + ps + "\n  registered assets: " + list;
			}

			return out;
		}



		/**
		 * Get AssetCollection ID.
		 * @return AssetCollection ID
		 */
		public function get id():String {
			return _id;
		}



		/**
		 * Get pointer to Asset provider.
		 * @return Asset provider (if attached, null if not)
		 * @see IAssetProvider
		 */
		public function get provider():IAssetProvider {
			return _provider;
		}



		/**
		 * Has an Error happened?
		 * @return Error happened flag
		 */
		public function get isError():Boolean {
			return (_provider == null) ? false : _provider.isError;
		}



		/**
		 * Is AssetCollection active?
		 * @return AssetCollection active flag
		 */
		public function get isActive():Boolean {
			return (_provider == null) ? false : _provider.isActive;
		}



		/**
		 * Is everything loaded?
		 * @return Loaded flag
		 */
		public function get isLoaded():Boolean {
			return (_provider == null) ? false : _provider.isLoaded;
		}



		/**
		 * Get Dictionary of Assets.
		 * @return Dictionary of assets as Array
		 * @throws Error if Asset provider not attached
		 */
		public function get assetsDictionary():Dictionary {
			if(_provider == null) {
				throw new Error("Asset provider not attached");
			}

			else {
				// return asset list
				return _provider.assetsDictionary;
			}
		}
	}
}
