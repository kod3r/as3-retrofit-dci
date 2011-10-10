package eu.powdermonkey.retrofit.plugins.asp3cts
{
	import eu.powdermonkey.retrofit.plugins.IGeneratorPlugin;
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectData;
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectMethodData;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.Instructions;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.FieldInfo;
	import org.flemit.reflection.MemberVisibility;
	import org.flemit.reflection.Type;
	
	/**
	 * ...
	 * @author ifrost
	 */
	public class Asp3ctsPlugin implements IGeneratorPlugin 
	{
		protected var _aspects:Array;
		
		public function Asp3ctsPlugin() 
		{
			_aspects = [];
		}
		
		public function addAspect(aspect:Object):void {
			_aspects.push(aspect);
		}
		
		protected function buildAspectPropertyName(namespaze:BCNamespace, aspectType:Type):QualifiedName {
			return new QualifiedName(namespaze, '_aspect_' +aspectType.fullName.replace(/[\.:]/g, '_'))
		}
		
		public function afterDynamicClassDefinition(dynamicClass:DynamicClass):void {
			// add fields for aspects
			// TODO: add only needed fields
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			
			for each (var aspect:Object in _aspects) {
				var aspectType:Type = Type.getType(aspect);
				var fieldInfo:FieldInfo = new FieldInfo(
						dynamicClass,  // onwer
						buildAspectPropertyName(namespaze, aspectType).name, // name
						null, // fullname
						MemberVisibility.PUBLIC, // visibility
						false, // static
						aspectType); // type					
				dynamicClass.addSlot(fieldInfo); // add field
			}
			
			// initialize data for aspects
			initializeAsp3ct();
		}
		
		public function beforeProxyInitialization(instructions:Array):void 
		{
			
		}
		
		public function afterProxyInitialization(instructions:Array):void 
		{
			for each (var aspect:Object in _aspects) {
				var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
				var aspectType:Type = Type.getType(aspect)
				var aspectPropertyName:QualifiedName = buildAspectPropertyName(namespaze, aspectType)
				
				with (Instructions) {
					instructions.push([GetLocal_0]); // 'this'	
					instructions.push([FindPropertyStrict, aspectType.qname])
					instructions.push([ConstructProp, aspectType.qname, 0])
					instructions.push([InitProperty, aspectPropertyName])
				}
			}
		}
		
		public function beforeProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void 
		{
			
		}
		
		public function afterProxiedObjectInitialization(data:ProxiedObjectData, instructions:Array):void 
		{
			
		}
		
		public function beforeProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void 
		{
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			
			for each (var aspect:Object in _aspects) {
				var aspectType:Type = Type.getType(aspect);
				var description:XML = describeType(aspect);
				
				var advices:XMLList = description.method.(metadata.(@name == "Before")[0]);
				
				for each (var advice:XML in advices) {
				
					var methodName:String = advice.@name;
					var methodQualifiedName:QualifiedName = new QualifiedName(namespaze, methodName);
					var aspectPropertyQualifiedName:QualifiedName = buildAspectPropertyName(namespaze, aspectType);
					
					var adviceExpression:String = advice.metadata.(@name == "Before")[0].arg[0].@value;
					
					if (methodMatch(data, adviceExpression)) {
					
						// add instructions that invoke method
						with (Instructions) {
							instructions.push([GetLocal_0])
							instructions.push([GetProperty, aspectPropertyQualifiedName])
							instructions.push([CallPropVoid, methodQualifiedName, 0])					
						}					
					}
					
				}
			}
		}		
		
		public function afterProxiedMethodInvocation(data:ProxiedObjectMethodData, instructions:Array):void 
		{
			
		}
		
		// privates
		
		private function methodMatch(data:ProxiedObjectMethodData, adviceExpression:String):Boolean {
			// all methods
			if (adviceExpression == "*") {
				return true;
			}
			
			// TODO: temporary - exact name
			if (data.methodInfo.name == adviceExpression) {
				return true;
			}
			
			return false;
		}
		
		private function initializeAsp3ct():void {
			
		}
		
	}

}