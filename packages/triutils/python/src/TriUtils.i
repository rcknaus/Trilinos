// -*- c++ -*-

// @HEADER
// ***********************************************************************
//
//          PyTrilinos.TriUtils: Python Interface to TriUtils
//                 Copyright (2005) Sandia Corporation
//
// Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
// license for use of this work by or on behalf of the U.S. Government.
//
// This library is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 2.1 of the
// License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// Questions? Contact Michael A. Heroux (maherou@sandia.gov)
//
// ***********************************************************************
// @HEADER

%module(package="PyTrilinos") TriUtils

%{
// System includes
#include <iostream>
#include <sstream>
#include <vector>

// Epetra includes
#include "Epetra_Map.h"
#include "Epetra_LocalMap.h"
#include "Epetra_CrsMatrix.h"
#include "Epetra_FECrsMatrix.h"
#include "Epetra_VbrMatrix.h"

// Epetra wrapper helper includes
#include "NumPyImporter.h"
#include "Epetra_NumPyMultiVector.h"
#include "Epetra_NumPyVector.h"

// Trilinos utility includes
#include "Trilinos_Util_CrsMatrixGallery.h"
#include "Trilinos_Util_Version.h"
%}

// Auto-documentation feature
%feature("autodoc", "1");

// Ignore directives
#pragma SWIG nowarn=503
%ignore *::operator<< ;
%ignore Trilinos_Util::CrsMatrixGallery::operator<<(ostream&,
						    const Trilinos_Util::CrsMatrixGallery&);

// Rename directives
%rename (TriUtils_Version) Triutils_Version;
%rename (ReadHB          ) Trilinos_Util_ReadHb2Epetra;

// Typemap directives
%typemap(argout) (Epetra_Map       *& OutMap,
                  Epetra_CrsMatrix *& OutMatrix,
                  Epetra_Vector    *& OutX,
                  Epetra_Vector    *& OutB,
                  Epetra_Vector    *& OutXexact) 
{
  PyObject *oMap, *oMatrix, *oX, *oB, *oXexact;
  oMap    = SWIG_NewPointerObj((void*)(*$1), SWIGTYPE_p_Epetra_Map,       1);
  oMatrix = SWIG_NewPointerObj((void*)(*$2), SWIGTYPE_p_Epetra_CrsMatrix, 1);
  oX      = SWIG_NewPointerObj((void*)(*$3), SWIGTYPE_p_Epetra_Vector,    1);
  oB      = SWIG_NewPointerObj((void*)(*$4), SWIGTYPE_p_Epetra_Vector,    1);
  oXexact = SWIG_NewPointerObj((void*)(*$5), SWIGTYPE_p_Epetra_Vector,    1);
  $result = Py_BuildValue("(OOOOO)",oMap,oMatrix,oX,oB,oXexact);
}

%typemap(in,numinputs=0) Epetra_Map *&OutMap(Epetra_Map* _map) {
    $1 = &_map;
}

%typemap(in,numinputs=0) Epetra_CrsMatrix *&OutMatrix(Epetra_CrsMatrix* _matrix) {
    $1 = &_matrix;
}

%typemap(in,numinputs=0) Epetra_Vector *&OutX(Epetra_Vector* _x) {
    $1 = &_x;
}

%typemap(in,numinputs=0) Epetra_Vector *&OutB(Epetra_Vector* _B) {
    $1 = &_B;
}

%typemap(in,numinputs=0) Epetra_Vector *&OutXexact(Epetra_Vector* _xexact) {
    $1 = &_xexact;
}

// %typemap(out) Epetra_MultiVector * {
//   Epetra_NumPyMultiVector * npmv;
//   static swig_type_info *ty = SWIG_TypeQuery("Epetra_NumPyMultiVector *");
//   npmv = new Epetra_NumPyMultiVector(*$1);
//   $result = SWIG_NewPointerObj(npmv, ty, 1);
// }

// %inline {
// void Trilinos_Util_ReadHb2Epetra(char               * data_file,
// 				 const Epetra_Comm  & comm, 
// 				 Epetra_Map        *& OutMap, 
// 				 Epetra_CrsMatrix  *& OutMatrix, 
// 				 Epetra_Vector     *& OutX, 
// 				 Epetra_Vector     *& OutB,
// 				 Epetra_Vector     *& OutXexact);
// }

// Epetra interface includes
using namespace std;
%import "Epetra.i"

// Triutils interface includes
%include "Trilinos_Util_ReadHb2Epetra.cpp"
%include "Trilinos_Util_CrsMatrixGallery.h"
%include "Trilinos_Util_Version.h"

// Python code
%pythoncode %{
__version__ = TriUtils_Version().split()[2]
%}
