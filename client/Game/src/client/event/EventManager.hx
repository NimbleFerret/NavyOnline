package client.event;

interface EventListener {
	function notify(event:String, params:Dynamic):Void;
}

class EventManager {
	private final listeners = new Map<String, List<EventListener>>();

	public static final instance:EventManager = new EventManager();

	private function new() {}

	public function subscribe(eventType:String, listener:EventListener) {
		if (listeners.exists(eventType)) {
			final users = listeners.get(eventType);
			users.add(listener);
		} else {
			final newList = new List();
			newList.add(listener);
			listeners.set(eventType, newList);
		}
	}

	public function unsubscribe(eventType:String, listener:EventListener) {
		final users = listeners.get(eventType);
		users.remove(listener);
	}

	public function notify(eventType:String, params:Dynamic) {
		final ls = listeners.get(eventType);
		for (listener in ls) {
			listener.notify(eventType, params);
		}
	}
}
