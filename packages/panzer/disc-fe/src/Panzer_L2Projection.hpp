// @HEADER
// @HEADER

#ifndef PANZER_L2_PROJECTION_HPP
#define PANZER_L2_PROJECTION_HPP

#include "Teuchos_RCP.hpp"
#include "Phalanx_KokkosDeviceTypes.hpp"
#include "Panzer_BasisDescriptor.hpp"
#include "Panzer_IntegrationDescriptor.hpp"
#include "Tpetra_Map.hpp" // for KokkosDeviceWrapperNode
#include <vector>
#include <string>

namespace Teuchos {
  template<typename T> class MpiComm;
}

namespace Tpetra {
  template<typename S,typename LO,typename GO,typename Node> class CrsMatrix;
}

namespace panzer {

  class LinearObjContainer;
  class BasisDescriptor;
  class IntegrationDescriptor;
  template<typename LO,typename GO> class ConnManager;
  template<typename LO,typename GO> class DOFManager;
  class WorksetContainer;

  /** \brief Unified set of tools for building objects for lumped and
      consistent L2 projects between bases. Currently only supports
      scalar projections onto HGrad bases. It is design to be
      extensible to all cases.

      Need to add description of utilities.
  */
  template<typename LO, typename GO>
  class L2Projection {

    panzer::BasisDescriptor targetBasisDescriptor_;
    panzer::IntegrationDescriptor integrationDescriptor_;
    Teuchos::RCP<Teuchos::MpiComm<int>> comm_;
    Teuchos::RCP<const panzer::ConnManager<LO,GO>> connManager_;
    std::vector<std::string> elementBlockNames_;
    mutable Teuchos::RCP<panzer::WorksetContainer> worksetContainer_;
    bool setupCalled_;

    Teuchos::RCP<panzer::DOFManager<LO,GO>> targetGlobalIndexer_;

  public:

    //! Constructor
    L2Projection() : setupCalled_(false) {}

    /** \brief Setup base objects for L2 Projections - requires target scalar basis and creates worksets if not supplied by user.

        \param[in] basis (required) Basis that field values will be projected to.
        \param[in] integrationDescriptor (required) Integration order used for the projection.
        \param[in] comm (required) Teuchos MPI communicator used all processes involved in the project.
        \param[in] connManger (required) Connection manager to describe the mesh.
        \param[in] elementBlockNames (required) Names of element blocks in mesh that are involved in the projection.
        \param[in] worksetContainer (optional) If the user has already allocated worksets for the corresponding mesh/element blocks, we can used those instead of reallocating for projection.
    */
    void setup(const panzer::BasisDescriptor& targetBasis,
               const panzer::IntegrationDescriptor& integrationDescriptor,
               const Teuchos::RCP<Teuchos::MpiComm<int>>& comm,
               const Teuchos::RCP<const panzer::ConnManager<LO,GO>>& connManager,
               const std::vector<std::string>& elementBlockNames,
               const Teuchos::RCP<panzer::WorksetContainer>& worksetContainer = nullptr);

    /** \brief Allocates, fills and returns a mass matrix for L2
        projection of a scalar and vector field(s) onto a scalar
        basis.

        \returns Filled Matrix in a LinearObjectContainer
    */
    Teuchos::RCP<Tpetra::CrsMatrix<double,LO,GO,Kokkos::Compat::KokkosDeviceWrapperNode<PHX::Device>>>
      buildMassMatrix();

    /** \brief Allocates, fills and returns a rectangular matrix for
        L2 projection of a scalar fields (or their gradients) or one
        dimension of a vector field onto the target scalar basis. If
        you wish to project all values of a vector field or the
        gradients of a scalar field, then you will need three separate
        RHS matrices to form the RHS for each independently.

        \param[in] (required) sourceDOFManager The source dof manger object
        \param[in] (required) ownedSourceMap The Tpetra Map for the owned source vector
        \param[in] (required) sourceFieldName The string name of the source field to project
        \param[in] (required) sourceBasisDescriptor The type of the basis for the source field
        \param[in] (optional) vectorOrGradientDirectionIndex For vector fields, this is the vector index to project (x,y, or z coordinate direction). For scalar fields, the default value of -1 results in a projection of the scalar field value. If set to 0 or greater, it is assumed that the gradient of the HGrad field is projected and that this value is the dimension index for the particular gradient (x, y, or z coordinate direction).
        \returns Alocated and filled Tpetra::CrsMatrix
    */
    Teuchos::RCP<Tpetra::CrsMatrix<double,LO,GO,Kokkos::Compat::KokkosDeviceWrapperNode<PHX::Device>>>
      buildRHSMatrix(const Teuchos::RCP<panzer::DOFManager<LO,GO>>& sourceDOFManager,
                     const Teuchos::RCP<Tpetra::Map<LO,GO,Kokkos::Compat::KokkosDeviceWrapperNode<PHX::Device>>>& ownedSourceMap,
                     const std::string& sourceFieldName,
                     const panzer::BasisDescriptor& sourceBasisDescriptor,
                     const int vectorOrGradientDirectionIndex = -1);
  };

}

#endif
