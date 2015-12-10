"""
Implementations of various in-place sorting algorithms to work on types 
implementing the Python buffer protocol. Code is based on the algorithms
described in `Data Structures in C` by Noel Kalicharan unless otherwise
documented.
"""
# Declarations in buffersort.pxd

cdef int _partition(Ord[:] buf, int start, int end):
    """
    Pivot buffer buf between indices start and end, using the value at index
    start as the pivot value. Returns the integer corresponding to the number
    of elements smaller than the pivot value, which also expresses the index
    location of the modified buffer where the pivot value resides. This is used
    by the quick sort algorithm to partition into lesser and greater halves.
    """
    # TODO: consider choosing a random position for the pivot.
    cdef:
        int j
        int num_lower = start
        Ord pivot_val = buf[start]
    # num_lower serves two roles:
    # 1. denoting how many items are seen to be lesser than pivot_val
    # 2. denoting how many indices from `start` can be used for placement of
    #    the lesser values.

    # Move alone the buffer between the two boundary positions.
    for j in range(start+1, end+1):

        # When a value lesser than the pivot is seen, it can be moved to the
        # front of the list. The exact placement is determined by how many
        # lesser values have already been seen.
        if (buf[j] < pivot_val):
            num_lower += 1           
            _swap(buf, num_lower, j) 

    # After the whole buffer has been searched for lesser values, we can take
    # whatever was the "final" such lesser value and swap it to the front, so
    # that the pivot value takes its place. This ensures everything to the left
    # of the pivot value is lesser, and everything to the right is greater or
    # equal.
    _swap(buf, start, num_lower)

    # Return the position that the pivot value was placed into.
    return num_lower

cdef void _swap(Ord[:] buf, int i, int j):
    """
    Swap elements i and j in buffer buf.
    """
    cdef Ord temp = buf[i]
    buf[i] = buf[j]
    buf[j] = temp

cdef void _sift_up(Ord[:] buf, int n):
    """
    Take the element stored at position `n` inside `buf` and insert it into
    `buf[0:n]` such that the heap property is preserved. Note that this 
    assumes the total length of the buffer is n+1, where the extra space was
    created specifically to append a new element to the end of buffer and to
    do an in-place heap insert via this function.
    """
    
    cdef:
        # By convention, the item stored at index n will be "inserted" into
        # the buffer[0:n] in such a manner as to preserve the heap property.
        Ord sift_item = buf[n] # Convention 

        int child = n          
        int parent = (child - 1) / 2 # In heap notation, the parent of node n
                                     # is found at index (n-1)/2

    # Loop until no more potential parent nodes can be found.
    while parent >= 0:

        # If the value to store is lesser than the value at parent, then the
        # value is appropriate as a child for that parent, so we break out for
        # assignment.
        if sift_item <= buf[parent]:
            break

        # Otherwise, swap the thing currently known as 'parent' into the
        # current space for 'child'. 
        buf[child] = buf[parent]

        # Change the index for 'child' to become the index previously used by 
        # 'parent', and re-calculate the new index for 'parent'.
        child = parent           
        parent = (child - 1) / 2

    # Once we've broken, it means the insert item is acceptable as a child at
    # the current 'child' location.
    buf[child] = sift_item

cdef void _sift_down(Ord key, Ord[:] buf, int root, int last):
    """
    Move a heap node further down towards the heap leaves, while swapping other
    nodes into its place as necessary, to ensure the heap property is preserved
    within the sub-heap starting at `root` and going no further than `last`.
    
    When used for heap sort, thr sift down algorithm is typically applied 
    starting at the final non-lead node. When the non-leaf node is processed,
    any leaf children it has will also be sifted into the correct order. Then
    the algorithm moves on to the next non-leaf node, and continues working 
    back to the very root of the entire heap. Thus, elements that occur further 
    up the heap will be processed and migrated downward only after the entire 
    sub-heap they will be moved into has been appropriately processed.
    """
    cdef:
        int child = 2 * root + 1

    # Iterate while we have not hit a leaf node descending down in this part of
    # the heap.
    while child <= last:
        
        # If `child` is strictly less than `last`, then `child` has a sibling
        # node that is also a child of the same parent. This node must also be
        # considered as a potential place to swap `key` into.
        if child < last:

            # If `child+1` contains the larger value, make `child` refer to it
            # instead.
            if buf[child+1] > buf[child]:
                child += 1

        # If the value to insert is greater than the greatest child, then it is
        # acceptable to be inserted as the parent of that child, so we can break
        # out of the loop for assignment.
        if key >= buf[child]:
            break

        # Otherwise, `key` will end up as a child, or even furthe down, beneath
        # what is currently called `child`. So we move `child` into `root` 
        # position, change `root` to reflect that it is `child` now, and we compute
        # a new child based on the new root (it will be `child`'s child).
        buf[root] = buf[child]
        root = child
        child = 2*root + 1

    # Once we've found a place where `key` is greater than the children nodes, we
    # place the value `key` there, knowing that the above loop has been pushing
    # any displaced values up the heap as necessary.
    buf[root] = key

