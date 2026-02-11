# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'fileutils'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:test)
RuboCop::RakeTask.new(:lint)

task default: :test

namespace :master do
  desc 'Shift_JISのマスタCSV/TXTをUTF-8へ変換して保存する'
  task :convert_utf8 do
    master_root = File.expand_path('csv/master', __dir__)
    year_dirs = Dir.glob(File.join(master_root, '*')).select { | path | File.directory?(path) }

    year_dirs.each do | year_dir |
      utf8_dir = File.join(year_dir, 'utf8')
      FileUtils.mkdir_p(utf8_dir)

      source_files = Dir.glob(File.join(year_dir, '*.{csv,txt,CSV,TXT}'))
      source_files.each do | source_path |
        source = File.binread(source_path).force_encoding('Shift_JIS')
        utf8 = source.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        output_path = File.join(utf8_dir, File.basename(source_path))
        File.binwrite(output_path, utf8)
        puts "converted: #{source_path} -> #{output_path}"
      end
    end
  end
end
