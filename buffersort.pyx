cimport cython
ctypedef fused Ord:
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

# Utility functions 
cdef void _swap(Ord[:] buf, int i, int j):
    """
    Swap elements i and j in buffer buf.
    """
    cdef Ord temp = buf[i]
    buf[i] = buf[j]
    buf[j] = temp

cdef int _partition(Ord[:] buf, int start, int end):
    cdef:
        int j
        int num_lower = start
        Ord position_val = buf[start]
    for j in range(start+1, end+1):
        if (buf[j] < position_val):
            num_lower += 1
            _swap(buf, num_lower, j)
    _swap(buf, start, num_lower)
    return num_lower

cdef void _sift_up(Ord[:] buf, int n):
    cdef:
        Ord sift_item = buf[n]
        int child = n
        int parent = (child - 1) / 2
    while parent >= 0:
        if sift_item <= buf[parent]:
            break
        buf[child] = buf[parent]
        child = parent
        parent = (child - 1) / 2
    buf[child] = sift_item

cdef void _sift_down(Ord key, Ord[:] buf, int root, int last):
    cdef:
        int child = 2 * root + 1;
    while child <= last:
        if child < last:
            if buf[child+1] > buf[child]:
                child += 1
        if key >= buf[child]:
            break
        buf[root] = buf[child]
        root = child
        child = 2*root + 1
    buf[root] = key

# Selection sort 
cdef void _selection_sort(Ord[:] buf, int size):
    cdef:
        int i, j, min_loc
    for i in range(size-1):
        min_loc = i
        for j in range(i+1, size):
            if (buf[j] < buf[min_loc]):
                min_loc = j
        _swap(buf, i, min_loc)

def selection_sort(Ord[:] sortable):
    """
    Apply selection sort to sort buffer-supporting type `sortable`. The base
    data type stored in `sortable` must be a member of the `Ord` fused type as
    defined in cylib_sort.pyx.
    """
    cdef Ord[:] buf = sortable
    _selection_sort(buf, len(buf))

# Insertion sort 
cdef void _insertion_sort(Ord[:] buf, int size):
    cdef:
        int j, k
        Ord temp
    for k in range(1, size):
        j = k - 1
        temp = buf[k]
        while (j >= 0) & (temp < buf[j]):
            buf[j+1] = buf[j] 
            j = j - 1
        buf[j+1] = temp

def insertion_sort(Ord[:] sortable):
    """
    Apply insertion sort to sort buffer-supporting type `sortable`. The base
    data type stored in `sortable` must be a member of the `Ord` fused type as
    defined in cylib_sort.pyx.
    """
    cdef Ord[:] buf = sortable
    _insertion_sort(buf, len(buf))

# Quick sort
cdef void _quick_sort(Ord[:] buf, int start, int end):
    cdef int partition_point
    if start < end:
        partition_point = _partition(buf, start, end)
        _quick_sort(buf, start, partition_point-1)
        _quick_sort(buf, partition_point+1, end)

def quick_sort(Ord[:] sortable):
    cdef Ord[:] buf = sortable
    _quick_sort(buf, 0, len(buf)-1)

# Heap sort
cdef void _heap_sort(Ord[:] buf, int size):
    cdef: 
        int k = (size/2) - 1
        Ord item
    while k >= 0:
        _sift_down(buf[k], buf, k, size-1)
        k -= 1
    for k in range(size-1, 0, -1):
        item = buf[k]
        buf[k] = buf[0]
        _sift_down(item, buf, 0, k-1)

def heap_sort(Ord[:] sortable):
    """
    Apply heap sort to sort buffer-supporting type `sortable`. The base
    data type stored in `sortable` must be a member of the `Ord` fused type as
    defined in cylib_sort.pyx.
    """
    cdef Ord[:] buf = sortable
    _heap_sort(buf, len(buf))

