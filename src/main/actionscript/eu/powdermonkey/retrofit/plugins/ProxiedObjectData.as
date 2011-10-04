package eu.powdermonkey.retrofit.plugins
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.reflection.Type;
	/**
	 * ...
	 * @author ifrost
	 */
	public class ProxiedObjectData 
	{		
		public var namespaze:BCNamespace;
		public var proxiedObjectType:Type;
		public var interfaceType:Type;
		public var proxiedObject:Object;
		
		public function ProxiedObjectData(proxiedObject:Object, interfaceType:Type, namespaze:BCNamespace) 
		{
			this.namespaze = namespaze;
			this.proxiedObject = proxiedObject;
			this.interfaceType = interfaceType;
			generateInfoData();
		}
		
		private function generateInfoData():void 
		{			
			proxiedObjectType = Type.getType(proxiedObject)
		}
		
	}

}