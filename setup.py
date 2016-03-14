import os
import numpy as np

from distutils.core import setup, Extension
from Cython.Build import cythonize
from Cython.Distutils import build_ext

# Search recursively in local source directory for Cython extension files.
def findExtFiles(srcDir, files=[]):
    for each_file in os.listdir(srcDir):
        path = os.path.join(srcDir, each_file)
        if os.path.isfile(path) and path.endswith(".pyx"):
            files.append(path.replace(os.path.sep, ".")[:-4])
        elif os.path.isdir(path):
            files = files + findExtFiles(path)
    return files

# Make an OS-agnostic extension from a Cython extension path.
def mkExt(extName):
    extPath = extName.replace(".", os.path.sep) + ".pyx"
    return Extension(extName,
                     [extPath],
                     include_dirs=[np.get_include(), "."],
                     extra_compile_agrs=["-O3", "-Wall"])




extNames = findExtFiles("buffersort")
extensions = list(map(mkExt, extNames))

setup(

    # Basic library identification parameters
    name         = 'buffersort',
    version      = '0.0.3',
    description  = ('Provide a variety of sorting algorithms that operate '
                    'in-place on types that implement the Python buffer '
                    'protocol.'),

    # Cython extension build instructions
    packages     = ["buffersort", "buffersort.test"],
    cmdclass     = {'build_ext':build_ext},
    ext_modules  = extensions,
    
    # Detailed package info for PyPI.
    author       = 'Ely M. Spears',
    author_email = 'spearsem+buffersort@gmail.com',
    url          = 'https://github.com/spearsem/buffersort', 
    download_url = 'https://github.com/spearsem/buffersort/tarball/0.0.3', 
    keywords     = ['cython', 'memoryview', 'sorting', 'fused-types'], 
    classifiers  = []
)
  
