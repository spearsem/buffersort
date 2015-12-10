import unittest
import numpy as np
from array import array

from .. import buffersort as bsort_py
from .. cimport buffersort as bsort_c

np.random.seed(0)

class TestBufferSort(unittest.TestCase):
    """
    Test buffersort code.
    """
    def setUp(self):
        """
        Prepare data for test cases.
        """
        
        empty = []
        
        # ints, shorts, longs, and longlongs
        sorted_ints_even = [1, 2, 3, 4]
        sorted_ints_odd = [1, 2, 3, 4, 5]

        antisorted_ints_even = [4, 3, 2, 1]
        antisorted_ints_odd = [5, 4, 3, 2, 1]

        random_ints_even = np.asarray(np.random.randint(10, size=10), dtype=np.int32)
        random_ints_odd = np.asarray(np.random.randint(10, size=11), dtype=np.int32)

        constant_ints_even = [1, 1, 1, 1, 1]
        constant_ints_odd = [1, 1, 1, 1, 1]

        # doubles and longdoubles
        sorted_doubles_even = [1.1, 2.2, 3.3, 4.4]
        sorted_doubles_odd = [1.1, 2.2, 3.3, 4.4, 5.5]

        antisorted_doubles_even = [4.4, 3.3, 2.2, 1.1]
        antisorted_doubles_odd = [5.5, 4.4, 3.3, 2.2, 1.1]

        random_doubles_even = np.random.rand()
        random_doubles_odd = np.random.rand()

        large_doubles_even = 1000000 * np. random.rand()
        large_doubles_odd = 1000000 * np. random.rand()

        # Chars
        
        
        

###########
# C tests #
###########
    
    def test__partition(Ord[:] buf, int start, int end):
        pass

    def test__swap(Ord[:] buf, int i, int j):
        pass

    def test__sift_up(Ord[:] buf, int n):
        pass

    def test__sift_down(Ord key, Ord[:] buf, int root, int last):
        pass

    def test__selection_sort(Ord[:] buf, int size):
        pass

    def test__insertion_sort(Ord[:] buf, int size):
        pass

    def test__quick_sort(Ord[:] buf, int start, int end):
        pass

    def test__heap_sort(Ord[:] buf, int size):
        pass



#####################
# Pure Python tests #
#####################

    def test_selection_sort(Ord[:] buf, int size):
        pass

    def test_insertion_sort(Ord[:] buf, int size):
        pass

    def test_quick_sort(Ord[:] buf, int start, int end):
        pass

    def test_heap_sort(Ord[:] buf, int size):
        pass
    


if __name__ == "__main__":
    unittest.main()



