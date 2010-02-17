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
	 * @author Vaclav Vancura (<a href="http://vaclav.vancura.org">vaclav.vancura.org</a>, <a href="http://twitter.com/vancura">@vancura</a>)
	 * @since 1.0
	 */
	public class LibrariumAssetProvider extends AssetProvider implements IAssetProvider {


		private static const _ASSETS_CONFIG_INDEX:String = 'config.json';

		private var _contentURL:String;
		private var _librarium:Librarium;
		private var _chunkLoadCounter:uint;
		private var _assetsConfig:Object;
		private var _assetsConfigIndex:String;
		private var _chunkDictionary:Dictionary;
		private var _indexDictionary:Dictionary;



		/**
		 * Constructor.
		 * @param contentURL Librarium archive URL
		 * @param assetsConfigIndex LibrariumItem name of the config, "config.json" by default
		 * @param logFunction Logging function. Set to {@code null} to disable logging (disabled by default)
		 */
		public function LibrariumAssetProvider(contentURL:String, assetsConfigIndex:String = _ASSETS_CONFIG_INDEX,
		                                       logFunction:Function = null) {
			super();

			// store varialbes
			_contentURL = contentURL;
			_assetsConfigIndex = assetsConfigIndex;
			_chunkDictionary = new Dictionary();
			_indexDictionary = new Dictionary();
			_chunkLoadCounter = 0;
			_isActive = true;

			// create a new librarium stream
			_librarium = new Librarium(logFunction);

			// add event listeners
			_librarium.addEventListener(Event.COMPLETE, _onLibrariumComplete, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.IO_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.SECURITY_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.DECOMPRESSION_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.INVALID_FILE_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.UNSUPPORTED_VERSION_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.PARSE_METADATA_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.PARSE_INDEX_ERROR, _onLibrariumError, false, 0, true);
			_librarium.addEventListener(LibrariumErrorEvent.PREPARE_DATA_ERROR, _onLibrariumError, false, 0, true);

			// load FAR and config item
			_librarium.loadURL(_contentURL);
		}



		/**
		 * Destructor.
		 */
		override public function destroy():void {
			if(_isActive) {
				// remove event listeners
				_librarium.addEventListener(Event.COMPLETE, _onLibrariumComplete, false, 0, true);
				_librarium.addEventListener(LibrariumErrorEvent.IO_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.SECURITY_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.DECOMPRESSION_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.INVALID_FILE_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.UNSUPPORTED_VERSION_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.PARSE_METADATA_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.PARSE_INDEX_ERROR, _onLibrariumError);
				_librarium.addEventListener(LibrariumErrorEvent.PREPARE_DATA_ERROR, _onLibrariumError);

				// destroy librarium
				_librarium.destroy();

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
		private function _dispatchError(eventName:String, message:String):void {
			_isError = true;
			_isLoaded = false;

			dispatchEvent(new ProviderErrorEvent(eventName, false, false, message));
		}



		private function _findURLs(asset:Asset, branch:Object):void {
			// browse all items in the list
			for each(var leaf:Object in branch) {
				// test for the leaf, if it's string, then it *may* contain an URL reference

				if(leaf is String) {
					// ok, it's a String
					var index:String = leaf as String;

					if(_librarium.contains(index)) {
						// it's a filename, since it's in the librarium archive
						var isNewChunk:Boolean = true;
						var isNewIndex:Boolean = true;

						// browse all stored chunks and indexes and test if the chunk is already there
						if(_chunkDictionary[index] != null) isNewChunk = false;
						if(_indexDictionary[index] != null) isNewIndex = false;

						if(isNewChunk) {
							// ok, so it's a new chunk
							var newChunk:Chunk = new Chunk(index);

							// increase counter to test for the last loaded chunk
							_chunkLoadCounter++;

							// add to the list
							_chunkDictionary[index] = newChunk;
						}

						if(isNewIndex) {
							// ok, so it's a new asset
							// create a new list of assets if not created before
							if(_indexDictionary[index] == null) _indexDictionary[index] = new Array();

							// add it to the list of assets
							_indexDictionary[index].push(asset);
						}
					}
				}

				else if(leaf is Object) {
					// no, it's an Object, so go deeper
					_findURLs(asset, leaf);
				}
			}
		}



		/* ★ EVENT LISTENERS ★ */


		private function _onItemReady(event:Event):void {
			var bitmap:Bitmap = event.target as Bitmap;

			// remove all event listeners
			bitmap.removeEventListener(Event.COMPLETE, _onItemReady);


			for each(var sourceChunk:Chunk in _chunkDictionary) {
				if(sourceChunk.bitmap == bitmap) {
					for each(var asset:Asset in _indexDictionary[sourceChunk.url]) {
						asset.addChunk(sourceChunk);
					}
				}
			}

			// check if all items are loaded
			--_chunkLoadCounter;
			if(_chunkLoadCounter == 0) {
				// all is done
				_isLoaded = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}



		private function _onLibrariumComplete(event:Event):void {
			if(!_isError) {
				// find asset config
				try {
					_assetsConfig = JSON.decode(_librarium.getItem(_assetsConfigIndex).getString());
				}
				catch(err:Error) {
					dispatchEvent(new ProviderErrorEvent(ProviderErrorEvent.CONFIG_PARSING_ERROR, false, false, printf('Librarium Asset Provider: Error parsing config JSON (%s)', err.message)));
					_isError = true;
				}
			}

			if(!_isError) {
				// find all assets specified in the config
				for each(var assetConfig:Object in _assetsConfig) {
					// create new asset
					// find all URLs referenced by the asset
					// add it to the list for future reference
					var newAsset:Asset = new Asset(assetConfig.id, assetConfig);
					_findURLs(newAsset, assetConfig);
					_assetsDictionary[assetConfig.id] = newAsset;
				}
			}

			if(!_isError) {
				// find all chunks previously found by the _findURLs() method
				for each(var chunk:Chunk in _chunkDictionary) {
					// chunk index contains even the prefix (like this:),
					// but itemHelper.index contains just index
					// hence we need to strip it this way

					// add event listener
					chunk.bitmap.addEventListener(Event.COMPLETE, _onItemReady, false, 0, true);

					// and assign a bitmap to the chunk
					_librarium.getItem(chunk.url).assignToBitmap(chunk.bitmap);
				}
			}
		}



		private function _onLibrariumError(event:LibrariumErrorEvent):void {
			_dispatchError(ProviderErrorEvent.PROVIDER_ERROR, printf('LibrariumAssetProvider error: %s', event.text));
		}
	}
}