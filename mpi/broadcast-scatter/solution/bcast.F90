program bcast
  use mpi
  implicit none

  integer, parameter :: size=12
  integer :: ntasks, myid, ierr, i, color, sub_comm
  integer, dimension(size) :: message, recvbuf
  integer, dimension(size**2) :: printbuf

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, ntasks, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, myid, ierr)

  ! Initialize message buffers
  call init_buffers

  ! Print data that will be sent
  call print_buffers(message)

  ! Send message everywhere
  if(myid == 0) then
     do i=0, ntasks-1
       call mpi_send(message, size, MPI_INTEGER, i,i,MPI_COMM_WORLD, ierr)
     enddo
  else
     call mpi_recv(message, size, MPI_INTEGER, 0, myid, MPI_COMM_WORLD, status,ierr)
  endif

  ! Print data that was received
  call print_buffers(message)
   
  call mpi_finalize(ierr)

contains

  subroutine init_buffers
    implicit none
    integer :: i
    if(myid==0) then
      do i = 1, size
         message(i) = i
      end do
    else
     do i=1, size
         message(i)= -1
     enddo
    endif
  end subroutine init_buffers


  subroutine print_buffers(buffer)
    implicit none
    integer, dimension(:), intent(in) :: buffer
    integer, parameter :: bufsize = size
    integer :: i
    character(len=40) :: pformat

    write(pformat,'(A,I3,A)') '(A4,I2,":",', bufsize, 'I3)'

    call mpi_gather(buffer, bufsize, MPI_INTEGER, &
         & printbuf, bufsize, MPI_INTEGER, &
         & 0, MPI_COMM_WORLD, ierr)

    if (myid == 0) then
       do i = 1, ntasks
          write(*,pformat) 'Task', i - 1, printbuf((i-1)*bufsize+1:i*bufsize)
       end do
       print *
    end if
  end subroutine print_buffers

end program 
