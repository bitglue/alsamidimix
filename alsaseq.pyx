cdef extern from 'errno.h':
    int EAGAIN

cdef extern from 'sys/poll.h':
    struct pollfd:
        int fd
        short events
        short revents

    int POLLIN
    int POLLPRI
    int POLLOUT
    int POLLERR
    int POLLHUP
    int POLLNVAL

cdef extern from 'stdlib.h':
    ctypedef unsigned size_t
    void *malloc(size_t size)
    void free(void *ptr)

cdef extern from 'string.h':
    void *memcpy(void *dest, void *src, size_t n)

cdef extern from 'alsa/asoundlib.h':
    ctypedef struct snd_seq_t:
        pass

    int snd_seq_open(snd_seq_t **seqp, char *name, int streams, int mode)
    int snd_seq_nonblock(snd_seq_t *seq, int nonblock)

    int SND_SEQ_OPEN_OUTPUT
    int SND_SEQ_OPEN_INPUT
    int SND_SEQ_OPEN_DUPLEX

    char *snd_strerror(int errnum)
    int snd_seq_set_client_name(snd_seq_t *seq, char *name)
    int snd_seq_create_simple_port(snd_seq_t *seq, char *name, unsigned int caps, unsigned int type)
    int snd_seq_drain_output(snd_seq_t *seq)

    int SND_SEQ_PORT_CAP_READ
    int SND_SEQ_PORT_CAP_WRITE
    int SND_SEQ_PORT_CAP_DUPLEX
    int SND_SEQ_PORT_CAP_SUBS_READ
    int SND_SEQ_PORT_CAP_SUBS_WRITE

    int SND_SEQ_PORT_TYPE_SPECIFIC
    int SND_SEQ_PORT_TYPE_MIDI_GENERIC
    int SND_SEQ_PORT_TYPE_MIDI_GM
    int SND_SEQ_PORT_TYPE_MIDI_GS
    int SND_SEQ_PORT_TYPE_MIDI_XG
    int SND_SEQ_PORT_TYPE_MIDI_MT32
    int SND_SEQ_PORT_TYPE_SYNTH
    int SND_SEQ_PORT_TYPE_DIRECT_SAMPLE
    int SND_SEQ_PORT_TYPE_SAMPLE
    int SND_SEQ_PORT_TYPE_APPLICATION


    int SND_SEQ_EVENT_SYSTEM
    int SND_SEQ_EVENT_RESULT

    int SND_SEQ_EVENT_NOTE
    int SND_SEQ_EVENT_NOTEON
    int SND_SEQ_EVENT_NOTEOFF
    int SND_SEQ_EVENT_KEYPRESS

    int SND_SEQ_EVENT_CONTROLLER
    int SND_SEQ_EVENT_PGMCHANGE
    int SND_SEQ_EVENT_CHANPRESS
    int SND_SEQ_EVENT_PITCHBEND
    int SND_SEQ_EVENT_CONTROL14
    int SND_SEQ_EVENT_NONREGPARAM
    int SND_SEQ_EVENT_REGPARAM

    int SND_SEQ_EVENT_SONGPOS
    int SND_SEQ_EVENT_SONGSEL
    int SND_SEQ_EVENT_QFRAME
    int SND_SEQ_EVENT_TIMESIGN
    int SND_SEQ_EVENT_KEYSIGN

    int SND_SEQ_EVENT_START
    int SND_SEQ_EVENT_CONTINUE
    int SND_SEQ_EVENT_STOP
    int SND_SEQ_EVENT_SETPOS_TICK
    int SND_SEQ_EVENT_SETPOS_TIME
    int SND_SEQ_EVENT_TEMPO
    int SND_SEQ_EVENT_CLOCK
    int SND_SEQ_EVENT_TICK
    int SND_SEQ_EVENT_QUEUE_SKEW
    int SND_SEQ_EVENT_SYNC_POS

    int SND_SEQ_EVENT_TUNE_REQUEST
    int SND_SEQ_EVENT_RESET
    int SND_SEQ_EVENT_SENSING

    int SND_SEQ_EVENT_ECHO
    int SND_SEQ_EVENT_OSS

    int SND_SEQ_EVENT_CLIENT_START
    int SND_SEQ_EVENT_CLIENT_EXIT
    int SND_SEQ_EVENT_CLIENT_CHANGE
    int SND_SEQ_EVENT_PORT_START
    int SND_SEQ_EVENT_PORT_EXIT
    int SND_SEQ_EVENT_PORT_CHANGE

    int SND_SEQ_EVENT_PORT_SUBSCRIBED
    int SND_SEQ_EVENT_PORT_UNSUBSCRIBED

    int SND_SEQ_EVENT_USR0
    int SND_SEQ_EVENT_USR1
    int SND_SEQ_EVENT_USR2
    int SND_SEQ_EVENT_USR3
    int SND_SEQ_EVENT_USR4
    int SND_SEQ_EVENT_USR5
    int SND_SEQ_EVENT_USR6
    int SND_SEQ_EVENT_USR7
    int SND_SEQ_EVENT_USR8
    int SND_SEQ_EVENT_USR9

    int SND_SEQ_EVENT_SYSEX
    int SND_SEQ_EVENT_BOUNCE
    int SND_SEQ_EVENT_USR_VAR0
    int SND_SEQ_EVENT_USR_VAR1
    int SND_SEQ_EVENT_USR_VAR2
    int SND_SEQ_EVENT_USR_VAR3
    int SND_SEQ_EVENT_USR_VAR4

    int SND_SEQ_EVENT_NONE


    int snd_seq_poll_descriptors_count(snd_seq_t *seq, short events)
    int snd_seq_poll_descriptors(snd_seq_t *seq, pollfd *pfds, unsigned int space, short events)

    int snd_seq_event_input_pending(snd_seq_t *seq, int fetch_sequencer)
    int snd_seq_event_output_pending(snd_seq_t *seq)

    ctypedef unsigned char snd_seq_event_type_t
    ctypedef unsigned int snd_seq_tick_time_t
    ctypedef struct snd_seq_real_time_t:
        unsigned int tv_sec
        unsigned int tv_nsec

    ctypedef struct snd_seq_addr_t:
        unsigned char client
        unsigned char port

    ctypedef union snd_seq_timestamp_t:
        snd_seq_tick_time_t tick
        snd_seq_real_time_t time

    ctypedef struct snd_seq_ev_note_t:
        unsigned char channel
        unsigned char note
        unsigned char velocity
        unsigned char off_velocity
        unsigned int duration

    ctypedef struct snd_seq_ev_ctrl_t:
        unsigned char channel
        unsigned int param
        signed int value

    #ctypedef struct snd_seq_ev_raw8_t:
    #    unsigned char d[12]

    #ctypedef struct snd_seq_ev_raw32_t:
    #    unsigned int d[3]

    #ctypedef struct snd_seq_connect_t:
    #    snd_seq_addr_t sender
    #    snd_seq_addr_t dest

    cdef union eventFlavors:
        snd_seq_ev_note_t note
        snd_seq_ev_ctrl_t control
        #snd_seq_ev_raw8_t raw8
        #snd_seq_ev_raw32_t raw32
        #snd_seq_ev_ext_t ext
        #snd_seq_ev_queue_control_t queue
        #snd_seq_timestamp_t time
        snd_seq_addr_t addr
        #snd_seq_connect_t connect
        #snd_seq_result_t result
        #snd_seq_ev_instr_begin_t instr_begin
        #snd_seq_ev_sample_control_t sample

    ctypedef struct snd_seq_event_t:
        snd_seq_event_type_t type
        unsigned char flags
        unsigned char tag

        unsigned char queue
        snd_seq_timestamp_t time

        snd_seq_addr_t source
        snd_seq_addr_t dest
        eventFlavors data

    int snd_seq_event_input(snd_seq_t *seq, snd_seq_event_t **ev)
    int snd_seq_event_output(snd_seq_t *seq, snd_seq_event_t *ev)
    void snd_seq_ev_clear(snd_seq_event_t *ev)
    void snd_seq_ev_set_subs(snd_seq_event_t *ev)
    void snd_seq_ev_set_source(snd_seq_event_t *ev, int port)
    void snd_seq_ev_set_direct(snd_seq_event_t *ev)


