#!/usr/bin/env python

from __future__ import division
import select, sys
from os import path
import alsaseq, alsamixer

class MidiMixer(object):
    def __init__(self):
        self.boundElements = {}
        self.feedbackers = []

        self.seq = alsaseq.Sequencer(streams='duplex')
        self.seq.setClientName(path.basename(sys.argv[0]))
        self.seq.setNonBlocking(True)
        self.inPort = self.seq.createPort('in', alsaseq.portCapWrite | alsaseq.portCapSubsWrite)
        self.outPort = self.seq.createPort('out', alsaseq.portCapWrite | alsaseq.portCapRead | alsaseq.portCapSubsRead)

        self.mixer = alsamixer.Mixer()
        self.mixer.attach('default')
        self.mixer.load()
        self.mixer.registerSimpleElement()

    def bindPlayback(self, elementName, cc, channel='*', elementIndex=0):
        if channel == '*':
            outChannel = 0
        else:
            channel -= 1        # alsa starts them at 0; they start at 1 usually
            outChannel = channel

        def sendFeedback(_=None):       # parameter is the element that changed, but that info is already in scope
            min, max = element.playbackVolumeRange
            value = int(round((element.getPlaybackVolume() - min) / (max - min) * 127))
            self._sendCC(cc, value, outChannel)

        element = alsamixer.Element(self.mixer, elementName, elementIndex)
        self.boundElements[(cc, channel)] = element
        element.setCallback(sendFeedback)
        self.feedbackers.append(sendFeedback)

    def run(self):
        poller = select.poll()
        self.seq.registerPoll(poller, input=True)
        self.mixer.registerPoll(poller)
        while True:
            poller.poll()
            while True:
                event = self.seq.input()
                if event is None: break
                self._handleMidiEvent(event)
            self.mixer.handleEvents()

    def _sendCC(self, cc, value, channel):
        event = alsaseq.Event()
        event.type = 'CONTROLLER'
        event.channel = channel
        event.param = cc
        event.value = value
        event.set_source(self.outPort)
        event.set_subscribers()
        event.set_direct()
        self.seq.output(event)
        self.seq.drainOutput()

    def _handleMidiEvent(self, event):
        event.normalize()

        if event.type == 'PORT_SUBSCRIBED':
            for f in self.feedbackers:
                f()
            return

        if event.type != 'CONTROLLER':
            return

        try:
            element = self.boundElements[(event.param, event.channel)]
        except KeyError:
            try:
                element = self.boundElements[(event.param, '*')]
            except KeyError:
                return

        floatValue = event.value / 127
        min, max = element.playbackVolumeRange
        element.setPlaybackVolumeAll(int(round(floatValue * (max-min) + min)))


def main(configFilename=path.expanduser('~/.midimixerrc')):
    mm = MidiMixer()
    namespace = dict([(k, getattr(mm, k)) for k in dir(mm) if not k.startswith('_')])
    execfile(configFilename, namespace)
    mm.run()


if __name__ == '__main__':
    import sys
    main(*sys.argv[1:])
