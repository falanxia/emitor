// Falanxia Emitor.
//
// Copyright (c) 2010 Falanxia (http://falanxia.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package com.falanxia.emitor.globals {
	import com.falanxia.emitor.Asset;
	import com.falanxia.emitor.interfaces.IAssetProvider;
	import com.falanxia.utilitaris.helpers.printf;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;



	/**
	 * Asset manager.
	 * Singleton.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. vaclav@falanxia.com
	 * @since 1.0
	 */
	public class AssetManager extends EventDispatcher {


		private static var _provider:IAssetProvider;



		/**
		 * Attach a {@code Provider}.
		 * @param provider {@code Provider} to be attached
		 * @throws {@code Error} if {@code Asset} provider already attached
		 * @see IAssetProvider
		 */
		public static function attachProvider(provider:IAssetProvider):void {
			if(_provider == null) _provider = provider;
			else throw new Error("Asset provider already attached");
		}



		/**
		 * Get an {@code Asset}.
		 * @param id {@code Asset} ID
		 * @return {@code Asset} (if defined, {@code null} if not)
		 * @throws {@code Error} if {@code Asset} provider not attached
		 */
		public static function getAsset(id:String):* {
			var out:Asset;

			if(_provider == null) throw new Error("Asset provider not attached");

			else {
				for each(var item:Asset in _provider.assetsDictionary) {
					if(item.id == id) out = item;
				}
			}

			return out;
		}



		/**
		 * Generate {@code AssetManager} description.
		 * @return {@code AssetManager} description
		 */
		public static function toString():String {
			var out:String;

			if(_provider == null) out = "AssetManager info:\n  provider not attached";

			else {
				// create list of assets
				var list:String = "";
				for each(var i:Asset in _provider.assetsDictionary) {
					list += i.id + ", ";
				}

				// strip trailing ", "
				list = list.substr(0, list.length - 2);

				var ps:String = _provider.toString();
				out = printf("AssetManager info:\n  provider=%s\n  registered assets: %s", ps, list);
			}

			return out;
		}



		/* ★ SETTERS & GETTERS ★ */


		/**
		 * Get {@code Dictionary} of {@code Asset}s.
		 * @return {@code Dictionary} of assets as Array
		 * @throws {@code Error} if {@code Asset} provider not attached
		 */
		public static function get assetsDictionary():Dictionary {
			if(_provider == null) throw new Error("Asset provider not attached");

			else {
				// return asset list
				return _provider.assetsDictionary;
			}
		}



		/**
		 * Get pointer to {@code Asset} provider.
		 * @return {@code Asset} provider (if attached, {@code null} if not)
		 * @see IAssetProvider
		 */
		public static function get provider():IAssetProvider {
			return _provider;
		}



		/**
		 * Has an {@code Error} happened?
		 * @return {@code Error} happened flag
		 */
		public static function get isError():Boolean {
			var out:Boolean;

			if(_provider == null) out = false;
			else out = _provider.isError;

			return out;
		}



		/**
		 * Is AssetManager active?
		 * @return AssetManager active flag
		 */
		public static function get isActive():Boolean {
			var out:Boolean;

			if(_provider == null) out = false;
			else out = _provider.isActive;

			return out;
		}



		/**
		 * Is everything loaded?
		 * @return Loaded flag
		 */
		public static function get isLoaded():Boolean {
			var out:Boolean;

			if(_provider == null) out = false;
			else out = _provider.isLoaded;

			return out;
		}
	}
}
