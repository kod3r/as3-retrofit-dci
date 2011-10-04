package eu.powdermonkey.retrofit.plugins
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	
	/**
	 * Plugin contains default instructions for mixin generator
	 * @author ifrost
	 */
	public class DefaultInstructions implements IGeneratorPlugin
	{
		
		public function DefaultInstructions() 
		{
			
		}
		
		public static function buildProxyPropName(namespaze:BCNamespace, interfaceType:Type):QualifiedName
		{
			return new QualifiedName(namespaze, '_' +interfaceType.fullName.replace(/[\.:]/g, '_'))
		}
		
		/* INTERFACE IMixinGeneratorPlugin */
		
		public function onProxiedObjectInitialization(data:ProxiedObjectData):Array 
		{
			var instructions:Array = [];
			var proxyPropertyName:QualifiedName = buildProxyPropName(data.namespaze, data.interfaceType);
			
			with (Instructions) {
				instructions.push([GetLocal_0]); // 'this'	
				instructions.push([FindPropertyStrict, data.proxiedObjectType.qname])
				instructions.push([ConstructProp, data.proxiedObjectType.qname, 0])
				instructions.push([InitProperty, proxyPropertyName])
			}
			
			return instructions;
		}
		
	}

}