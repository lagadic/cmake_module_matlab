cmake_module_matlab
=============

A CMake Module for finding Matlab based on cmake_modules.

Usage
-----

To use the CMake modules provided by this catkin package, you must `<build_depend>` on it in your `package.xml`, like so:

```xml
<?xml version="1.0"?>
<package>
  <!-- ... -->
  <build_depend>cmake_module_matlab</build_depend>
</package>
```

Then you must `find_package` it in your `CMakeLists.txt` along with your other catkin build dependencies:

```cmake
find_package(catkin REQUIRED COMPONENTS ... cmake_module_matlab ...)
```

OR by `find_package`'ing it directly:

```cmake
find_package(cmake_module REQUIRED)
```

After the above `find_package` invocations, the modules provided by `cmake_module_matlab` will be available in your `CMAKE_MODULE_PATH` to be found. Then you can find `Matlab` by using the following:

```cmake
find_package(Matlab REQUIRED)
```

The module also contains a template of a rtwmakecfg.m file that can be useful for compiling simulink s-functions.