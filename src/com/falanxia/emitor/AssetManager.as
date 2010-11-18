/*
 * Copyright (c) 2010 Vaclav Vancura (http://vaclav.vancura.org)
 */

package com.falanxia.emitor {
	import com.falanxia.emitor.interfaces.IAssetProvider;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;



	/**
	 * Asset manager.
	 * Singleton.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * 
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



		public static function setAssetManager(id:String, provider:IAssetProvider):void {
			if(allAssetManagerList == null) {
				allAssetManagerList = new Dictionary(true);
				_defaultAssetManagerID = id;
			}

			allAssetManagerList[id] = new AssetManager(id, provider);
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

				out = "AssetManager info:\n  provider=" + ps + "\n  registered assets: " + list;
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
