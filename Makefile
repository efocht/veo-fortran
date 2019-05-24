
ALL: hello libvehello.so veorun_static_omp

CC  = gcc
FC = gfortran
NCC = /opt/nec/ve/bin/ncc
NFORT = /opt/nec/ve/bin/nfort

# uncomment following line for static linking (for OpenMP on VE side)
VEO_STATIC = -DVEO_STATIC=1

# uncomment the following line if you want to get a chance to attach a
# debugger to the VE offloaded code (in static mode)
#VEO_DBG_SLEEP = -DVEO_DEBUG_SLEEP=20


veo_glue_code.o: veo_glue_code.c
	$(CC) -g $(VEO_STATIC) $(VEO_DBG_SLEEP) -o veo_glue_code.o -c veo_glue_code.c -I/opt/nec/ve/veos/include

#
# The following dynamic lib is only needed with dynamic linking (no OpenMP on VE side)
#
libvehello.so: libvehello.f03
	$(NFORT) -g -shared -fpic -o libvehello.so libvehello.f03

#
# The following executable is only needed with static VEO linking (OpenMP on VE side)
#
veorun_static_omp: libvehello.f03
	$(NFORT) -g -O2 -mno-create-threads-at-startup -fopenmp -o libvehello.o -c libvehello.f03; \
	CXX=$(NFORT) CFLAGS="-fopenmp" /opt/nec/ve/libexec/mk_veorun_static veorun_static_omp libvehello.o

hello.o: hello.f03
	$(FC) -o hello.o -c hello.f03

veo_glue.mod: veo_glue.f03
	$(FC) -g -c veo_glue.f03

hello: veo_glue_code.o veo_glue.mod hello.o libvehello.so
	$(FC) -g -o hello hello.o veo_glue_code.o \
		-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64 -lveo -ldl

clean:
	rm -f *.o *.mod *.so hello veorun_static_omp


