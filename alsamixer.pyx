cdef extern from 'Python.h':
    ctypedef struct PyInterpreterState
    ctypedef struct PyThreadState:
        PyInterpreterState *interp
    PyThreadState* PyThreadState_New(PyInterpreterState *interp)
    PyThreadState* PyThreadState_Get()
    void PyThreadState_Delete(PyThreadState *tstate)
    PyThreadState* PyThreadState_Swap(PyThreadState *tstate)

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

cdef extern from 'alsa/asoundlib.h':
    ctypedef struct snd_mixer_t
    ctypedef struct snd_mixer_selem_id_t
    cdef struct snd_mixer_selem_regopt
    ctypedef struct snd_mixer_class_t
    ctypedef struct snd_mixer_elem_t
    ctypedef int (*snd_mixer_callback_t)(snd_mixer_t *ctl, unsigned int mask, snd_mixer_elem_t *elem)
    ctypedef int (*snd_mixer_elem_callback_t)(snd_mixer_elem_t *elem, unsigned int mask)
    ctypedef enum snd_mixer_selem_channel_id_t:
        SND_MIXER_SCHN_UNKNOWN
        SND_MIXER_SCHN_FRONT_LEFT
        SND_MIXER_SCHN_FRONT_RIGHT
        SND_MIXER_SCHN_FRONT_CENTER
        SND_MIXER_SCHN_REAR_LEFT
        SND_MIXER_SCHN_REAR_RIGHT
        SND_MIXER_SCHN_WOOFER
        SND_MIXER_SCHN_LAST
        SND_MIXER_SCHN_MONO

    int snd_mixer_open(snd_mixer_t **mixerp, int mode)
    int snd_mixer_attach(snd_mixer_t *mixer, char *name)
    int snd_mixer_load(snd_mixer_t *mixer)
    snd_mixer_elem_t *snd_mixer_find_selem(snd_mixer_t *mixer, snd_mixer_selem_id_t *id)
    int snd_mixer_poll_descriptors_count(snd_mixer_t *mixer)
    int snd_mixer_poll_descriptors(snd_mixer_t *mixer, pollfd *pfds, unsigned int space)
    void snd_mixer_set_callback(snd_mixer_t *obj, snd_mixer_callback_t val)
    void snd_mixer_elem_set_callback(snd_mixer_elem_t *obj, snd_mixer_elem_callback_t val)
    void snd_mixer_set_callback_private(snd_mixer_t *mixer, void *val)
    void snd_mixer_elem_set_callback_private(snd_mixer_elem_t *mixer, void *val)
    void *snd_mixer_get_callback_private(snd_mixer_t *mixer)
    void *snd_mixer_elem_get_callback_private(snd_mixer_elem_t *mixer)
    int snd_mixer_handle_events(snd_mixer_t *mixer)

    void snd_mixer_selem_id_set_name(snd_mixer_selem_id_t *obj, char *val)
    void snd_mixer_selem_id_set_index(snd_mixer_selem_id_t *obj, unsigned val)
    int snd_mixer_selem_id_malloc(snd_mixer_selem_id_t **ptr)
    int snd_mixer_selem_id_free(snd_mixer_selem_id_t *ptr)
    char *snd_mixer_selem_get_name(snd_mixer_elem_t *elem)
    unsigned snd_mixer_selem_get_index(snd_mixer_elem_t *elem)
    int snd_mixer_selem_register(snd_mixer_t *mixer, snd_mixer_selem_regopt *options, snd_mixer_class_t **classp)
    int snd_mixer_selem_set_playback_volume_all(snd_mixer_elem_t *elem, long value)
    int snd_mixer_selem_get_playback_volume_range(snd_mixer_elem_t *elem, long *min, long *max)
    int snd_mixer_selem_get_playback_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long *value)

    char *snd_strerror(int errnum)


import select, sets
callbacks = sets.Set()

cdef PyInterpreterState *mainInterpreter
mainInterpreter = PyThreadState_Get().interp


