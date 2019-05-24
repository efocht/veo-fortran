MODULE veo_glue
  !
  ! fortran 2003 interfaces to the VEO related C functions
  !
  USE, INTRINSIC :: ISO_FORTRAN_ENV
  USE, INTRINSIC :: ISO_C_BINDING
  IMPLICIT NONE
  !
  INTERFACE
     ! int veo_init(size_t input_buff_size, size_t output_buff_size)
     FUNCTION veo_init (input_buff_size, output_buff_size) BIND(C, NAME='veo_init')
       USE, INTRINSIC :: ISO_C_BINDING
       IMPLICIT NONE
       INTEGER (KIND=C_INT) :: veo_init
       INTEGER (KIND=C_SIZE_T), VALUE :: input_buff_size, output_buff_size
     END FUNCTION veo_init

     ! double veo_work(int n, double *inbuff, double *outbuff)
     FUNCTION veo_work(n, inbuff, outbuff) BIND(C, NAME='veo_work')
       USE, INTRINSIC :: ISO_C_BINDING
       IMPLICIT NONE
       INTEGER (KIND=C_INT) :: veo_work
       INTEGER (KIND=C_INT), VALUE :: n
       REAL (KIND=C_DOUBLE), DIMENSION(*), INTENT(in) :: inbuff
       REAL (KIND=C_DOUBLE), DIMENSION(*), INTENT(out) :: outbuff
     END FUNCTION veo_work

     ! int veo_finish()
     FUNCTION veo_finish() BIND(C, NAME='veo_finish')
       USE, INTRINSIC :: ISO_C_BINDING
       IMPLICIT NONE
       INTEGER (KIND=C_INT) :: veo_finish
     END FUNCTION veo_finish

  END INTERFACE

END MODULE veo_glue
