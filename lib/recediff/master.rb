# frozen_string_literal: true

module Recediff
  class Master
    extend Forwardable

    def_delegators :@hash, :[], :[]=

    class << self
      def load(master_dir)
        master = self.new
        Dir.glob("#{master_dir}/*.csv") do | csv_path |
          CSV.foreach(csv_path) { | code, name | master[code.to_i] = name }
        end
        master
      end
    end

    def initialize
      @hash = {}
    end

    def find_name_by_code(code)
      @hash[code]
    end
  end
end
