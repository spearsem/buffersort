import sys
import copy
import unittest
import numpy as np

from array import array
from generate_tests import generate_test_arrays

from .. import buffersort as bsort_py
from .. cimport buffersort as bsort_cy

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
        self.sort_msg = "%s failed for a (%s) buffer of data type %s: \n%s"

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

        # Other test data for helper methods.
        


################################
# C tests for helper functions #
################################
#    
#    def test__partition(self):
#        pass
#
#    def test__swap(self):
#        pass
#
#    def test__sift_up(self):
#        pass
#
#    def test__sift_down(self):
#        pass
#
######################################
# C tests for C level sort functions #
######################################
#
#    def _generic_c_sort_test(self, sort_name):
#        for type_name, arrays in self.test_cases.items():
#            test_copies = copy.deepcopy(arrays)
#            sort_fn = getattr(bsort_c, sort_name)
#            map(sort_fn, test_copies)
#            self.assertEqual(test_copies, 
#                             self.test_truth[type_name],
#                             self.sort_msg%(sort_name, type_name))
#
#    def test__selection_sort(self):
#        self._generic_c_sort_test("selection_sort")
#
#    def test__insertion_sort(self):
#        self._generic_c_sort_test("insertion_sort")
#
#    def test__quick_sort(self):
#        self._generic_c_sort_test("quick_sort")
#
#    def test__heap_sort(self):
#        self._generic_c_sort_test("heap_sort")
#
#


#####################
# Pure Python tests #
#####################

    def _generic_py_sort_test(self, sort_name):

        # Get a handle to the Python-layer sort function, accessible from the
        # *python* import of the buffersort package.
        sort_fn = getattr(bsort_py, sort_name)

        # For each test case, do sort mutation and check correctness.
        for type_name in self.test_cases:
            
            # Make copies to test sorting as mutation side effect.
            test_copies = copy.deepcopy(self.test_cases[type_name])
            test_truth = self.test_truth[type_name]

            # Mutate the copies with the sorting algorithm.
            for t in test_copies:
                sort_fn(t)

            # Assert that mutated copies match ground truth sorted data.
            for i, case in enumerate(test_copies):
                
                err_msg = self.sort_msg%(sort_name, 
                                         type(case), 
                                         type_name, 
                                         case)

                # Note that assertSequenceEqual fails for numpy arrays, so
                # workaround with a list of the contents.
                if isinstance(case, np.ndarray):
                    self.assertSequenceEqual(list(case), 
                                             list(test_truth[i]),
                                             err_msg)
                else:
                    self.assertSequenceEqual(case, test_truth[i], err_msg)
                    


    #########################################################################
    # Simple wrappers to test each buffersort Python-layer sort function by #
    # name.                                                                 #
    #########################################################################
    def test_selection_sort(self):
        self._generic_py_sort_test("selection_sort")

    def test_insertion_sort(self):
        self._generic_py_sort_test("insertion_sort")

    def test_quick_sort(self):
        self._generic_py_sort_test("quick_sort")

    def test_heap_sort(self):
        self._generic_py_sort_test("heap_sort")


def run_tests(alert=False):
    """
    Executes suite of `buffersort` unit tests. Optional argument `alert` 
    (default False) can be set to any value with truthiness of True in order to
    cause this function to invoke sys.exit with a return code of 0 if tests all
    pass and a return code of 1 otherwise.
    """
    test_suite = unittest.TestLoader().loadTestsFromTestCase(TestBufferSort)
    result = unittest.TextTestRunner(verbosity=3).run(test_suite)
    if alert:
        exit_code = 1 - int(result.wasSuccessful())
        sys.exit(exit_code)

    
if __name__ == "__main__":
    unittest.main()



