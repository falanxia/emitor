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



	/**
	 * Asset template.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * @since 1.0
	 */
	public class Asset {


		private var _id:String;
		private var _config:Object;
		private var _chunksList:Array = new Array();



		/**
		 * Create a new Asset.
		 * @param id Asset ID
		 * @param config Config data
		 */
		public function Asset(id:String, config:Object) {
			_id = id;
			_config = config;
		}



		/**
		 * Destroys Asset instance and frees it for GC.
		 */
		public function destroy():void {
			var c:Chunk;

			for each(c in _chunksList) {
				c.destroy();
			}

			_id = null;
			_config = null;
			_chunksList = null;
		}



		/**
		 * Add a chunk.
		 * @param chunk Chunk
		 * @throws Error if Chunk with this url already added
		 * @see Chunk
		 */
		public function addChunk(chunk:Chunk):void {
			var c:Chunk;

			for each(c in _chunksList) {
				if(c.url == chunk.url) {
					throw new Error("Chunk with URL " + chunk.url + " already added");
				}
			}

			_chunksList.push(chunk);
		}



		/**
		 * Get chunk by its URL.
		 * @param url Chunk URL
		 * @return Chunk if found, null if not
		 * @throws Error if Chunk with this url not found is an Asset
		 * @see Chunk
		 */
		public function getChunkByURL(url:String):Chunk {
			var o:Chunk;
			var c:Chunk;

			if(url.charAt(0) == "@") url = url.substr(1); // strip the prefix @ from the url to allow LibrariumAssetProvider URL parsing

			// try to find it in the _chunksList
			for each(c in _chunksList) {
				if(c.url == url) o = c;
			}

			if(o == null) {
				throw new Error("Chunk with URL '" + url + "' not found in Asset '" + _id + "'. This probably means the referenced file ('" + url + "') is not bundled in the LBA archive.");
			}

			return o;
		}



		/**
		 * Get list of Chunks.
		 * @return List of Chunks as an Array
		 * @see Chunk
		 */
		public function get chunksList():Array {
			return _chunksList;
		}



		/**
		 * Set list of Chunks.
		 * @param value List of Chunks as Array
		 * @see Chunk
		 */
		public function set chunksList(value:Array):void {
			_chunksList = value;
		}



		/**
		 * Get Asset ID.
		 * @return Asset ID
		 */
		public function get id():String {
			return _id;
		}



		/**
		 * Get Asset config.
		 * @return Asset config
		 */
		public function get config():Object {
			return _config;
		}



		/**
		 * Generate Asset description.
		 * @return Asset Description
		 */
		public function toString():String {
			return "Asset id='" + id + "'";
		}
	}
}
