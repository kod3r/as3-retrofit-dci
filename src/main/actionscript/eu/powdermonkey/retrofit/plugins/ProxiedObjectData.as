package eu.powdermonkey.retrofit.plugins
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.QualifiedName;
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
		public var proxiedObjectPropertyQualifiedName:QualifiedName;
		
		public function ProxiedObjectData(proxiedObjectPropertyQualifiedName:QualifiedName, proxiedObject:Object, interfaceType:Type, namespaze:BCNamespace) 
		{
			this.proxiedObjectPropertyQualifiedName = proxiedObjectPropertyQualifiedName;
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