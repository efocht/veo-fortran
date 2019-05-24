# VEO in Fortran

This little example shows how VEO (Vector Engine Offloading) can be
used from Fortran. Instead of having all VEO API converted to Fortran,
this example implements the VEO calls specific to the program in C and
uses them with the help of `ISO_C_BINDING`.

## Files and their role

`hello.f03`: Fortran main program. Runs on the vector host (VH).

`libvehello.f03`: Fortran offloaded kernel, supposed to run on the vector engine (VE).

`veo_glue_code.c`: Specialized code that deals with VEO details and
calls the VEO kernel in libvehello.f03. This is in C because the VEO
API is in C. The glue code uses static VEO linking because that allows
the use of OpenMP insode the VEO kernels. This is currently a
limitation of VEO.

`veo_glue.f03`: Fortran module implementing the interfaces to the functions defined in *veo_glue_code.c*.


## Build and test

Clone the repository:
```
git clone https://github.com/efocht/veo-fortran
```

Build the files (an an Aurora system!):
```
cd veo-fortran

make
```

Run the test:
```
OMP_NUM_THREADS=4 ./hello
```

The env variable `OMP_NUM_THREADS` is being passed and used by the VE
kernel. You can also specify the VE ID on which the kernel should run:
```
export VE_NODE_NUMBER=<ve_node_id>
```
