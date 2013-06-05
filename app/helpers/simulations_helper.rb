module SimulationsHelper

  def simulation_run_label(simulation)
    simulation.name
  end

  def parametrization_options(parameter, parameter_id)
    options = self.send("options_for_#{parameter["type"]}")

    select_tag "parametrization_type_#{parameter_id}", options_for_select(options), :parameter => parameter.to_json
  end

  def options_for_integer
    [
        ["Value", "value"],
        ["Random - Gauss distribution", "gauss"],
        ["Random - Discrete Uniform distribution", "uniform"],
        ["Range", "range"]
    ]
  end

  def options_for_float
    [
        ["Value", "value"],
        ["Random - Gauss distribution", "gauss"],
        ["Random - Discrete Uniform distribution", "uniform"],
        ["Range", "range"]
    ]
  end

  def options_for_string
    [
        ["Single value", "value"],
        ["Multiple value", "multiple"]
    ]
  end

  def select_doe_type
    options_for_select([
                           ['Near Orthogonal Latin Hypercubes', 'nolhDesign'],
                           ['2^k', '2k'],
                           ['Full factorial', 'fullFactorial'],
                           ['Fractional factorial (with Federov algorithm)', 'fractionalFactorial'],
                           ['Orthogonal Latin Hypercubes', 'latinHypercube'],
                       ])
  end

end
