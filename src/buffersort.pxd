cimport cython
cimport cpython.array

cimport numpy as cnp

# Fused type definition mimicking Haskell's Ord typeclass.
# These are base datatypes permitted in buffers seeking to be sorted.
ctypedef fused Ord:
    # Basic types
    bytes
    cython.int
    cython.sint
    cython.uint
    cython.char
    cython.uchar
    cython.long
    cython.ulong
    cython.slong
    cython.longlong
    cython.slonglong
    cython.short
    cython.sshort
    cython.float
    cython.double
    cython.longdouble
    

cdef  int _partition(Ord[:] buf, int start, int end)
cdef void _swap(Ord[:] buf, int i, int j)
cdef void _sift_up(Ord[:] buf, int n)
cdef void _sift_down(Ord key, Ord[:] buf, int root, int last)
cdef void _selection_sort(Ord[:] buf, int size)
cdef void _insertion_sort(Ord[:] buf, int size)
cdef void _quick_sort(Ord[:] buf, int start, int end)
cdef void _heap_sort(Ord[:] buf, int size)
