/*
 * Falanxia Emitor.
 *
 * Copyright (c) 2010 Falanxia (http://falanxia.com)
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
	import com.falanxia.emitor.interfaces.*;
	import com.falanxia.utilitaris.helpers.*;

	import flash.events.*;
	import flash.utils.*;



	/**
	 * Asset manager.
	 * Singleton.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * @since 1.0
	 */
	public class AssetManager extends EventDispatcher {


		private static var allAssetManagerList:Dictionary;

		private static var _defaultAssetManagerID:String;

		private var _provider:IAssetProvider;
		private var _id:String;



		/**
		 * Get an AssetManager by its ID.
		 * @param id
		 * @return
		 */
		public static function getAssetManager(id:String):AssetManager {
			var assetManager:Object = allAssetManagerList[id];

			return (assetManager == null) ? null : AssetManager(assetManager);
		}



		/**
		 * Get default AssetManager ID.
		 * @return Default AssetManager ID
		 */
		public static function get defaultAssetManagerID():String {
			return _defaultAssetManagerID;
		}



		/**
		 * Set default AssetManager ID.
		 * @param value Default AssetManager ID
		 */
		public static function set defaultAssetManagerID(value:String):void {
			_defaultAssetManagerID = value;
		}



		/**
		 * Create an instance of AssetManager and attach a Provider.
		 * @param id AssetManager ID
		 * @param provider Provider to be attached
		 * @see IAssetProvider
		 */
		public function AssetManager(id:String, provider:IAssetProvider) {
			if(allAssetManagerList == null) {
				allAssetManagerList = new Dictionary(true);
				_defaultAssetManagerID = id;
			}

			allAssetManagerList[id] = this;

			_id = id;
			_provider = provider;
		}



		/**
		 * Destructor.
		 */
		public function destroy():void {
			delete allAssetManagerList[_id];

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
			var out:Asset;

			if(_provider == null) {
				throw new Error("Asset provider not attached");
			}

			else {
				for each(var item:Asset in _provider.assetsDictionary) {
					if(item.id == id) out = item;
				}
			}

			return out;
		}



		/**
		 * Generate AssetManager description.
		 * @return AssetManager description
		 */
		override public function toString():String {
			var out:String;

			if(_provider == null) {
				out = "AssetManager info:\n  provider not attached";
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

				out = printf("AssetManager info:\n  provider=%s\n  registered assets: %s", ps, list);
			}

			return out;
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



		/**
		 * Get AssetManager ID.
		 * @return AssetManager ID
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
		 * Is AssetManager active?
		 * @return com.falanxia.emitor.AssetManager active flag
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
	}
}
