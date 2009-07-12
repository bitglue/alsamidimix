from distutils.core import setup
from distutils.extension import Extension
from Pyrex.Distutils import build_ext
setup(
  name = "Alsa Sequencer for Python",
  ext_modules=[ 
    Extension("alsaseq", ["alsaseq.pyx"], libraries = ["asound"]),
    Extension("alsamixer", ["alsamixer.pyx"], libraries = ["asound"]),
    ],
  cmdclass = {'build_ext': build_ext}
)
