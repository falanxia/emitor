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

package com.falanxia.emitor.globals {
	import com.falanxia.emitor.Asset;
	import com.falanxia.emitor.AssetManager;
	import com.falanxia.utilitaris.helpers.printf;

	import flash.display.BitmapData;



	public function A2B(id:String, assetManagerID:String = null):BitmapData {
		if(assetManagerID == null) assetManagerID = AssetManager.defaultAssetManagerID;

		var assetManager:AssetManager = AssetManager.getAssetManager(assetManagerID);
		var asset:Asset = assetManager.getAsset(id);

		if(asset == null) {
			throw new Error(printf("Asset \"%s\" is not defined in skin. This probably means it's not specified in the JSON config file.", id));
		}

		return asset.getChunkByURL(id).bitmap.bitmapData;
	}
}
