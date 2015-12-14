import unittest
import numpy as np

from array import array
from generate_tests import generate_test_arrays

from .. import buffersort as bsort_py
from .. cimport buffersort as bsort_c

class TestBufferSort(unittest.TestCase):
    """
    Test buffersort code.
    """
    def setUp(self):
        """
        Prepare data for test cases. Test cases are generated randomly for
        each type that may appear as the base type of the underlying 
        memoryview, as defined by the Cython fused type `Ord` in 
        buffersort.pxd. Set up parameters controlling the size of each test 
        case and the range of values from which to draw are used to customize 
        test behavior.
        """
        self.cases_per_type = 10
        self.size_per_case = 25
        self.int_range = (-100, 100)
        self.uint_range = (0, 100)
        self.char_range = (0, 255)
        self.double_range = (-100.0, 100.0)

        tc, tr = generate_test_arrays(self.int_range, 
                                      self.uint_range, 
                                      self.char_range, 
                                      self.double_range, 
                                      self.size_per_case,
                                      self.cases_per_type)

        # These are dictionaries with types as keys and lists-of-buffers as 
        # values. For some type t, self.test_truth[t][i] is the sorted version
        # of self.test_cases[t][i], using NumPy `sort` as the base sort 
        # algorithm
        self.test_cases = tc
        self.test_truth = tr

###########
# C tests #
###########
    
    def test__partition(self):
        pass

    def test__swap(self):
        pass

    def test__sift_up(self):
        pass

    def test__sift_down(self):
        pass

    def test__selection_sort(self):
        pass

    def test__insertion_sort(self):
        pass

    def test__quick_sort(self):
        pass

    def test__heap_sort(self):
        pass



#####################
# Pure Python tests #
#####################

    def test_selection_sort(self):
        pass

    def test_insertion_sort(self):
        pass

    def test_quick_sort(self):
        pass

    def test_heap_sort(self):
        pass
    


if __name__ == "__main__":
    unittest.main()



