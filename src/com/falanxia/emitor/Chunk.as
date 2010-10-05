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
	import flash.display.Bitmap;



	/**
	 * An Asset chunk.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura @ Falanxia a.s. <vaclav@falanxia.com>
	 * @since 1.0
	 */
	public class Chunk {


		private var _url:String;
		private var _bitmap:Bitmap;



		/**
		 * Chunk constructor.
		 * @param url Chunk URL
		 */
		public function Chunk(url:String) {
			_url = url;
			_bitmap = new Bitmap();
		}



		/**
		 * Destroys Chunk instance and frees it for GC.
		 */
		public function destroy():void {
			if(_bitmap != null && _bitmap.bitmapData != null) {
				_bitmap.bitmapData.dispose();
				_bitmap.bitmapData = null;
			}

			_url = null;
			_bitmap = null;
		}



		/**
		 * Get Chunk URL.
		 * @return Chunk URL
		 */
		public function get url():String {
			return _url;
		}



		/**
		 * Set Chunk Bitmap.
		 * @param value Chunk Bitmap
		 */
		public function set bitmap(value:Bitmap):void {
			_bitmap = value;
		}



		/**
		 * Get Chunk Bitmap.
		 * @return Chunk Bitmap
		 */
		public function get bitmap():Bitmap {
			return _bitmap;
		}
	}
}
