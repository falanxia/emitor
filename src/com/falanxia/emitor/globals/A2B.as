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

package com.falanxia.emitor.globals {
	import com.falanxia.emitor.Asset;
	import com.falanxia.emitor.AssetManager;

	import flash.display.BitmapData;



	public function A2B(id:String, assetCollectionID:String = null, doNotThrowError:Boolean = false):BitmapData {
		if(assetCollectionID == null) assetCollectionID = AssetManager.getInstance().defaultCollectionID; // FIXME: Speed this up!

		var asset:Asset = AssetManager.getInstance().getCollection(assetCollectionID).getAsset(id); // FIXME: Speed this up!

		if(asset == null) {
			if(!doNotThrowError) {
				throw new Error("A2B: Asset '" + id + "' is not defined in skin. This probably means it's not specified in the JSON config file.");
			}
		}

		return asset.getChunkByURL(id).bitmap.bitmapData;
	}
}
