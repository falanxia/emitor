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

package com.falanxia.emitor {
	import com.falanxia.utilitaris.helpers.printf;



	/**
	 * Asset template.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. vaclav@falanxia.com
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
		 * Add a chunk.
		 * @param chunk {@code Chunk}
		 * @throws {@code Error} if {@code Chunk} with this url already added
		 * @see {@code Chunk}
		 */
		public function addChunk(chunk:Chunk):void {
			for each(var c:Chunk in _chunksList) {
				if(c.url == chunk.url) {
					throw new Error(printf("Chunk with URL %s already added", chunk.url));
				}
			}

			_chunksList.push(chunk);
		}



		/**
		 * Get chunk by its URL.
		 * @param url {@code Chunk} URL
		 * @return {@code Chunk} if found, null if not
		 * @throws {@code Error} if {@code Chunk} with this {@code url} not found is an {@code Asset}
		 * @see {@code Chunk}
		 */
		public function getChunkByURL(url:String):Chunk {
			var o:Chunk;

			// try to find it in the _chunksList
			for each(var c:Chunk in _chunksList) {
				if(c.url == url) o = c;
			}

			if(o == null) throw new Error(printf("Chunk with URL '%s' not found in Asset '%s'", url, _id));

			return o;
		}



		/* ★ SETTERS & GETTERS ★ */


		/**
		 * Get list of {@code Chunk}s.
		 * @return List of {@code Chunk}s as an {@code Array}
		 * @see {@code Chunk}
		 */
		public function get chunksList():Array {
			return _chunksList;
		}



		/**
		 * Set list of {@code Chunk}s.
		 * @param value List of {@code Chunk}s as {@code Array}
		 * @see {@code Chunk}
		 */
		public function set chunksList(value:Array):void {
			_chunksList = value;
		}



		/**
		 * Get {@code Asset} ID.
		 * @return {@code Asset} ID
		 */
		public function get id():String {
			return _id;
		}



		/**
		 * Get {@code Asset} config.
		 * @return {@code Asset} config
		 */
		public function get config():Object {
			return _config;
		}



		/**
		 * Generate {@code Asset} description.
		 * @return {@code Asset} Description
		 */
		public function toString():String {
			return printf("Asset id='%s'", id);
		}
	}
}
