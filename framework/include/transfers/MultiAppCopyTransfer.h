//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "MultiAppFieldTransfer.h"

/**
 * Copy the fields directly from one application to another, based on degree-of-freedom indexing
 */
class MultiAppCopyTransfer : public MultiAppFieldTransfer
{
public:
  static InputParameters validParams();

  MultiAppCopyTransfer(const InputParameters & parameters);

  /**
   * Performs the transfer of a variable (Nonlinear or Auxiliary) to/from the Multiapp.
   */
  virtual void execute() override;

protected:
  virtual std::vector<VariableName> getFromVarNames() const override { return _from_var_names; }
  virtual std::vector<AuxVariableName> getToVarNames() const override { return _to_var_names; }

  // These attributes are used if a derived class supports transferring multiple variables
  /// Name of variables transfering from
  const std::vector<VariableName> _from_var_names;
  /// Name of variables transfering to
  const std::vector<AuxVariableName> _to_var_names;

  // These attributes are used if a derived class only supports one variable
  /// Name of variables transfering from
  VariableName _from_var_name;
  /// Name of variables transfering to
  AuxVariableName _to_var_name;
};
