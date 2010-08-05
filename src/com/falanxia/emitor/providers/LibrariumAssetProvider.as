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


package com.falanxia.emitor.providers {
	import com.falanxia.emitor.*;
	import com.falanxia.emitor.events.*;
	import com.falanxia.emitor.interfaces.*;
	import com.falanxia.jsonora.*;
	import com.falanxia.librarium.*;
	import com.falanxia.librarium.events.*;
	import com.falanxia.utilitaris.helpers.*;

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;



	/**
	 * Librarium Asset provider.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * @since 1.0
	 */
	public class LibrariumAssetProvider extends AssetProvider implements IAssetProvider {


		public static const DEFAULT_ASSETS_CONFIG_INDEX:String = "config.json";

		private var _url:String;
		private var _isUncompressEnabled:Boolean;

		private var librarium:Librarium;
		private var chunkLoadCounter:uint;
		private var assetsConfig:Object;
		private var assetsConfigIndex:String;
		private var chunkDictionary:Dictionary;
		private var indexDictionary:Dictionary;



		/**
		 * Constructor.
		 * @param url Librarium archive URL
		 * @param assetsConfigIndex LibrariumItem name of the config, "config.json" by default
		 * @param isUncompressEnabled true to uncompress data, false to keep data compressed (e.g. to save memory), resulting in decompression on demannd (e.g. via getItem().data())
		 * @param logFunction Logging function. Set to null to disable logging (disabled by default)
		 */
		public function LibrariumAssetProvider(url:String, assetsConfigIndex:String = DEFAULT_ASSETS_CONFIG_INDEX, isUncompressEnabled:Boolean = true, logFunction:Function = null
				) {
			super();

			// store varialbes
			this.assetsConfigIndex = assetsConfigIndex;
			this.chunkDictionary = new Dictionary();
			this.indexDictionary = new Dictionary();
			this.chunkLoadCounter = 0;

			_url = url;
			_isUncompressEnabled = isUncompressEnabled;
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
			librarium.addEventListener(LibrariumErrorEvent.ADD_CHUNK_ERROR, onLibrariumError, false, 0, true);
			librarium.addEventListener(ProgressEvent.PROGRESS, onLibrariumProgress, false, 0, true);

			// load FAR and config item
			librarium.loadURL(url, _isUncompressEnabled);
		}



		/**
		 * Destructor.
		 */
		override public function destroy():void {
			var chunk:Chunk;

			if(_isActive) {
				// remove event listeners
				librarium.removeEventListener(Event.COMPLETE, onLibrariumComplete);
				librarium.removeEventListener(LibrariumErrorEvent.IO_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.SECURITY_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.DECOMPRESSION_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.INVALID_FILE_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.UNSUPPORTED_VERSION_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.PARSE_METADATA_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.PARSE_INDEX_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.PREPARE_DATA_ERROR, onLibrariumError);
				librarium.removeEventListener(LibrariumErrorEvent.ADD_CHUNK_ERROR, onLibrariumError);
				librarium.removeEventListener(ProgressEvent.PROGRESS, onLibrariumProgress);

				// destroy librarium
				librarium.destroy();

				// destroy super
				super.destroy();

				// destroy chunks
				for each(chunk in chunkDictionary) chunk.destroy();

				_url = null;
				librarium = null;
				assetsConfig = null;
				assetsConfigIndex = null;
				chunkDictionary = null;
				indexDictionary = null;
			}
		}



		/**
		 * Dispose source LBA from memory.
		 */
		override public function dispose():void {
			super.dispose();

			librarium.destroy();

			librarium = null;
		}



		/**
		 * Get an Asset from the provider.
		 * @param id Asset ID
		 * @return Asset (if found, null if not)
		 */
		public function getAsset(id:String):Asset {
			var asset:Asset = _assetsDictionary[id];
			var e:ProviderItemEvent;

			if(asset != null) {
				// dispatch en event that the item was loaded
				e = new ProviderItemEvent(ProviderItemEvent.ITEM_LOADED, false, false, asset);
				dispatchEvent(e);
			}

			return asset;
		}



		/**
		 * Get AssetProvider URL.
		 * @return AssetProvider URL
		 */
		public function get url():String {
			return _url;
		}



		/**
		 * Dispatch an Error event.
		 * @param eventName Event name
		 * @param message Event message
		 */
		private function dispatchError(eventName:String, message:String):void {
			_isError = true;
			_isLoaded = false;

			dispatchEvent(new ProviderErrorEvent(eventName, false, false, message));
		}



		private function findURLs(asset:Asset, branch:Object):void {
			var leaf:Object;
			var index:String;
			var isNewChunk:Boolean;
			var isNewIndex:Boolean;
			var newChunk:Chunk;

			// browse all items in the list
			for each(leaf in branch) {
				// test for the leaf, if it's string, then it *may* contain an URL reference

				if(leaf is String) {
					// ok, it's a String
					index = String(leaf);

					if(index.charAt(0) == "@") {
						index = index.substr(1);

						if(librarium.contains(index)) {
							// it's a filename, since it's in the librarium archive
							isNewChunk = true;
							isNewIndex = true;

							// browse all stored chunks and indexes and test if the chunk is already there
							if(chunkDictionary[index] != null) isNewChunk = false;
							if(indexDictionary[index] != null) isNewIndex = false;

							if(isNewChunk) {
								// ok, so it's a new chunk
								newChunk = new Chunk(index);

								// increase counter to test for the last loaded chunk
								chunkLoadCounter++;

								// add to the list
								chunkDictionary[index] = newChunk;
							}

							if(isNewIndex) {
								// ok, so it's a new asset
								// create a new list of assets if not created before
								if(indexDictionary[index] == null) indexDictionary[index] = new Array();
							}

							// add it to the list of assets
							indexDictionary[index].push(asset);
						}
					}
				}

				else {
					if(leaf is Object) {
						// no, it's an Object, so go deeper
						findURLs(asset, leaf);
					}
				}
			}
		}



		private function onItemReady(e:Event):void {
			var bitmap:Bitmap = Bitmap(e.target);
			var sourceChunk:Chunk;
			var asset:Asset;

			// remove all event listeners
			bitmap.removeEventListener(Event.COMPLETE, onItemReady);

			for each(sourceChunk in chunkDictionary) {
				if(sourceChunk.bitmap == bitmap) {
					for each(asset in indexDictionary[sourceChunk.url]) {
						try {
							asset.addChunk(sourceChunk);
						}
						catch(err:Error) {
							dispatchEvent(new LibrariumErrorEvent(LibrariumErrorEvent.DECOMPRESSION_ERROR, false, false, err.message));
							_isError = true;
						}
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



		private function onLibrariumComplete(e:Event):void {
			var assetConfig:Object;
			var newAsset:Asset;
			var chunk:Chunk;
			var item:LibrariumItem;

			if(!_isError) {
				// find asset config
				try {
					item = librarium.getItem(assetsConfigIndex);
					assetsConfig = JSON.decode(item.getString());
				}
				catch(err:Error) {
					dispatchEvent(new ProviderErrorEvent(ProviderErrorEvent.CONFIG_PARSING_ERROR, false, false,
					                                     printf("Librarium Asset Provider: Error parsing config JSON (%s)", err.message)));
					_isError = true;
				}
			}

			if(!_isError) {
				// no assets at all?
				if(assetsConfig.length == 0) {
					dispatchEvent(new Event(Event.COMPLETE));
				}
				else {
					// find all assets specified in the config
					for each(assetConfig in assetsConfig) {
						// create new asset
						// find all URLs referenced by the asset
						// add it to the list for future reference
						newAsset = new Asset(assetConfig.id, assetConfig);
						findURLs(newAsset, assetConfig);
						_assetsDictionary[assetConfig.id] = newAsset;
					}
				}
			}

			if(!_isError) {
				// find all chunks previously found by the _findURLs() method
				for each(chunk in chunkDictionary) {
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



		private function onLibrariumError(e:LibrariumErrorEvent):void {
			dispatchError(ProviderErrorEvent.PROVIDER_ERROR, printf("LibrariumAssetProvider error: %s", e.text));
		}



		private function onLibrariumProgress(e:ProgressEvent):void {
			dispatchEvent(e.clone());
		}
	}
}
