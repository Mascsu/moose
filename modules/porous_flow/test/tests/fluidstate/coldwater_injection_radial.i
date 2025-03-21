# Cold water injection into 1D radial hot reservoir (Avdonin, 1964)
#
# To generate results presented in documentation for this problem,
# set xmax = 1000 and nx = 200 in the Mesh block, and dtmax = 1e4
# and end_time = 1e6 in the Executioner block.

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 50
  xmin = 0.1
  xmax = 5
  bias_x = 1.05
[]

[Problem]
  rz_coord_axis = Y
  coord_type = RZ
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[AuxVariables]
  [temperature]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
    execute_on = 'initial timestep_end'
  []
[]

[Variables]
  [pliquid]
    initial_condition = 5e6
  []
  [h]
    scaling = 1e-6
  []
[]

[ICs]
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliquid
    property = enthalpy
    temperature = 170
    temperature_unit = Celsius
    fp = water
  []
[]

[Functions]
  [injection_rate]
    type = ParsedFunction
    vals = injection_area
    vars = area
    value = '-0.1/area'
  []
[]

[BCs]
  [source]
    type = PorousFlowSink
    variable = pliquid
    flux_function = injection_rate
    boundary = left
  []
  [pright]
    type = DirichletBC
    variable = pliquid
    value = 5e6
    boundary = right
  []
  [hleft]
    type = DirichletBC
    variable = h
    value = 678.52e3
    boundary = left
  []
  [hright]
    type = DirichletBC
    variable = h
    value = 721.4e3
    boundary = right
  []
[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    variable = pliquid
  []
  [massflux]
    type = PorousFlowAdvectiveFlux
    variable = pliquid
  []
  [heat]
    type = PorousFlowEnergyTimeDerivative
    variable = h
  []
  [heatflux]
    type = PorousFlowHeatAdvection
    variable = h
  []
  [heatcond]
    type = PorousFlowHeatConduction
    variable = h
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pliquid h'
    number_fluid_phases = 2
    number_fluid_components = 1
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    pc_max = 1e6
    sat_lr = 0.1
    m = 0.5
    alpha = 1e-5
  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = water
    capillary_pressure = pc
  []
[]

[FluidProperties]
  [water]
    type = Water97FluidProperties
  []
[]

[Materials]
  [watervapor]
    type = PorousFlowFluidStateSingleComponent
    porepressure = pliquid
    enthalpy = h
    temperature_unit = Celsius
    capillary_pressure = pc
    fluid_state = fs
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.2
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1.8e-11 0 0 0 1.8e-11 0 0 0 1.8e-11'
  []
  [relperm_water]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
    s_res = 0.1
    sum_s_res = 0.1
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 1
    sum_s_res = 0.1
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2900
    specific_heat_capacity = 740
  []
  [rock_thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '20 0 0  0 20 0  0 0 20'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e3
  nl_abs_tol = 1e-8
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
  []
[]

[Postprocessors]
  [injection_area]
    type = AreaPostprocessor
    boundary = left
    execute_on = initial
  []
[]

[VectorPostprocessors]
  [line]
    type = ElementValueSampler
    sort_by = x
    variable = temperature
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  perf_graph = true
  [csv]
    type = CSV
    execute_on = final
  []
[]