import select


class AlsaError(Exception):
    pass


cdef class Event:
    cdef snd_seq_event_t event

    def __init__(self):
        snd_seq_ev_clear(&self.event)

    def normalize(self):
        """Change NOTEON with velocity 0 to NOTEOFF vith velocity 64."""
        if self.event.type == SND_SEQ_EVENT_NOTEON \
        and self.event.data.note.velocity == 0:
            self.event.type = SND_SEQ_EVENT_NOTEOFF
            self.event.data.note.velocity = 64

    def set_subscribers(self):
        """Sets the destination of self as the subscribers of the source port.

        See snd_seq_ev_set_subs in the C API.
        """
        snd_seq_ev_set_subs(&self.event)

    def set_source(self, port):
        """Sets the source port of self.

        See snd_seq_ev_set_source in the C API.
        """
        snd_seq_ev_set_source(&self.event, port)

    def set_direct(self):
        """Schedules self for direct delivery.

        See snd_seq_ev_set_direct() in the C API.
        """
        snd_seq_ev_set_direct(&self.event)

    property type:
        def __get__(self):
            return eventTypeNames[self.event.type]
        def __set__(self, value):
            try:
                self.event.type = eventTypeValues[value]
            except KeyError:
                raise ValueError, '%r is not a valid event type' % (value,)

    property flags:
        def __get__(self):
            return self.event.flags
        def __set__(self, unsigned char flags):
            self.event.flags = flags

    property tag:
        def __get__(self):
            return self.event.tag
        def __set__(self, unsigned char tag):
            self.event.tag = tag

    property queue:
        def __get__(self):
            return self.event.queue
        def __set__(self, unsigned char queue):
            self.event.queue = queue

    property source:
        def __get__(self):
            return self.source.client, self.source.port
        def __set__(self, value):
            self.source.client = value[0]
            self.source.port = value[1]

    property dest:
        def __get__(self):
            return self.dest.client, self.dest.port
        def __set__(self, value):
            self.dest.client, self.dest.port = value

    property channel:
        # both note and control have channel, but they are in the same place in
        # the union.
        def __get__(self):
            return self.event.data.note.channel
        def __set__(self, value):
            self.event.data.note.channel = value

    property note:
        def __get__(self):
            return self.event.data.note.note
        def __set__(self, value):
            self.event.data.note.note = note

    property velocity:
        def __get__(self):
            return self.event.data.note.velocity
        def __set__(self, value):
            self.event.data.note.velocity = value

    property offVelocity:
        def __get__(self):
            return self.event.data.note.off_velocity
        def __set__(self, value):
            self.event.data.note.off_velocity = value

    property duration:
        def __get__(self):
            return self.event.data.note.duration
        def __set__(self, value):
            self.event.data.note.duration = value

    property param:
        def __get__(self):
            return self.event.data.control.param
        def __set__(self, value):
            self.event.data.control.param = value

    property value:
        def __get__(self):
            return self.event.data.control.value
        def __set__(self, value):
            self.event.data.control.value = value

    property addr:
        def __get__(self):
            return self.event.data.addr.client, self.event.data.addr.port
        def __set__(self, value):
            self.event.data.addr.client, self.event.data.addr.port = value


