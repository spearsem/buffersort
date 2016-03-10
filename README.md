# buffersort
Provide a variety of sorting algorithms that operate in-place on types that implement the Python buffer protocol.

## install
Pip and/or conda instructions are forthcoming. For now, simply clone the repo, navigate to the top-level directory where you can find `setup.py` and use

```bash
python setup.py install
```

If you'd like to preserve a copy of the files affected by installation so that you can manually uninstall later, add the `--record` option:

```bash
python setup.py install --record install-files.txt
```

Currently, `buffersort` has only been tested with Python 2.7.11 on 64-bit Ubuntu 14.04, but the code is written to be cross-platform and Python 3 safe. Further testing and any version or platform-specific instructions are forthcoming.

`buffersort` requires Cython >= 0.22 and NumPy >= 1.10.1.


## usage
Assuming you have installed the package, everything can be accessed by importing `buffersort`:

```python
>>> import buffersort
>>> from array import array
>>> a = array('l', [-1, -50, 10, -3, 27, 14])
>>> a
array('l', [-1, -50, 10, -3, 27, 14])

>>> buffersort.heap_sort(a)
>>> a
array('l', [-50, -3, -1, 10, 14, 27])
```

## testing
`buffersort` provides unit tests as a built package so that you may execute them more conveniently. The test subpackage, `buffersort.test`, may be imported directly:

```python
>>> import buffersort.test as test
```

Alternatively, the `buffersort.test.test_buffersort` module, which contains the unit tests, is provided as part of the top-level `buffersort` package import, and you may run the full suite of unit tests as follows.

```python
>>> import buffersort
>>> buffersort.test_buffersort.run_tests()
```

If tests fail due to type signature errors or unsupported type errors, feel free to create an issue with your platform information. The type support is controlled by the `Ord` fused type found in `buffersort.pxd`. Cython states that support for fused types is experimental, so some bugs may be unavoidable due to Cython fused type support. Other bugs may be fixable by extending the library to include additional types in the `Ord` fused type definition. 

## motivation
`buffersort` makes use of Cython fused types and typed memoryviews to enable writing concise functions in simple Cython syntax from which many overloaded versions are automatically generated and correctly dispatched in the compiled code. 

`buffersort` is meant to be an educational library for the task of writing Python modules that include functions which are both *performant* and *polymorphic*. Traditionally, with Python's dynamic type model, there is often a trade-off between writing a generic function accepting of many different Python objects and writing specialized functions that are tightly compiled and optimized to handle a narrow type. But with Cython fused types, it is possible to make functions more generic without sacrificing any of their static type specialization. 

The use of `Ord` as a Cython fused type is not accidental. This motif is inspired by the [`Ord` type class in the Haskell programming language](https://hackage.haskell.org/package/base-4.8.2.0/docs/Data-Ord.html). Part of the goal of `buffersort` is to demonstrate how, at least for a limited set of situations, Cython fused types enable designs that are similarly easy to work with and expressive as Haskell type classes.

For example, we can see from a small section of the Cython source code how a C-level function is defined with static type information, yet corresponds to autogenerated functions that cover all necessary static type signatures from all constituent types of `Ord`:

```cython
cdef void _swap(Ord[:] buf, int i, int j):
    """
    Swap elements i and j in buffer buf.
    """
    cdef Ord temp = buf[i]
    buf[i] = buf[j]
    buf[j] = temp
```

In this case, `_swap` is a simple helper function to swap the elements residing at positions `i` and `j` of an array. The array argument `buf` has a static type of `Ord[:]` -- a typed memoryview of a one-dimensional array of `Ord` values. 

In the body of the function, we can work with the array without caring whether it is an array of `int` or an array of `double` -- the overloaded versions specific to these types will be autogenerated since those base types are part of the `Ord` fused type. We can even create a temporary value, `temp` with type `Ord` that will be correctly resolved for each distinct compiled overload of the function.