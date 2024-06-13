#include <mpi.h>
#include <stdio.h>

int main( int argc, char *argv[])
{
  int myrank = -1, nranks = -1;
  MPI_Init(&argc,&argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &myrank); MPI_Comm_size(MPI_COMM_WORLD, &nranks);
  if (myrank == 0) printf("%d\n", nranks);
  MPI_Finalize();
  return 0;
}
