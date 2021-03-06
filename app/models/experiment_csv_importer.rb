require 'csv'

class ExperimentCsvImporter
  attr_accessor :parameters, :parameter_values

  def initialize(csv_content, parameters_to_include = nil)
    @content = csv_content
    @parameters, @parameter_values = [], []
    @parameters_to_include = parameters_to_include
    @indexes_to_omit = []

    parse
  end

  def parse
    i = 0

    CSV.parse(@content.strip) do |row|
      if i == 0
        @parameters = row
        @parameters_to_include = @parameters if @parameters_to_include.nil?

        @parameters.each_with_index do |parameter, index|
          unless @parameters_to_include.include?(parameter)
            @indexes_to_omit << index
          end
        end

        @parameters.delete_if{ |e| not @parameters_to_include.include?(e) }
      else
        row_values = []
        row.each_with_index do |cell, index|
          next if @indexes_to_omit.include?(index)

          begin
            parsed_cell = JSON.parse(cell)
            row_values << parsed_cell.map {|v| self.class.convert_type(v)}
          rescue JSON::ParserError
            row_values << [ self.class.convert_type(cell) ]
          end
        end

        p = row_values[0]
        1.upto(row_values.size - 1).each do |i|
          p = p.product(row_values[i])
        end
        @parameter_values += p.map{ |e| e.respond_to?(:flatten) ? e.flatten : e }
      end

      i += 1
    end

    @parameter_values
  end

  # TODO move to utils
  def self.convert_type(value)
    cval = nil
    begin
      cval = Integer(value)
    rescue ArgumentError
      begin
        cval = Float(value)
      rescue ArgumentError
        cval = value.to_s
      end
    end

    cval
  end

end