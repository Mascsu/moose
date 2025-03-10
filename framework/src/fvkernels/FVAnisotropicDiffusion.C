//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVAnisotropicDiffusion.h"

registerMooseObject("MooseApp", FVAnisotropicDiffusion);

InputParameters
FVAnisotropicDiffusion::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription(
      "Computes residual for anisotropic diffusion operator for finite volume method.");
  params.addRequiredParam<MooseFunctorName>("coeff",
                                            "The diagonal coefficients of a diffusion tensor.");
  MooseEnum coeff_interp_method("average harmonic", "harmonic");
  params.addParam<MooseEnum>(
      "coeff_interp_method",
      coeff_interp_method,
      "Switch that can select face interpolation method for diffusion coefficients.");
  params.set<unsigned short>("ghost_layers") = 2;
  return params;
}

FVAnisotropicDiffusion::FVAnisotropicDiffusion(const InputParameters & params)
  : FVFluxKernel(params), _coeff(getFunctor<ADRealVectorValue>("coeff"))
{
#ifndef MOOSE_GLOBAL_AD_INDEXING
  mooseError("FVAnisotropicDiffusion is not supported by local AD indexing. In order to use this "
             "object, please run "
             "the configure script in the root MOOSE directory with the configure option "
             "'--with-ad-indexing-type=global'. Note that global indexing is now the default "
             "configuration for AD indexing type.");
#endif

  const auto & interp_method = getParam<MooseEnum>("coeff_interp_method");
  if (interp_method == "average")
    _coeff_interp_method = Moose::FV::InterpMethod::Average;
  else if (interp_method == "harmonic")
    _coeff_interp_method = Moose::FV::InterpMethod::HarmonicAverage;

  if ((_var.faceInterpolationMethod() == Moose::FV::InterpMethod::SkewCorrectedAverage) &&
      (_tid == 0))
    adjustRMGhostLayers(std::max((unsigned short)(3), _pars.get<unsigned short>("ghost_layers")));
}

ADReal
FVAnisotropicDiffusion::computeQpResidual()
{
  const auto & grad_T = _var.adGradSln(
      *_face_info, _var.faceInterpolationMethod() == Moose::FV::InterpMethod::SkewCorrectedAverage);

  ADRealVectorValue coeff;
  interpolate(_coeff_interp_method,
              coeff,
              _coeff(elemFromFace()),
              _coeff(neighborFromFace()),
              *_face_info,
              true);

  ADReal r = 0;
  for (const auto i : make_range(Moose::dim))
    r += _normal(i) * coeff(i) * grad_T(i);
  return -r;
}