cdef copyEvent(snd_seq_event_t *ev):
    cdef Event new
    new = Event.__new__(Event)
    memcpy(&new.event,  ev, sizeof(snd_seq_event_t))
    return new


cdef class Sequencer:
    cdef snd_seq_t *handle

    def __new__(self, char *name='default', streams='input', nonBlocking=False):
        cdef int err
        cdef int cstreams

        if streams == 'input':
            cstreams = SND_SEQ_OPEN_INPUT
        elif streams == 'output':
            cstreams = SND_SEQ_OPEN_OUTPUT
        elif streams == 'duplex':
            cstreams = SND_SEQ_OPEN_DUPLEX
        else:
            raise ValueError, '"streams" argument must be one of "input", "output", or "duplex"'

        err = snd_seq_open(&self.handle, name, cstreams, nonBlocking and SND_SEQ_OPEN_OUTPUT or 0)
        if err:
            raise AlsaError, snd_strerror(err)

    def setNonBlocking(self, int mode):
        cdef int err
        err = snd_seq_nonblock(self.handle, mode)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def setClientName(self, char *name):
        cdef int err
        err = snd_seq_set_client_name(self.handle, name)
        if err:
            raise AlsaError, snd_strerror(err)

    def inputPending(self, fetchSequencer=False):
        return snd_seq_event_input_pending(self.handle, fetchSequencer)

    def outputPending(self):
        return snd_seq_event_output_pending(self.handle)

    def input(self):
        cdef int remaining
        cdef snd_seq_event_t *event
        remaining = snd_seq_event_input(self.handle, &event)
        if remaining == -EAGAIN:
            return None
        if remaining < 0:
            raise AlsaError, snd_strerror(remaining)
        return copyEvent(event)

    def output(self, Event event):
        cdef int remaining
        remaining = snd_seq_event_output(self.handle, &event.event)
        if remaining < 0:
            raise AlsaError, snd_strerror(remaining)
        return remaining

    def createPort(self, char *name, int caps, int type=SND_SEQ_PORT_TYPE_APPLICATION):
        cdef int id
        id = snd_seq_create_simple_port(self.handle, name, caps, type)
        if id < 0:
            raise AlsaError, snd_strerror(err)
        return id

    def drainOutput(self):
        cdef int remaining
        remaining = snd_seq_drain_output(self.handle)
        if remaining < 0:
            raise AlsaError, snd_strerror(remaining)
        return remaining

    def registerPoll(self, pollObj, input=False, output=False):
        cdef unsigned count, i
        cdef short events
        cdef pollfd *pfds

        events = 0
        if input:
            events = events | POLLIN
        if output:
            events = events | POLLOUT

        count = snd_seq_poll_descriptors_count(self.handle, events)
        pfds = <pollfd *>malloc(sizeof(pollfd) * count)
        if not pfds:
            raise MemoryError
        try:
            count = snd_seq_poll_descriptors(self.handle, pfds, count, events)
            for i from 0 <= i < count:
                pyevents = 0
                if pfds[i].events & POLLIN:
                    pyevents = pyevents | select.POLLIN
                if pfds[i].events & POLLPRI:
                    pyevents = pyevents | select.POLLPRI
                if pfds[i].events & POLLOUT:
                    pyevents = pyevents | select.POLLOUT
                if pfds[i].events & POLLERR:
                    pyevents = pyevents | select.POLLERR
                if pfds[i].events & POLLHUP:
                    pyevents = pyevents | select.POLLHUP
                if pfds[i].events & POLLNVAL:
                    pyevents = pyevents | select.POLLNVAL
                pollObj.register(pfds[i].fd, pyevents)
        finally:
            free(pfds)

