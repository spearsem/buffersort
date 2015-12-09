from distutils.core import setup, Extension
from Cython.Build import cythonize

ext = Extension("buffersort", sources=["buffersort.pyx"])
setup(name="buffersort", ext_modules=cythonize([ext]))
