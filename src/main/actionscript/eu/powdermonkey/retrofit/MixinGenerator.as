package eu.powdermonkey.retrofit
{
	import eu.powdermonkey.retrofit.plugins.IGeneratorPlugin;
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectMethodData;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	import org.flemit.bytecode.*;
	import org.flemit.reflection.*;
	
	import eu.powdermonkey.retrofit.plugins.ProxiedObjectData;
	
	public class MixinGenerator extends BaseGenerator
	{
		protected var _plugins:Array;
		
		public function MixinGenerator(plugins:Array) {
			super();
			_plugins = plugins;
		}
		
		public function generate(name:QualifiedName, base:Type, mixins:Dictionary):DynamicClass
		{
			var superClass:Type = Type.getType(Object)
			
			var interfaces:Array = [].concat(base).concat(base.getInterfaces())
//			var mixinClasses:Dictionary = new Dictionary()
//			
//			for each (var interfaceType:Type in interfaces)
//			{
//				if (mixins.hasOwnProperty(interfaceType.classDefinition))
//				{
//					mixinClasses[interfaceType] = mixins[interfaceType.name]
//				}
//				else if (mixins.hasOwnProperty(interfaceType.fullName))
//				{
//					mixinClasses[interfaceType] = mixins[interfaceType.fullName]
//				}
//			}
			
			var dynamicClass:DynamicClass = new DynamicClass(name, superClass, interfaces)
			
			addInterfaceMembers(dynamicClass)
			
			var method:MethodInfo
			var property:PropertyInfo
			
			// add fields for proxied objects
			
			var propertyInfo:PropertyInfo
			var proxyPropertyName:QualifiedName
			var proxyObject:Object 
			var proxyObjectType:Type 
			
			for (var interfaceType:* in mixins) 
			{
				proxyObject = mixins[interfaceType]
				proxyObjectType = Type.getType(proxyObject)
				proxyPropertyName = buildProxyPropName(namespaze, interfaceType)
				
				var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
				
				var fieldInfo:FieldInfo = new FieldInfo(
					dynamicClass,  // onwer
					buildProxyPropName(namespaze, interfaceType).name, // name
					null, // fullname
					MemberVisibility.PUBLIC, // visibility
					false, // static
					interfaceType); // type
				dynamicClass.addSlot(fieldInfo); // add field
			}
			
			// HOOK: dynamic class creation
			for each (var plugin:IGeneratorPlugin in _plugins) {
				plugin.afterDynamicClassDefinition(dynamicClass);
			}			
			
			dynamicClass.constructor = createConstructor(dynamicClass)
			
			dynamicClass.addMethodBody(dynamicClass.scriptInitialiser, generateScriptInitialier(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.staticInitialiser, generateStaticInitialiser(dynamicClass))
			dynamicClass.addMethodBody(dynamicClass.constructor, generateInitialiser(dynamicClass, mixins))
			
			return dynamicClass; 
		}
		
		private function createConstructor(dynamicClass:DynamicClass):MethodInfo
		{
			return new MethodInfo(dynamicClass, "ctor", null, MemberVisibility.PUBLIC, false, false, Type.star, [])
		}
		
		private function generateInitialiser(dynamicClass:DynamicClass, mixins:Dictionary):DynamicMethod
		{
			var baseCtor : MethodInfo = dynamicClass.baseType.constructor;
			var argCount : uint = baseCtor.parameters.length;
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			var proxies:int = 0
			
			with (Instructions)
			{
				var instructions : Array = [
					[GetLocal_0],
					[PushScope],
					// begin construct super
					[GetLocal_0], // 'this'
					[ConstructSuper, argCount]
				];
				
				var propertyInfo:PropertyInfo
				var proxyPropertyName:QualifiedName
				var proxyObject:Object 
				var proxyObjectType:Type 
				
				// HOOK: before proxy initialization
				for each (var plugin:IGeneratorPlugin in _plugins) {
					plugin.beforeProxyInitialization(instructions);
				}
				
				for (var interfaceType:Type in mixins) 
				{
					proxyObject = mixins[interfaceType]
					proxyObjectType = Type.getType(proxyObject)
					proxyPropertyName = buildProxyPropName(namespaze, interfaceType)
					
					// data for plugins
					var proxiedObjectData:ProxiedObjectData = new ProxiedObjectData(proxyPropertyName, proxyObject, interfaceType, namespaze);
					
					// HOOK: before proxied object initialization
					for each (plugin in _plugins) {
						plugin.beforeProxiedObjectInitialization(proxiedObjectData, instructions);
					}					
					
					// default instructions creating proxied objects (with parametless constructor!)
					with (Instructions) {
						instructions.push([GetLocal_0]); // 'this'	
						instructions.push([FindPropertyStrict, proxiedObjectData.proxiedObjectType.qname])
						instructions.push([ConstructProp, proxiedObjectData.proxiedObjectType.qname, 0])
						instructions.push([InitProperty, proxyPropertyName])
					}					
					
					// HOOK: after proxied object initialization					
					for each (plugin in _plugins) {
						plugin.afterProxiedObjectInitialization(proxiedObjectData, instructions);
					}
					
					proxies++
				}
				
				// HOOK: after proxy initialization
				for each (plugin in _plugins) {
					plugin.afterProxyInitialization(instructions);
				}				
				
				instructions.push(
					[ReturnVoid]
				);
				
				var argumentBytes:int = proxies * 9
				
				return new DynamicMethod(dynamicClass.constructor, 6 + argumentBytes, 3 + argumentBytes, 4, 5, instructions);
			}
		}
		
		private function buildProxyPropName(namespaze:BCNamespace, interfaceType:Type):QualifiedName
		{
			return new QualifiedName(namespaze, '_' +interfaceType.fullName.replace(/[\.:]/g, '_'))
		}
		
		override protected function generateMethod(type:Type, dynamicClass:DynamicClass, method:MethodInfo, baseMethod:MethodInfo, baseIsDelegate:Boolean, name:String, methodType:uint):DynamicMethod
		{
			var argCount:uint = method.parameters.length;
			var namespaze:BCNamespace = new BCNamespace('', NamespaceKind.PACKAGE_NAMESPACE)
			var proxyPropertyName:QualifiedName = buildProxyPropName(namespaze, type)

			var proxiedObjectMethodData:ProxiedObjectMethodData = new ProxiedObjectMethodData(proxyPropertyName, namespaze, argCount, method, methodType);
			

			with (Instructions)
			{
				var instructions:Array = [
					[GetLocal_0],
					[PushScope],
				];
				
				// HOOK: before method invocation
				for each (var plugin:IGeneratorPlugin in _plugins) {
					plugin.beforeProxiedMethodInvocation(proxiedObjectMethodData, instructions);
				}
				
				if (methodType == MethodType.METHOD)
				{
					instructions.push([GetLocal_0])
					instructions.push([GetProperty, proxiedObjectMethodData.proxiedObjectPropertyQualifiedName])
					
					for (var i:uint=0; i < proxiedObjectMethodData.argCount; ++i)
					{
						instructions.push([GetLocal, i+1])
					}
					
//					var methodQName:QualifiedName = new QualifiedName(namespaze, method.name)
					if (proxiedObjectMethodData.methodInfo.returnType == Type.voidType)
					{
						instructions.push([CallPropVoid, proxiedObjectMethodData.methodInfo.qname, argCount])
					}
					else
					{
						instructions.push([CallProperty, proxiedObjectMethodData.methodInfo.qname, proxiedObjectMethodData.argCount])
					}
				}
				else if (proxiedObjectMethodData.methodType == MethodType.PROPERTY_GET || methodType == MethodType.PROPERTY_SET)
				{
					
					instructions.push([GetLex, proxiedObjectMethodData.proxiedObjectPropertyQualifiedName])
					instructions.push([GetProperty, proxiedObjectMethodData.methodQualifiedName])
					
					if (methodType == MethodType.PROPERTY_SET)
					{
						instructions.push([GetLocal, 0])
						instructions.push([GetProperty, proxiedObjectMethodData.proxiedObjectPropertyQualifiedName])
						instructions.push([GetLocal, 1])
						instructions.push([SetProperty, proxiedObjectMethodData.methodQualifiedName])
					}
					else {
						instructions.push([GetLocal, 0])
						instructions.push([GetProperty, proxiedObjectMethodData.proxiedObjectPropertyQualifiedName])
						instructions.push([GetProperty, proxiedObjectMethodData.methodQualifiedName])
					}		
				}
				
				// HOOK: before method invocation
				for each (plugin in _plugins) {
					plugin.afterProxiedMethodInvocation(proxiedObjectMethodData, instructions);
				}
				
				if (proxiedObjectMethodData.methodInfo.returnType == Type.voidType) // void
				{
					instructions.push([ReturnVoid])
				}
				else
				{
					instructions.push([ReturnValue])
				}
				
				return new DynamicMethod(method, 7 + argCount, argCount + 2, 4, 5, instructions);
			}
		}
	}		
}