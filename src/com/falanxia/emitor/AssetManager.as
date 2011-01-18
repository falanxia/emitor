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
	 * Asset manager.
	 * Singleton.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 */
	public class AssetManager extends EventDispatcher {


		private static var instance:AssetManager;

		private var allCollectionList:Dictionary;

		private var _defaultCollectionID:String;



		/**
		 * Constructor.
		 */
		public function AssetManager(s:Senf) {
			if(s == null) throw new Error("AssetManager is singleton, use getInstance() method");
		}



		/**
		 * Singleton acces method
		 * @return Instance of the AssetManager singleton.
		 */
		public static function getInstance():AssetManager {
			if(instance == null) instance = new AssetManager(new Senf());

			return instance;
		}



		/**
		 * Get an AssetCollection by its ID.
		 * @param id AssetCollection ID
		 * @return AssetCollection
		 */
		public function getCollection(id:String):AssetCollection {
			var collection:Object = allCollectionList[id];

			return (collection == null) ? null : AssetCollection(collection);
		}



		/**
		 * Set AssetCollection.
		 * @param id AssetCollection ID
		 * @param provider Provider
		 */
		public function setCollection(id:String, provider:IAssetProvider):void {
			if(allCollectionList == null) {
				allCollectionList = new Dictionary(true);

				_defaultCollectionID = id;
			}

			allCollectionList[id] = new AssetCollection(id, provider);
		}



		/**
		 * Get default AssetCollection ID.
		 * @return Default AssetCollection ID
		 */
		public function get defaultCollectionID():String {
			return _defaultCollectionID;
		}



		/**
		 * Set default AssetCollection ID.
		 * @param value Default AssetCollection ID
		 */
		public function set defaultCollectionID(value:String):void {
			_defaultCollectionID = value;
		}



		/**
		 * Create an instance of AssetCollection and attach a Provider.
		 * @param id AssetCollection ID
		 * @param provider Provider to be attached
		 * @see IAssetProvider
		 */
		public function createCollection(id:String, provider:IAssetProvider):AssetCollection {
			if(allCollectionList == null) {
				allCollectionList = new Dictionary(true);

				_defaultCollectionID = id;
			}

			var collection:AssetCollection = new AssetCollection(id, provider);

			allCollectionList[id] = collection;

			return collection;
		}



		/**
		 * Destructor.
		 * @param id AssetCollection ID
		 */
		public function destroyCollection(id:String):void {
			var collection:Object = allCollectionList[id];

			if(collection != null) {
				AssetCollection(collection).destroy();
			}

			delete allCollectionList[id];
		}
	}
}



class Senf {
}