class AlsaError(Exception):
    pass


cdef int mixer_event_callback(snd_mixer_t *mixer, unsigned mask, snd_mixer_elem_t *elem):
    return 0


cdef class Mixer:
    cdef snd_mixer_t *handle

    def __init__(self, int mode=0):
        cdef int err
        err = snd_mixer_open(&self.handle, mode)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def setCallback(self, c):
        if not callable(c):
            raise TypeError, 'callback must be a callable taking arguments (mixer, element).'
        callbacks.add(c)
        snd_mixer_set_callback_private(self.handle, <void *>c)
        snd_mixer_set_callback(self.handle, mixer_event_callback)

    def handleEvents(self):
        cdef int err
        err = snd_mixer_handle_events(self.handle)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def attach(self, char *name):
        cdef int err
        err = snd_mixer_attach(self.handle, name)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def load(self):
        cdef int err
        err = snd_mixer_load(self.handle)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def registerSimpleElement(self):
        cdef int err
        err = snd_mixer_selem_register(self.handle, NULL, NULL)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    def registerPoll(self, pollObj):
        cdef unsigned count, i
        cdef pollfd *pfds

        count = snd_mixer_poll_descriptors_count(self.handle)
        pfds = <pollfd *>malloc(sizeof(pollfd) * count)
        if not pfds:
            raise MemoryError
        try:
            count = snd_mixer_poll_descriptors(self.handle, pfds, count)
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


cdef class Element:
    cdef snd_mixer_elem_t *element

    def __init__(self, Mixer mixer, char *name, unsigned index=0):
        cdef snd_mixer_selem_id_t *id

        snd_mixer_selem_id_malloc(&id)
        try:
            snd_mixer_selem_id_set_name(id, name)
            snd_mixer_selem_id_set_index(id, index)

            self.element = snd_mixer_find_selem(mixer.handle, id)
            if not self.element:
                raise AlsaError, 'could not find mixer element "%s",%i' % (name, index)
        finally:
            snd_mixer_selem_id_free(id)

    def setCallback(self, c):
        if not callable(c):
            raise TypeError, 'callback must be a callable taking arguments (element).'
        callbacks.add(c)
        snd_mixer_elem_set_callback_private(self.element, <void *>c)
        snd_mixer_elem_set_callback(self.element, elem_event_callback)

    property name:
        def __get__(self):
            return snd_mixer_selem_get_name(self.element)

    property index:
        def __get__(self):
            return snd_mixer_selem_get_index(self.element)

    def getPlaybackVolume(self):
        cdef int err
        cdef long value
        err = snd_mixer_selem_get_playback_volume(self.element, SND_MIXER_SCHN_MONO, &value)
        if err < 0:
            raise AlsaError, snd_strerror(err)
        return value

    def setPlaybackVolumeAll(self, long value):
        cdef int err
        err = snd_mixer_selem_set_playback_volume_all(self.element, value)
        if err < 0:
            raise AlsaError, snd_strerror(err)

    property playbackVolumeRange:
        def __get__(self):
            cdef long min, max
            snd_mixer_selem_get_playback_volume_range(self.element, &min, &max)
            return (min, max)


cdef int elem_event_callback(snd_mixer_elem_t *elementHandle, unsigned mask):
    cdef PyThreadState *tstate, *origState
    cdef void *voidCallback
    cdef object callback
    cdef Element element
    cdef int status

    voidCallback = snd_mixer_elem_get_callback_private(elementHandle)
    if voidCallback == NULL:
        return 0
    callback = <object>voidCallback

    element = Element.__new__(Element)
    element.element = elementHandle

    tstate = PyThreadState_New(mainInterpreter)
    origState = PyThreadState_Swap(tstate)

    try:
        callback(element)
        status = 0
    except:
        print 'ignoring unhandled exception in element callback:'
        import traceback
        traceback.print_exc()
        status = -1

    PyThreadState_Swap(origState)
    PyThreadState_Delete(tstate)
    return status
