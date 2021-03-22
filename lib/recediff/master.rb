# frozen_string_literal: true

module Recediff
  class Master
    extend Forwardable

    def_delegators :@hash, :[], :[]=

    class << self
      def load(master_dir)
        master = self.new
        Dir.glob("#{master_dir}/{IY,SI,TO}.csv") do | csv_path |
          CSV.foreach(csv_path) { | code, name | master[code.to_i] = name }
        end
        master
      end
    end

    def initialize
      # @type [Hash<Symbol, String>]
      @hash = {}
    end

    # @param [String, Integer] code
    # @return [String, nil]
    def find_name_by_code(code)
      @hash[code]
    end
  end

  class DiseaseMaster
    extend Forwardable

    def_delegators :@hash, :[], :[]=

    class << self
      def load(master_dir)
        master = self.new
        Dir.glob("#{master_dir}/SY.csv") do | csv_path |
          CSV.foreach(csv_path) { | _, _, code, _, _, name | master[code] = name }
        end
        master
      end
    end

    def initialize
      # @type [Hash<Symbol, String>]
      @hash = {}
    end

    # @param [String, Integer] code
    # @return [String, nil]
    def find_name_by_code(code)
      @hash[code]
    end
  end

  class ShushokugoMaster
    extend Forwardable

    def_delegators :@hash, :[], :[]=

    class << self
      def load(master_dir)
        master = self.new
        Dir.glob("#{master_dir}/SH.csv") do | csv_path |
          CSV.foreach(csv_path) { | code, name, is_prefix | master[code] = Syobyo::Shushokugo.new(code, name, is_prefix.to_i != 8) }
        end
        master
      end
    end

    def initialize
      # @type [Hash<Symbol, String>]
      @hash = {}
    end

    # @param [String, Integer] code
    # @return [Shushokugo, nil]
    def find_by_code(code)
      @hash[code]
    end
  end
end
