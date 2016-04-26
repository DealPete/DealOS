      PROGRAM MAIN
      INTEGER M,N

      M = 5
      N = 20
      CALL ADD(M,N)
      END

      SUBROUTINE ADD(I,J)
      INTEGER I,J
      J = I + J
      WRITE(*,*)J
      END
