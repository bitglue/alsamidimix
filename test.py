import alsaseq

seq = alsaseq.Sequencer()
seq.setClientName('alsaseq test')
port = seq.createPort('in', alsaseq.portCapWrite | alsaseq.portCapSubsWrite)
print port

while True:
    event = seq.input()
    event.normalize()
    print
    print event.type
    if event.type in ['NOTEON', 'NOTEOFF']:
        print 'channel:', event.channel
        print 'note:', event.note
        print 'velocity:', event.velocity
        print 'offVelocity:', event.offVelocity
    elif event.type in ['CONTROLLER', 'PITCHBEND']:
        print 'channel:', event.channel
        try:
            name = '(%s)' % (alsaseq.controllerNames[event.param],)
        except KeyError:
            name = ''
        print 'param:', event.param, name
        print 'value:', event.value
    elif event.type in ['PGMCHANGE']:
        print 'value:', event.value
