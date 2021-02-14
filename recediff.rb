#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "recediff"

parser = Recediff::Parser.new(Recediff::Master.load('./csv'))

receipts_in_uke = parser.parse(ARGV.first)

puts receipts_in_uke.map(&:show)
puts receipts_in_uke.sum(&:point)
puts receipts_in_uke.length
