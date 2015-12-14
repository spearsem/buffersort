import numpy as np
from array import array

np.random.seed(0)

_INT_TYPES = (np.int8, np.int16, np.int32, np.int64)
_UNSIGNED_INT_TYPES = (np.uint16, np.uint32, np.uint64)
_CHAR_TYPES = (np.uint8,)
_FLOAT_TYPES = (np.double, np.float16, np.float32, np.float64, np.float128)

# Map type names to the codes required by array.array
_INT_TYPECODE_MAP = {np.int8:'b',
                     np.uint8:'B',
                     np.int16:'h',
                     np.uint16:'H',
                     np.int32:'l',
                     np.uint32:'L'}

_CHAR_TYPECODE_MAP = {np.uint8:'c'}

_FLOAT_TYPECODE_MAP = {np.float:'f',
                       np.float32:'f',
                       np.float64:'d',
                       np.double:'d'}

_DTYPES = _INT_TYPES + _UNSIGNED_INT_TYPES + _CHAR_TYPES + _FLOAT_TYPES

def make_random_int_nparray(val_range, size, dtype):
    a = np.asarray(np.random.randint(*val_range, size=size), dtype=dtype)
    s_a = np.sort(a)
    return (a, s_a)

def make_random_char_nparray(val_range, size, dtype):
    return make_random_int_nparray(val_range, size, dtype)

def make_random_float_nparray(val_range, size, dtype):
    a = np.asarray(np.random.rand(size), dtype=dtype)
    a = val_range[0] + 2*val_range[1]*a
    s_a = np.sort(a)
    return (a, s_a)

def make_random_int_array(val_range, size, dtype):
    if dtype not in _INT_TYPECODE_MAP:
        raise ValueError("Data type not supported for array.array: %s"%(dtype))

    a, s_a = make_random_int_nparray(val_range, size, dtype)
    arr = array(_INT_TYPECODE_MAP[dtype], a.tolist())
    s_arr = array(_INT_TYPECODE_MAP[dtype], s_a.tolist())
    return (arr, s_arr)
    
def make_random_char_array(val_range, size, dtype):
    if dtype not in _CHAR_TYPECODE_MAP:
        raise ValueError("Data type not supported for array.array: %s"%(dtype))

    a, s_a = make_random_char_nparray(val_range, size, dtype)
    arr = array(_CHAR_TYPECODE_MAP[dtype], map(chr, a.tolist()))
    s_arr = array(_CHAR_TYPECODE_MAP[dtype], map(chr, s_a.tolist()))
    return (arr, s_arr)

def make_random_float_array(val_range, size, dtype):
    if dtype not in _FLOAT_TYPECODE_MAP:
        raise ValueError("Data type not supported for array.array: %s"%(dtype))

    a, s_a = make_random_float_nparray(val_range, size, dtype)
    arr = array(_FLOAT_TYPECODE_MAP[dtype], a.tolist())
    s_arr = array(_FLOAT_TYPECODE_MAP[dtype], s_a.tolist())
    return (arr, s_arr)

def make_random_int_bytearray(val_range, size, dtype):
    a, s_a = make_random_int_nparray(val_range, size, dtype)
    return (bytearray(a), bytearray(s_a))
    
def make_random_char_bytearray(val_range, size, dtype):
    # Note this uses 'array' and not 'nparray' to ensure true char type.
    arr, s_arr = make_random_char_array(val_range, size, dtype)
    return (bytearray(arr), bytearray(s_arr))

def make_random_float_bytearray(val_range, size, dtype):
    a, s_a = make_random_float_nparray(val_range, size, dtype)
    return (bytearray(a), bytearray(s_a))


def make_test_cases_for_type(array_makers, num_cases, type_range, size, dtype):
    """
    Produce random test cases for a specific data type. Attempts to produce
    each of array.array, bytearray, and numpy.ndarray (sometimes truncating values
    to enforce necessary type ranges) when possible, but returns only those for
    which the type is possible. For example, there is no supported type code for
    array.array to have np.float128 as the base type.
    """        
    array_cases = list()
    truth_cases = list()
    for i in range(num_cases):
        for array_maker in array_makers:
            try:
                cases, truths = array_maker(type_range, size, dtype)
                array_cases.append(cases)
                truth_cases.append(truths)
            except ValueError:
                pass
        
    return array_cases, truth_cases


def generate_test_arrays(int_range, 
                         uint_range, 
                         char_range, 
                         double_range, 
                         size_per_case,
                         cases_per_type):
    """
    Generate random test cases for a range of types, where random values are 
    generated according to type-specific parameters.
    """
    cases = dict()
    sorted_truth = dict()

    for dtype in _DTYPES:

        if dtype in _INT_TYPES:
            type_range = int_range
            array_makers = [make_random_int_array, 
                            make_random_int_nparray, 
                            make_random_int_bytearray]

        elif dtype in _UNSIGNED_INT_TYPES:
            type_range = uint_range
            array_makers = [make_random_int_array, 
                            make_random_int_nparray, 
                            make_random_int_bytearray]

        elif dtype in _CHAR_TYPES:
            type_range = char_range
            array_makers = [make_random_char_array, 
                            make_random_char_nparray, 
                            make_random_char_bytearray]

        elif dtype in _FLOAT_TYPES:
            type_range = double_range
            array_makers = [make_random_float_array, 
                            make_random_float_nparray, 
                            make_random_float_bytearray]

        else:
            raise ValueError("passed dtype %s is not permitted."%(dtype))

        test_cases, test_truths = make_test_cases_for_type(array_makers,
                                                           cases_per_type, 
                                                           type_range, 
                                                           size_per_case, 
                                                           dtype)
        
        cases[dtype] = test_cases
        sorted_truth[dtype] = test_truths
    return cases, sorted_truth
