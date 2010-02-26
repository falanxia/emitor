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


package com.falanxia.emitor.providers {
	import com.falanxia.emitor.Asset;
	import com.falanxia.emitor.Chunk;
	import com.falanxia.emitor.events.ProviderErrorEvent;
	import com.falanxia.emitor.events.ProviderItemEvent;
	import com.falanxia.emitor.interfaces.IAssetProvider;
	import com.falanxia.jsonora.JSON;
	import com.falanxia.librarium.Librarium;
	import com.falanxia.librarium.events.LibrariumErrorEvent;
	import com.falanxia.utilitaris.helpers.printf;

	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.Dictionary;



	/**
	 * Librarium Asset provider.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. vaclav@falanxia.com
	 * @since 1.0
	 */
	public class LibrariumAssetProvider extends AssetProvider implements IAssetProvider {


		private static const ASSETS_CONFIG_INDEX:String = "config.json";

		private var contentURL:String;
		private var librarium:Librarium;
		private var chunkLoadCounter:uint;
		private var assetsConfig:Object;
		private var assetsConfigIndex:String;
		private var chunkDictionary:Dictionary;
		private var indexDictionary:Dictionary;



		/**
		 * Constructor.
		 * @param contentURL Librarium archive URL
		 * @param assetsConfigIndex LibrariumItem name of the config, "config.json" by default
		 * @param logFunction Logging function. Set to {@code null} to disable logging (disabled by default)
		 */
		public function LibrariumAssetProvider(contentURL:String, assetsConfigIndex:String = ASSETS_CONFIG_INDEX,
		                                       logFunction:Function = null) {
			super();

			// store varialbes
			this.contentURL = contentURL;
			this.assetsConfigIndex = assetsConfigIndex;
			this.chunkDictionary = new Dictionary();
			this.indexDictionary = new Dictionary();
			this.chunkLoadCounter = 0;
			_isActive = true;

			// create a new librarium stream
			librarium = new Librarium(logFunction);

			// add event listeners
			librarium.addEventListener(Event.COMPLETE, onLibrariumComplete, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.IO_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.SECURITY_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.DECOMPRESSION_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.INVALID_FILE_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.UNSUPPORTED_VERSION_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.PARSE_METADATA_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.PARSE_INDEX_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(LibrariumErrorEvent.PREPARE_DATA_ERROR, onLibrariumError, false, 0, true);

			// load FAR and config item
			librarium.loadURL(contentURL);
		}



		/**
		 * Destructor.
		 */
		override public function destroy():void {
			if(_isActive) {
				// remove event listeners
				librarium.addEventListener(Event.COMPLETE, onLibrariumComplete, false, 0, true);
				librarium.addEventListener(LibrariumErrorEvent.IO_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.SECURITY_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.DECOMPRESSION_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.INVALID_FILE_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.UNSUPPORTED_VERSION_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.PARSE_METADATA_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.PARSE_INDEX_ERROR, onLibrariumError);
				librarium.addEventListener(LibrariumErrorEvent.PREPARE_DATA_ERROR, onLibrariumError);

				// destroy librarium
				librarium.destroy();

				// destroy super
				super.destroy();
			}
		}



		/**
		 * Get an {@code Asset} from the provider.
		 * @param id {@code Asset} ID
		 * @return {@code Asset} (if found, {@code null} if not)
		 */
		public function getAsset(id:String):Asset {
			var asset:Asset = _assetsDictionary[id];

			if(asset != null) {
				// dispatch en event that the item was loaded
				var e:ProviderItemEvent = new ProviderItemEvent(ProviderItemEvent.ITEM_LOADED, false, false, asset);
				dispatchEvent(e);
			}

			return asset;
		}



		/* ★ PRIVATE METHODS ★ */


		/**
		 * Dispatch an {@code Error} event.
		 * @param eventName Event name
		 * @param message Event message
		 */
		private function dispatchError(eventName:String, message:String):void {
			_isError = true;
			_isLoaded = false;

			dispatchEvent(new ProviderErrorEvent(eventName, false, false, message));
		}



		private function findURLs(asset:Asset, branch:Object):void {
			// browse all items in the list
			for each(var leaf:Object in branch) {
				// test for the leaf, if it's string, then it *may* contain an URL reference

				if(leaf is String) {
					// ok, it's a String
					var index:String = String(leaf);

					if(librarium.contains(index)) {
						// it's a filename, since it's in the librarium archive
						var isNewChunk:Boolean = true;
						var isNewIndex:Boolean = true;

						// browse all stored chunks and indexes and test if the chunk is already there
						if(chunkDictionary[index] != null) isNewChunk = false;
						if(indexDictionary[index] != null) isNewIndex = false;

						if(isNewChunk) {
							// ok, so it's a new chunk
							var newChunk:Chunk = new Chunk(index);

							// increase counter to test for the last loaded chunk
							chunkLoadCounter++;

							// add to the list
							chunkDictionary[index] = newChunk;
						}

						if(isNewIndex) {
							// ok, so it's a new asset
							// create a new list of assets if not created before
							if(indexDictionary[index] == null) indexDictionary[index] = new Array();

							// add it to the list of assets
							indexDictionary[index].push(asset);
						}
					}
				}

				else if(leaf is Object) {
					// no, it's an Object, so go deeper
					findURLs(asset, leaf);
				}
			}
		}



		/* ★ EVENT LISTENERS ★ */


		private function onItemReady(event:Event):void {
			var bitmap:Bitmap = Bitmap(event.target);

			// remove all event listeners
			bitmap.removeEventListener(Event.COMPLETE, onItemReady);


			for each(var sourceChunk:Chunk in chunkDictionary) {
				if(sourceChunk.bitmap == bitmap) {
					for each(var asset:Asset in indexDictionary[sourceChunk.url]) {
						asset.addChunk(sourceChunk);
					}
				}
			}

			// check if all items are loaded
			--chunkLoadCounter;
			if(chunkLoadCounter == 0) {
				// all is done
				_isLoaded = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}



		private function onLibrariumComplete(event:Event):void {
			if(!_isError) {
				// find asset config
				try {
					assetsConfig = JSON.decode(librarium.getItem(assetsConfigIndex).getString());
				}
				catch(err:Error) {
					dispatchEvent(new ProviderErrorEvent(ProviderErrorEvent.CONFIG_PARSING_ERROR, false, false, printf("Librarium Asset Provider: Error parsing config JSON (%s)", err.message)));
					_isError = true;
				}
			}

			if(!_isError) {
				// find all assets specified in the config
				for each(var assetConfig:Object in assetsConfig) {
					// create new asset
					// find all URLs referenced by the asset
					// add it to the list for future reference
					var newAsset:Asset = new Asset(assetConfig.id, assetConfig);
					findURLs(newAsset, assetConfig);
					_assetsDictionary[assetConfig.id] = newAsset;
				}
			}

			if(!_isError) {
				// find all chunks previously found by the _findURLs() method
				for each(var chunk:Chunk in chunkDictionary) {
					// chunk index contains even the prefix (like this:),
					// but itemHelper.index contains just index
					// hence we need to strip it this way

					// add event listener
					chunk.bitmap.addEventListener(Event.COMPLETE, onItemReady, false, 0, true);

					// and assign a bitmap to the chunk
					librarium.getItem(chunk.url).assignToBitmap(chunk.bitmap);
				}
			}
		}



		private function onLibrariumError(event:LibrariumErrorEvent):void {
			dispatchError(ProviderErrorEvent.PROVIDER_ERROR, printf("LibrariumAssetProvider error: %s", event.text));
		}
	}
}
