/// @note Taken from: http://stackoverflow.com/questions/466280/get-bounds-of-filters-applied-to-flash-sprite-within-sprite
package lup.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BoundsHelper
	{
		private var _hBmd:BitmapData;
		private var _hBmdRect:Rectangle;
		private var _hMtr:Matrix;
		private var _hPoint:Point;
		
		private var _xMin:Number;
		private var _xMax:Number;
		private var _yMin:Number;
		private var _yMax:Number;
		
		/**
		 * Specify maxFilteredObjWidth and maxFilteredObjHeight to match the maximal possible size
		 * of a filtered object. Performance of the helper is inversely proportional to the product
		 * of these values.
		 *
		 * @param maxFilteredObjWidth Maximal width of a filtered object.
		 * @param maxFilteredObjHeight Maximal height of a filtered object.
		 */
		public function BoundsHelper(maxFilteredObjWidth:Number = 500, maxFilteredObjHeight:Number = 500) {
			_hMtr = new Matrix();
			_hPoint = new Point();
			_hBmd = new BitmapData(maxFilteredObjWidth, maxFilteredObjHeight, true, 0);
			_hBmdRect = new Rectangle(0, 0, maxFilteredObjWidth, maxFilteredObjHeight);
		}
		
		/**
		 * Determines boundary rectangle of an object relative to the given coordinate space.
		 *
		 * @param obj The object which bounds are being determined.
		 *
		 * @param space The coordinate space relative to which the bounds should be represented.
		 *        If you pass null or the object itself, then bounds will be represented
		 *        relative to the (untransformed) object.
		 *
		 * @param dst Destination rectangle to store the result in. If you pass null,
		 *        new rectangle will be created and returned. Otherwise the passed
		 *        rectangle will be updated and returned.
		 */
		public function getRealBounds(obj:DisplayObject, space:DisplayObject = null, dst:Rectangle = null):Rectangle {
			var tx:Number = (_hBmdRect.width  - obj.width ) / 2,
				ty:Number = (_hBmdRect.height - obj.height) / 2;
			
			// get transformation matrix that translates the object to the center of the bitmap
			_hMtr.identity();
			_hMtr.translate(tx, ty);
			
			// clear the bitmap, so it will contain only pixels with zero alpha channel
			_hBmd.fillRect(_hBmdRect, 0);
			// draw the object; it will be drawn untransformed, except for translation
			// caused by _hMtr matrix
			_hBmd.draw(obj, _hMtr);
			
			// get the area which encloses all pixels with nonzero alpha channel (i.e. our object)
			var bnd:Rectangle = dst ? dst : new Rectangle(),
				selfBnd:Rectangle = _hBmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
			
			// transform the area to eliminate the effect of _hMtr transformation; now we've obtained
			// the bounds of the object in it's own coord. system (self bounds)
			selfBnd.offset(-tx, -ty);
			
			if (space && space !== obj) { // the dst coord space is different from the object's one
				// so we need to obtain transformation matrix from the object's coord space to the dst one
				var mObjToSpace:Matrix;
				
				if (space === obj.parent) {
					// optimization
					mObjToSpace = obj.transform.matrix;
				} else if (space == obj.stage) {
					// optimization
					mObjToSpace = obj.transform.concatenatedMatrix;
				} else {
					// general case
					var mStageToSpace:Matrix = space.transform.concatenatedMatrix; // space -> stage
					mStageToSpace.invert();                                    // stage -> space
					mObjToSpace = obj.transform.concatenatedMatrix;                // obj -> stage
					mObjToSpace.concat(mStageToSpace);                             // obj -> space
				}
				
				// now we transform all four vertices of the boundary rectangle to the target space
				// and determine the bounds of this transformed shape
				
				_xMin =  Number.MAX_VALUE;
				_xMax = -Number.MAX_VALUE;
				_yMin =  Number.MAX_VALUE;
				_yMax = -Number.MAX_VALUE;
				
				expandBounds(mObjToSpace.transformPoint(getPoint(selfBnd.x, selfBnd.y)));
				expandBounds(mObjToSpace.transformPoint(getPoint(selfBnd.right, selfBnd.y)));
				expandBounds(mObjToSpace.transformPoint(getPoint(selfBnd.x, selfBnd.bottom)));
				expandBounds(mObjToSpace.transformPoint(getPoint(selfBnd.right, selfBnd.bottom)));
				
				bnd.x = _xMin;
				bnd.y = _yMin;
				bnd.width = _xMax - _xMin;
				bnd.height = _yMax - _yMin;
			} else {
				// the dst coord space is the object's one, so we simply return the self bounds
				bnd.x = selfBnd.x;
				bnd.y = selfBnd.y;
				bnd.width = selfBnd.width;
				bnd.height = selfBnd.height;
			}
			
			return bnd;
		}
		
		private function getPoint(x:Number, y:Number):Point {
			_hPoint.x = x;
			_hPoint.y = y;
			return _hPoint;
		}
		
		private function expandBounds(p:Point):void {
			if (p.x < _xMin) {
				_xMin = p.x;
			}
			if (p.x > _xMax) {
				_xMax = p.x;
			}
			if (p.y < _yMin) {
				_yMin = p.y;
			}
			if (p.y > _yMax) {
				_yMax = p.y;
			}
		}
	}
}