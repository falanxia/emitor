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

package com.falanxia.emitor.events {
	import flash.events.ErrorEvent;
	import flash.events.Event;



	/**
	 * Provider ErrorEvent.
	 * Something bad happened.
	 *
	 * @author Falanxia (<a href="http://falanxia.com">falanxia.com</a>, <a href="http://twitter.com/falanxia">@falanxia</a>)
	 * @author Vaclav Vancura / Falanxia a.s.
	 */
	public class ProviderErrorEvent extends ErrorEvent {


		/** Provider error */
		public static const PROVIDER_ERROR:String = "providerErrorEvent:providerError";

		/** Item not found */
		public static const ITEM_NOT_FOUND:String = "providerErrorEvent:itemNotFound";

		/** Item load failed */
		public static const ITEM_LOAD_FAILED:String = "providerErrorEvent:itemLoadFailed";

		/** Config parsing error */
		public static const CONFIG_PARSING_ERROR:String = "providerErrorEvent:configParsingError";



		/**
		 * Event constructor.
		 * @param type Event type (see Event constants)
		 * @param text Error description
		 */
		public function ProviderErrorEvent(type:String, text:String = "") {
			super(type, false, false, text);
		}



		/**
		 * Clone Event.
		 * @return Cloned Event
		 */
		public override function clone():Event {
			return new ProviderErrorEvent(type, text);
		}
	}
}