portCapRead = SND_SEQ_PORT_CAP_READ
portCapWrite = SND_SEQ_PORT_CAP_WRITE
portCapDuplex = SND_SEQ_PORT_CAP_DUPLEX
portCapSubsRead = SND_SEQ_PORT_CAP_SUBS_READ
portCapSubsWrite = SND_SEQ_PORT_CAP_SUBS_WRITE

portTypeSpecific = SND_SEQ_PORT_TYPE_SPECIFIC
portTypeMidiGeneric = SND_SEQ_PORT_TYPE_MIDI_GENERIC
portTypeMidiGM = SND_SEQ_PORT_TYPE_MIDI_GM
portTypeMidiGS = SND_SEQ_PORT_TYPE_MIDI_GS
portTypeMidiXG = SND_SEQ_PORT_TYPE_MIDI_XG
portTypeMidiMT32 = SND_SEQ_PORT_TYPE_MIDI_MT32
portTypeSynth = SND_SEQ_PORT_TYPE_SYNTH
portTypeDirectSample = SND_SEQ_PORT_TYPE_DIRECT_SAMPLE
portTypeSample = SND_SEQ_PORT_TYPE_SAMPLE
portTypeApplication = SND_SEQ_PORT_TYPE_APPLICATION


eventTypeNames = {
    SND_SEQ_EVENT_SYSTEM: 'SYSTEM',
    SND_SEQ_EVENT_RESULT: 'RESULT',

    SND_SEQ_EVENT_NOTE: 'NOTE',
    SND_SEQ_EVENT_NOTEON: 'NOTEON',
    SND_SEQ_EVENT_NOTEOFF: 'NOTEOFF',
    SND_SEQ_EVENT_KEYPRESS: 'KEYPRESS',

    SND_SEQ_EVENT_CONTROLLER: 'CONTROLLER',
    SND_SEQ_EVENT_PGMCHANGE: 'PGMCHANGE',
    SND_SEQ_EVENT_CHANPRESS: 'CHANPRESS',
    SND_SEQ_EVENT_PITCHBEND: 'PITCHBEND',
    SND_SEQ_EVENT_CONTROL14: 'CONTROL14',
    SND_SEQ_EVENT_NONREGPARAM: 'NONREGPARAM',
    SND_SEQ_EVENT_REGPARAM: 'REGPARAM',

    SND_SEQ_EVENT_SONGPOS: 'SONGPOS',
    SND_SEQ_EVENT_SONGSEL: 'SONGSEL',
    SND_SEQ_EVENT_QFRAME: 'QFRAME',
    SND_SEQ_EVENT_TIMESIGN: 'TIMESIGN',
    SND_SEQ_EVENT_KEYSIGN: 'KEYSIGN',

    SND_SEQ_EVENT_START: 'START',
    SND_SEQ_EVENT_CONTINUE: 'CONTINUE',
    SND_SEQ_EVENT_STOP: 'STOP',
    SND_SEQ_EVENT_SETPOS_TICK: 'SETPOS_TICK',
    SND_SEQ_EVENT_SETPOS_TIME: 'SETPOS_TIME',
    SND_SEQ_EVENT_TEMPO: 'TEMPO',
    SND_SEQ_EVENT_CLOCK: 'CLOCK',
    SND_SEQ_EVENT_TICK: 'TICK',
    SND_SEQ_EVENT_QUEUE_SKEW: 'QUEUE_SKEW',
    SND_SEQ_EVENT_SYNC_POS: 'SYNC_POS',

    SND_SEQ_EVENT_TUNE_REQUEST: 'TUNE_REQUEST',
    SND_SEQ_EVENT_RESET: 'RESET',
    SND_SEQ_EVENT_SENSING: 'SENSING',

    SND_SEQ_EVENT_ECHO: 'ECHO',
    SND_SEQ_EVENT_OSS: 'OSS',

    SND_SEQ_EVENT_CLIENT_START: 'CLIENT_START',
    SND_SEQ_EVENT_CLIENT_EXIT: 'CLIENT_EXIT',
    SND_SEQ_EVENT_CLIENT_CHANGE: 'CLIENT_CHANGE',
    SND_SEQ_EVENT_PORT_START: 'PORT_START',
    SND_SEQ_EVENT_PORT_EXIT: 'PORT_EXIT',
    SND_SEQ_EVENT_PORT_CHANGE: 'PORT_CHANGE',

    SND_SEQ_EVENT_PORT_SUBSCRIBED: 'PORT_SUBSCRIBED',
    SND_SEQ_EVENT_PORT_UNSUBSCRIBED: 'PORT_UNSUBSCRIBED',

    SND_SEQ_EVENT_USR0: 'USR0',
    SND_SEQ_EVENT_USR1: 'USR1',
    SND_SEQ_EVENT_USR2: 'USR2',
    SND_SEQ_EVENT_USR3: 'USR3',
    SND_SEQ_EVENT_USR4: 'USR4',
    SND_SEQ_EVENT_USR5: 'USR5',
    SND_SEQ_EVENT_USR6: 'USR6',
    SND_SEQ_EVENT_USR7: 'USR7',
    SND_SEQ_EVENT_USR8: 'USR8',
    SND_SEQ_EVENT_USR9: 'USR9',

    SND_SEQ_EVENT_SYSEX: 'SYSEX',
    SND_SEQ_EVENT_BOUNCE: 'BOUNCE',
    SND_SEQ_EVENT_USR_VAR0: 'USR_VAR0',
    SND_SEQ_EVENT_USR_VAR1: 'USR_VAR1',
    SND_SEQ_EVENT_USR_VAR2: 'USR_VAR2',
    SND_SEQ_EVENT_USR_VAR3: 'USR_VAR3',
    SND_SEQ_EVENT_USR_VAR4: 'USR_VAR4',

    SND_SEQ_EVENT_NONE: 'NONE',
}

