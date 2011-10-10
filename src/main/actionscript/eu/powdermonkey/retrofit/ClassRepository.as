package eu.powdermonkey.retrofit
{
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import org.flexunit.experimental.theories.internals.error.CouldNotGenerateValueException;
	
	import org.flemit.SWFHeader;
	import org.flemit.SWFWriter;
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.ByteCodeLayoutBuilder;
	import org.flemit.bytecode.DynamicClass;
	import org.flemit.bytecode.IByteCodeLayout;
	import org.flemit.bytecode.IByteCodeLayoutBuilder;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.reflection.Type;
	import org.flemit.tags.DoABCTag;
	import org.flemit.tags.EndTag;
	import org.flemit.tags.FileAttributesTag;
	import org.flemit.tags.FrameLabelTag;
	import org.flemit.tags.ScriptLimitsTag;
	import org.flemit.tags.SetBackgroundColorTag;
	import org.flemit.tags.ShowFrameTag;
	import org.flemit.util.ClassUtility;
	import org.flemit.util.MethodUtil;
	
	public class ClassRepository
	{
		protected var classes:Dictionary = new Dictionary()
		
		protected var dynamicClasses:Dictionary = new Dictionary()
		
		protected var loaders:Array = []
		
		/**
		 * Creates an instance of a proxy. The proxy must already have been 
		 * prepared by calling prepare.
		 * @param cls The class to create a proxy instance for
		 * @param args The arguments to pass to the base constructor
		 * @param interceptor The interceptor that will receive calls from the proxy
		 * @return An instance of the class specified by the cls argument
		 * @throws ArgumentException Thrown when a proxy for the cls argument has not been prepared by 
		 * calling prepare 
		 */
		protected function validateClass(cls:Class, args:Array):Object
		{
			var clazz:Class = classes[cls].clazz
			
			if (clazz == null)
			{
				throw new ArgumentError("A class for " 
					+ getQualifiedClassName(cls) + " has not been prepared yet") 
			}
			
			var classType:Type = Type.getType(clazz)
			var constructorArgCount : int = classType.constructor.parameters.length
			var constructorRequiredArgCount : int = MethodUtil.getRequiredArgumentCount(classType.constructor)
			
			if (args.length < constructorArgCount || args.length > constructorArgCount)
			{
				throw new ArgumentError('Constructor expects at least '+constructorArgCount+'arguemnts')
			}
			
			return ClassUtility.createClass(clazz, args)
		}
		
		protected function prepareClasses(classesToPrepare:Array, generator:Function, applicationDomain:ApplicationDomain = null):PreperationSignals
		{
			applicationDomain = applicationDomain || new ApplicationDomain(ApplicationDomain.currentDomain);
			
			var layoutBuilder:IByteCodeLayoutBuilder = new ByteCodeLayoutBuilder()
			var generatedNames:Dictionary = new Dictionary()
			
			for each(var cls:Class in classesToPrepare)
			{
				var type:Type = Type.getType(cls);
				var qname:QualifiedName = generateQName(type)
				var dynamicClass:DynamicClass = generator(qname, type)
				generatedNames[cls] = qname
				dynamicClasses[cls] = dynamicClass
				layoutBuilder.registerType(dynamicClass)
			}
			
			var layout:IByteCodeLayout = layoutBuilder.createLayout()
			
			var loader:Loader = createSwf(layout, applicationDomain)
			loaders.push(loader)
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadedHandler)
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, swfErrorHandler)
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, swfErrorHandler)
			
			var preperationSignals:PreperationSignals = new PreperationSignals(classesToPrepare)
			return preperationSignals
			
			function swfErrorHandler(error:ErrorEvent) : void
			{
				throw new Error("Error generating swf: " + error.text);
				preperationSignals.error.dispatch(error)
			}
			
			function swfLoadedHandler(event:Event):void
			{
				for each(var cls : Class in classesToPrepare)
				{
					var qname:QualifiedName = generatedNames[cls]
					var fullName:String = qname.ns.name.concat('::', qname.name)
					var generatedClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(fullName) as Class
					
					Type.getType(generatedClass)
					classes[cls] = generatedClass
				}
				
				preperationSignals.completed.dispatch()
			}
		}
		
		protected function basicValidation(type:Type):void
		{
			if (type.isGeneric || type.isGenericTypeDefinition)
			{
				throw new IllegalOperationError("Generic types (Vector) are not supported. (feature request #2599097)")
			}
			
			if (type.qname.ns.kind != NamespaceKind.PACKAGE_NAMESPACE)
			{
				throw new IllegalOperationError("Private (package) classes are not supported. (feature request #2549289)")
			}
		}
		
		private function createSwf(layout:IByteCodeLayout, applicationDomain:ApplicationDomain):Loader
		{
			var buffer:ByteArray = new ByteArray()
			var header:SWFHeader = new SWFHeader(10)
			var swfWriter:SWFWriter = new SWFWriter()
				
			swfWriter.write(buffer, header, [
					FileAttributesTag.create(false, false, false, true, true),
					new ScriptLimitsTag(),
					new SetBackgroundColorTag(0xFF, 0x0, 0x0),
					new FrameLabelTag("ProxyFrameLabel"),
					new DoABCTag(false, "ProxyGenerated", layout),
					new ShowFrameTag(),
					new EndTag()
			])
			
			buffer.position = 0
			
			var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain)
			enableAIRDynamicExecution(loaderContext)
			
			var loader:Loader = new Loader()
			loader.loadBytes(buffer, loaderContext)
			
			return loader
		}
		
		private function enableAIRDynamicExecution(loaderContext:LoaderContext) : void
		{
			// Needed for AIR
			if (loaderContext.hasOwnProperty("allowLoadBytesCodeExecution"))
			{
				loaderContext["allowLoadBytesCodeExecution"] = true;
			}
		}
		
		protected function generateQName(type:Type):QualifiedName
		{
			var ns:BCNamespace = (type.qname.ns.kind != NamespaceKind.PACKAGE_NAMESPACE)
				? type.qname.ns
				: BCNamespace.packageNS(type.packageName);
			
			return new QualifiedName(ns, "Generated" + type.name);
		}
		
		private function typeAlreadyPreparedFilter(cls:Class, index:int, array:Array):Boolean
		{
			return (classes[cls] == null);
		}
	}
}