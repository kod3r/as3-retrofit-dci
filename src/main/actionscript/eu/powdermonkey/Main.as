package eu.powdermonkey
{
	import dci.context.RoomTravelContext;
	import dci.interaction.IRoomTravellerRole;
	import dci.interaction.RoomTravellerRole;
	import eu.powdermonkey.retrofit.MixinRepository;
	import eu.powdermonkey.retrofit.plugins.SelfInjection;
	import eu.powdermonkey.retrofit.ValueClassRepository;
	
	import flash.geom.Point;
	import flash.utils.describeType;
	
	public class Main
	{
		private var mixinRepo:MixinRepository = new MixinRepository()
		
		private var valueClassRepo:ValueClassRepository = new ValueClassRepository()
		
		public function Main()
		{			
			with(mixinRepo)
			{
				// add self injection plugin required for dci test
				addGeneratorPlugin(new SelfInjection())
				
				defineMixin(RoomObject, RoomObjectCls)
				defineMixin(Moveable, MoveableCls)
				defineMixin(ItemContainer, ItemContainerImpl)
				defineMixin(IRoomTravellerRole, RoomTravellerRole)
				defineBase(Person)
				defineBase(Desk)
				defineBase(Item)
				prepare().completed.add(testMixins)
			}
			
			valueClassRepo.prepare([ServerMessage]).completed.add(testValueClass)
		}
		
		private function testMixins():void
		{
			testDesk()
			testPerson()
			testDCI();
		}
		
		private function testDCI():void {
			var dummyPerson:Person = mixinRepo.create(Person);
			
			var shyPerson:Person = mixinRepo.create(Person);
			shyPerson.name = "Shy Guy";
			
			var perkyPerson:Person = mixinRepo.create(Person);
			perkyPerson.name = "Perky Guy";
			
			var dummyRoom:Room = new Room("Dummy Room");
			dummyPerson.joinRoom(dummyRoom);
			
			var emptyRoom:Room = new Room("Empty Room");
			
			var shyPersonTravelContext:RoomTravelContext = new RoomTravelContext(shyPerson, dummyRoom, emptyRoom);
			var perkyPersonTravelContext:RoomTravelContext = new RoomTravelContext(perkyPerson, dummyRoom, emptyRoom);
			
			shyPersonTravelContext.visitEmptyRooms();
			perkyPersonTravelContext.visitAllRooms();
		}
				
		private function testDesk():void
		{
			var room:Room = new Room('lobby')
			var desk:Desk = mixinRepo.create(Desk)
			var apple:Item = mixinRepo.create(Item)
			desk.joinRoom(room)
			desk.addItem(apple)
			trace('desk in room:', desk.room, desk.items)
		}
		
		private function testPerson():void
		{
			var personA:Person = mixinRepo.create(Person)
		
			var roomA:Room = new Room('roomA')
			var roomB:Room = new Room('roomB')
			
			personA.joinRoom(roomA)
			trace('personA.room:', personA.room)
			
			personA.enteredTwoRooms(roomB, roomA)
			trace('personA.room:', personA.room)
			
			personA.room = roomA
			trace('personA.room:', personA.room)
			
			trace('personA.getRoomName(roomA):', personA.getRoomName(roomA))
			
			personA.move(new Point())
			trace('personA.location:', personA.location)
			
			// test multiple instances
			var personB:Person = mixinRepo.create(Person)
			
			personA.joinRoom(roomA);
			personB.joinRoom(roomB);
			
			trace("personA is in room", personA.room, " (should be roomA)");
			trace("personB is in room", personB.room, " (should be roomB)");
			
			personA.room = roomB;
			personB.room = roomA;
			
			trace("personA is in room", personA.room, " (should be roomB)");
			trace("personB is in room", personB.room, " (should be roomA)");
		}
		
		private function testValueClass():void
		{
			var serverMessage:ServerMessage = valueClassRepo.create(ServerMessage, {data:'brian', timestamp:28, id:'0'})
			var type:XML = describeType(serverMessage)
//			trace(type)
//			trace('serverMessage.id:', serverMessage.id)
//			trace('serverMessage.data:', serverMessage.data)
//			trace('serverMessage.timestamp:', serverMessage.timestamp)
//			trace('serverMessage.toString:', serverMessage)
		}
	}
}