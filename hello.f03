PROGRAM hello

  USE, INTRINSIC :: ISO_FORTRAN_ENV
  USE, INTRINSIC :: ISO_C_BINDING
  USE veo_glue
  IMPLICIT NONE

  INTEGER (KIND=C_INT) :: rc, i
  INTEGER (KIND=C_SIZE_T), PARAMETER :: NSIZE = 10000

  DOUBLE PRECISION, DIMENSION(NSIZE) :: a, b

  rc = veo_init(NSIZE * 8, NSIZE * 8)
  if (rc /= 0) then
     stop 1
  end if

  do i = 1, NSIZE
     a(i) = i
  end do

  rc = veo_work(int(NSIZE), a, b)
  
  if (rc /= 0) then
     print *,"error while veo_work"
  end if

  print *,"first 5 values of result array:"
  do i = 1, 5
     print *, b(i)
  end do
  
  rc = veo_finish();

end program hello
