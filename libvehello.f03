!
! /opn/nec/ve/bin/nfort -shared -fpic -o libvehello.so libvehello.f90
!

function my_func(n, a, b) BIND(C, NAME='my_func')
  implicit none
  double precision :: my_func
  integer, intent(in) :: n
  double precision, intent(in) :: a(n)
  double precision, intent(out) :: b(n)

  integer :: i
  double precision :: sum

  print *,"n = ", n
  sum = 0.0
!$OMP PARALLEL DO
  do i = 0, n
     b(i) = a(i) * 2
!$OMP CRITICAL
     sum = sum + b(i)
!$OMP END CRITICAL
  end do
  my_func = sum
end function my_func
