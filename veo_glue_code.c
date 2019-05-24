#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <ve_offload.h>


int ve_node_number = 0;
struct veo_proc_handle *proc = NULL;
struct veo_thr_ctxt *ctx = NULL;
uint64_t handle = 0;
uint64_t func_sym = 0;
uint64_t ve_input_buff = 0;
uint64_t ve_output_buff = 0;


int veo_init(size_t input_buff_size, size_t output_buff_size)
{
	int rc;
	char *env;

	env = getenv("VE_NODE_NUMBER");
	if (env)
		ve_node_number = atoi(env);

#ifdef VEO_STATIC
#warning "Using statically linked VEO"
	proc = veo_proc_create_static(ve_node_number, "./veorun_static_omp");

#ifdef VEO_DEBUG_SLEEP
	printf("If you want to debug veorun, you've got %ds to attach a debugger!\n"
	       "From another shell, do:\n\n"
	       "/opt/nec/ve/bin/gdb -p %d veorun_static_omp\n\n"
	       "Then (in gdb) type for example: 'break <function_name>'\n",
	       VEO_DEBUG_SLEEP, getpid());
	sleep(VEO_DEBUG_SLEEP);
#endif
#else
	proc = veo_proc_create(ve_node_number);
#endif
	if (proc == NULL) {
		perror("veo_proc_create");
		return -1;
	}

	
#ifdef VEO_STATIC
	handle = 0UL;
#else
	handle = veo_load_library(proc, "./libvehello.so");
	if (handle == 0) {
		perror("veo_load_library");
		return -1;
	}
#endif

	func_sym = veo_get_sym(proc, handle, "my_func");
	printf("VE function address = %p\n", (void *)func_sym);

	ctx = veo_context_open(proc);
	if (ctx == NULL) {
		perror("veo_context_open");
		return -1;
	}
	/* allocate buffers */
	rc = veo_alloc_mem(proc, &ve_input_buff, input_buff_size);
	if (rc != 0) {
		perror("allocating input buffer failed");
		return -1;
	}
	rc = veo_alloc_mem(proc, &ve_output_buff, output_buff_size);
	if (rc != 0) {
		perror("allocating output buffer failed");
		return -1;
	}
	return 0;
}

int veo_work(int n, double *inbuff, double *outbuff)
{
	uint64_t req;
	double retval;
	int rc;

	/*
	  Transfer the input buffer to the VE, where the space
	  has been allocated during initialization.
	*/
	rc = veo_write_mem(proc, ve_input_buff, (char *)inbuff, n *sizeof(double));

	/*
	  You can also allocate the veo_args only once and
	  reuse the object. The object needs to be re-initialized
	  before a new use with veo_args_clear(argp)
	 */
	struct veo_args *argp = veo_args_alloc();

	/*
	  Prepare the arguments for the function called on VE side.
	  Let's suppose this is an integer Fortran function that takes
	  as arguments:
              integer N : intent in
	      double precision invec(N) : intent in
	      double precision outvec(N) : intent out
	*/

	/* set first argument, pass by reference, value on stack on VE */
	veo_args_set_stack(argp, VEO_INTENT_IN, 0, (char *)&n, sizeof(int));

	/* 2nd and 3rd arg are already known, only addresses must be passed */
	veo_args_set_u64(argp, 1, ve_input_buff);
	veo_args_set_u64(argp, 2, ve_output_buff);

	req = veo_call_async(ctx, func_sym, argp);
	if (req == VEO_REQUEST_ID_INVALID) {
		printf("Some error happened while veo_call_async\n");
		return -1;
	}
	printf("VEO request ID = 0x%lx\n", req);

	/* wait for request to finish */
	rc = veo_call_wait_result(ctx, req, (uint64_t *)&retval);
	printf("0x%lx: %d, %e\n", req, rc, retval);

	/*
	  Transfer the input buffer to the VE, where the space
	  has been allocated during initialization.
	*/
	rc = veo_read_mem(proc, (char *)outbuff, ve_output_buff, n * sizeof(double));

	veo_args_free(argp);
	return 0;
}

int veo_finish()
{
	int close_status = veo_context_close(ctx);
	printf("close status = %d\n", close_status);
	return close_status;
}
