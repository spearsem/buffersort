import os
import numpy as np

from distutils.core import setup, Extension
from Cython.Build import cythonize
from Cython.Distutils import build_ext

def findExtFiles(srcDir, files=[]):
    for each_file in os.listdir(srcDir):
        path = os.path.join(srcDir, each_file)
        if os.path.isfile(path) and path.endswith(".pyx"):
            files.append(path.replace(os.path.sep, ".")[:-4])
        elif os.path.isdir(path):
            files = files + findExtFiles(path)
    return files

def mkExt(extName):
    extPath = extName.replace(".", os.path.sep) + ".pyx"
    return Extension(extName,
                     [extPath],
                     include_dirs=[np.get_include(), "."],
                     extra_compile_agrs=["-O3", "-Wall"])

extNames = findExtFiles("buffersort")
extensions = map(mkExt, extNames)

setup(name="buffersort",
      packages=["buffersort", "buffersort.test"],
      ext_modules=extensions,
      cmdclass={'build_ext':build_ext})
