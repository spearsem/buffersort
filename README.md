# buffersort
Provide a variety of sorting algorithms that operate in-place on types that implement the Python buffer protocol.

## install
Pip and/or conda instructions are forthcoming. For now, simply clone the repo, navigate to the top-level directory where you can fine `setup.py` and use

```shell
python setup.py install
```

If you'd like to preserve a copy of the files affected by installation so that you can manually uninstall later, add the `--record` option:

```shell
python setup.py install --record install-files.txt
```

Currently, `buffersort` has only been tested with Python 2.7.11 on Ubuntu 14.04, but the code is written to be cross-platform and Python 3 safe. Further testing and any version or platform-specific instructions are forthcoming.

`buffersort` requires Cython >= 0.22 and NumPy >= 1.10.1.


## usage
Assuming you have installed the package, everything can be accessed by importing `buffersort`:

```
In [1]: import buffersort

In [2]: from array import array

In [3]: a = array('l', [-1, -50, 10, -3, 27, 14])

In [4]: a
Out[4]: array('l', [-1, -50, 10, -3, 27, 14])

In [5]: buffersort.heap_sort(a)

In [6]: a
Out[6]: array('l', [-50, -3, -1, 10, 14, 27])
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