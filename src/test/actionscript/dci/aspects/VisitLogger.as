package dci.aspects 
{
	/**
	 * ...
	 * @author ifrost
	 */
	public class VisitLogger 
	{
		
		public function VisitLogger() 
		{
			
		}
		
		[Before("visitRoom")]
		public function beforeVisitingRoom():void {
			trace("LOGGER: before visiting room");
		}
		
		[After("visitRoom")]
		public function afterVisitingRoom():void {
			trace("LOGGER: after visiting room");
		}
		
		
	}

}