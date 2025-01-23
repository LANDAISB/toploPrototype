Class {
	#name : 'CSPClient',
	#superclass : 'CSPAbstractConnector',
	#instVars : [
		'whenMessageReceivedDo',
		'messagesReceived',
		'zmqSocketP'
	],
	#pools : [
		'ZMQConstants'
	],
	#category : 'ClientServerPrototype',
	#package : 'ClientServerPrototype'
}

{ #category : 'api - running' }
CSPClient >> doStep [

	"Receive up to a thousand messages"
	| currentReceived msg |
	currentReceived := 0.
	
	[
		msg := (zmqSocket receiveMsgDontWait) first.
		currentReceived := currentReceived + 1.
		msg isEmpty ifFalse:[ whenMessageReceivedDo value. messagesReceived := messagesReceived + 1].
		currentReceived = 1000 or: [msg isEmpty]] whileFalse

]

{ #category : 'initialization' }
CSPClient >> initialize [

	super initialize.

	whenMessageReceivedDo := [].
	messagesReceived := 0.
]

{ #category : 'accessing' }
CSPClient >> messagesReceived [

	^ messagesReceived
]

{ #category : 'accessing' }
CSPClient >> messagesReceived: anObject [

	messagesReceived := anObject
]

{ #category : 'api - running' }
CSPClient >> sendClientMessage [

	Transcript show: 'sendClientMessage'; cr.
	zmqSocketP send: 'test 1234'.
]

{ #category : 'initialization' }
CSPClient >> start [

	| urlString urlStringS|
	self isRunning ifTrue: [ ^ self ].

	urlString := self url asString.
	urlString last = $/ ifTrue: [ urlString := urlString allButLast ].
	
	zmqSocket := ZMQSocket new: ZMQ_SUB.
	zmqSocket connect: urlString.
	zmqSocket optionKey: 6 "ZMQ_SUBSCRIBE" optValue: 'test'.
	
	urlStringS := urlString allButLast.
	urlStringS := urlStringS, '2'.
	zmqSocketP := ZMQSocket new: ZMQ_PUB.
	zmqSocketP connect: urlStringS.

	service := TKTParameterizableService new
		name: 'CSPClient';
		step: [self doStep];
		stepDelay: delay;
		priority: 40;
		start;
		yourself.

]

{ #category : 'accessing' }
CSPClient >> whenMessageReceivedDo [

	^ whenMessageReceivedDo
]

{ #category : 'accessing' }
CSPClient >> whenMessageReceivedDo: anObject [

	whenMessageReceivedDo := anObject
]
