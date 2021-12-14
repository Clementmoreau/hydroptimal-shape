cd ../fortran_build/laplace
make
cp -R ./laplace ../../fortran_exec/laplace
cd ../prtcl_3d_shape
make
cp -R ./prtcl_3d_shape ../../fortran_exec/prtcl_3d_shape
cd ../stokes_grad
make
cp -R ./stokes_grad ../../fortran_exec/stokes_grad
cd ../stokes
make
cp -R ./stokes ../../fortran_exec/stokes
