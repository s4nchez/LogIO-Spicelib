package com.gourame.logio {
import flash.events.Event;
import flash.net.Socket;

import org.spicefactory.lib.flash.logging.LogEvent;
import org.spicefactory.lib.flash.logging.impl.AbstractAppender;

public class LogIOAppender extends AbstractAppender {
    private var _host:String = "localhost";
    private var _port:int = 28777;
    private var _node:String = "node";
    private var _streamName:String = "stream";

    private var _socket:Socket;

    public function LogIOAppender() {
    }

    public function set host(value:String):void {
        _host = value;
        reconnectIfAlreadyConnected();
    }

    public function set port(value:int):void {
        _port = value;
        reconnectIfAlreadyConnected();
    }

    public function set node(value:String):void {
        _node = value;
    }

    public function set streamName(value:String):void {
        _streamName = value;
    }

    private function connectAndRegister():void {
        _socket = new Socket(_host, _port);
        _socket.addEventListener(Event.CONNECT, traceEvent("Connect"));
        _socket.addEventListener(Event.CLOSE, traceEvent("Close"));
        writeRemotely("+node|" + _node + "|" + _streamName + "\r\n");
    }

    private static function traceEvent(eventName:String):Function {
        return function (event:Event):void {
            trace(eventName);
        };
    }

    private function writeRemotely(message:String):void {
        trace("Sending " + message);
        _socket.writeUTFBytes(message);
        _socket.flush();
    }

    private function reconnectIfAlreadyConnected():void {
        if (_socket) {
            connectAndRegister();
        }
    }

    override protected function handleLogEvent(event:LogEvent):void {
        if (!_socket) {
            connectAndRegister();
        }
        if (!isBelowThreshold(event.level)) {
            writeRemotely("+log|" + _streamName + "|" + _node + "|" + event.level + "|" + event.message + "\r\n");
        }

    }
}
}