eventTypeValues = {}
for value, name in eventTypeNames.iteritems():
    eventTypeValues[name] = value
del value, name


controllerNames = {
    0:   'Bank Select (coarse)',
    1:   'Modulation Wheel (coarse)',
    2:   'Breath controller (coarse)',
    4:   'Foot Pedal (coarse)',
    5:   'Portamento Time (coarse)',
    6:   'Data Entry (coarse)',
    7:   'Volume (coarse)',
    8:   'Balance (coarse)',
    10:  'Pan position (coarse)',
    11:  'Expression (coarse)',
    12:  'Effect Control 1 (coarse)',
    13:  'Effect Control 2 (coarse)',
    16:  'General Purpose Slider 1',
    17:  'General Purpose Slider 2',
    18:  'General Purpose Slider 3',
    19:  'General Purpose Slider 4',
    32:  'Bank Select (fine)',
    33:  'Modulation Wheel (fine)',
    34:  'Breath controller (fine)',
    36:  'Foot Pedal (fine)',
    37:  'Portamento Time (fine)',
    38:  'Data Entry (fine)',
    39:  'Volume (fine)',
    40:  'Balance (fine)',
    42:  'Pan position (fine)',
    43:  'Expression (fine)',
    44:  'Effect Control 1 (fine)',
    45:  'Effect Control 2 (fine)',
    64:  'Hold Pedal (on/off)',
    65:  'Portamento (on/off)',
    66:  'Sustenuto Pedal (on/off)',
    67:  'Soft Pedal (on/off)',
    68:  'Legato Pedal (on/off)',
    69:  'Hold 2 Pedal (on/off)',
    70:  'Sound Variation',
    71:  'Sound Timbre',
    72:  'Sound Release Time',
    73:  'Sound Attack Time',
    74:  'Sound Brightness',
    75:  'Sound Control 6',
    76:  'Sound Control 7',
    77:  'Sound Control 8',
    78:  'Sound Control 9',
    79:  'Sound Control 10',
    80:  'General Purpose Button 1 (on/off)',
    81:  'General Purpose Button 2 (on/off)',
    82:  'General Purpose Button 3 (on/off)',
    83:  'General Purpose Button 4 (on/off)',
    91:  'Effects Level',
    92:  'Tremulo Level',
    93:  'Chorus Level',
    94:  'Celeste Level',
    95:  'Phaser Level',
    96:  'Data Button increment',
    97:  'Data Button decrement',
    98:  'Non-registered Parameter (fine)',
    99:  'Non-registered Parameter (coarse)',
    100: 'Registered Parameter (fine)',
    101: 'Registered Parameter (coarse)',
    120: 'All Sound Off',
    121: 'All Controllers Off',
    122: 'Local Keyboard (on/off)',
    123: 'All Notes Off',
    124: 'Omni Mode Off',
    125: 'Omni Mode On',
    126: 'Mono Operation',
    127: 'Poly Operation',
}

__version__ = '0.1'