cdef void _selection_sort(Ord[:] buf, int size):
    """
    Iteratively find the location of the minimum entry of the tails of the
    array, swapping the value from the minimum location with the value from
    the current iteration's index. 
    """
    cdef:
        int i, j, min_loc

    for i in range(size-1):
        min_loc = i # Initialize the min location.
        
        # Update the min location by examining the tail of the array.
        for j in range(i+1, size):
            if (buf[j] < buf[min_loc]):
                min_loc = j

        # Once min location is known, swap it into the current position.
        _swap(buf, i, min_loc)

def selection_sort(Ord[:] sortable):
    """
    Apply selection sort to sort buffer-supporting type `sortable`. The base 
    data stored in `sortable` must be a member of the Cython `Ord` fused type.
    """
    if sortable:
        cdef Ord[:] buf = sortable
        _selection_sort(buf, len(buf))

cdef void _insertion_sort(Ord[:] buf, int size):
    """
    Move linearly through an array and at each index, move left-ward to find
    a location where the current array element would be in sorted position,
    and move it there (swapping all other elements 1 space to the right to make
    room).
    """
    cdef:
        int j, k
        Ord temp
    
    # Starting from the second array position, move through the array to check
    # how far left each value must be shifted to get into sorted order.
    for j in range(1, size):
        k = j - 1      # Begin examining at one index left of j.
        temp = buf[j]  # Store temp of element in case it must be moved.
        
        # For all index positions lesser than j, check if the value
        # is greater than temp. If so, migrate the value to the right by
        # one position.
        while (k >= 0) & (temp < buf[k]):
            buf[k+1] = buf[k] 
            k = k - 1

        # If we've reached the beginning of the array, or else some position
        # at which temp is greater than the element at that position, then we
        # place temp, guaranteeing that everything to the left of temp will be
        # lesser.
        buf[k+1] = temp

def insertion_sort(Ord[:] sortable):
    """
    Apply insertion sort to sort buffer-supporting type `sortable`. The base 
    data stored in `sortable` must be a member of the Cython `Ord` fused type.
    """
    if sortable:
        cdef Ord[:] buf = sortable
        _insertion_sort(buf, len(buf))

cdef void _quick_sort(Ord[:] buf, int start, int end):
    """
    Use _partition algorithm to separate an array into lesser and greater
    halves with respect to a pivot element, and recursively use quick sort
    to sort the halves.
    """
    cdef int partition_point
    if start < end:
        # Obtain the position where pivot value is moved in array.
        partition_point = _partition(buf, start, end)

        # Recursively sort the subset of the array to the left and right of
        # the pivot location, respectively.
        _quick_sort(buf, start, partition_point-1)
        _quick_sort(buf, partition_point+1, end)

def quick_sort(Ord[:] sortable):
    """
    Apply quick sort to sort buffer-supporting type `sortable`. The base data
    stored in `sortable` must be a member of the Cython `Ord` fused type.
    """
    if sortable:
        cdef Ord[:] buf = sortable
        _quick_sort(buf, 0, len(buf)-1)


cdef void _heap_sort(Ord[:] buf, int size):
    """
    Sort buffer using heap sort algorithm. First the buffer is rearranged to
    satisfy the heap property. Then it is sorted from the end of the array to
    the beginning, by repeatedly swapping the heap-based maximum (which will
    be at index zero) into the end of the array, and then re-inserting the
    value it displaces back into the front of the array in such a way as to
    preserve the heap property.
    """

    cdef: 
        int k = (size/2) - 1 # Position of the final non-leaf node.
        Ord item             # Temp space for items swapped out of last node.

    # Starting from final non-leaf node and moving backward, migrate the node
    # downward into the heap using sift down algorithm to preserve heap 
    # property as you go. At the end of this, the buffer will satisfy the heap
    # property but may not yet be a sorted heap.
    while k >= 0:
        _sift_down(buf[k], buf, k, size-1)
        k -= 1

    # Starting at the very final node, swap the largest element (which by heap
    # property must be in position 0) into the final position. Index `k` here
    # keeps track of the current "last" unsorted position in the array.
    for k in range(size-1, 0, -1):
        
        # Keep a temporary copy of whatever is in current "last" location.
        item = buf[k]   

        # Move the biggest element, from index 0 to the current "last" index.
        buf[k] = buf[0]

        # item must now find a new home somewhere between index 0 and k-1. Find
        # that home in such a way as to preserve the heap property (e.g. with
        # sift down algorithm), and then on the next iteration the same trick of
        # swapping entry 0 to the end will work for sorting.
        _sift_down(item, buf, 0, k-1)

def heap_sort(Ord[:] sortable):
    """
    Apply heap sort to sort buffer-supporting type `sortable`. The base data
    stored in `sortable` must be a member of the Cython `Ord` fused type.
    """
    if sortable:
        cdef Ord[:] buf = sortable
        _heap_sort(buf, len(buf))

