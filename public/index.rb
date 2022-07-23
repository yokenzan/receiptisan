#!/usr/bin/env ruby
# frozen_string_literal: true

require 'recediff'
require 'sinatra'
require 'stringio'
require 'erb'
require 'sinatra/reloader' if development?

set :views, settings.root + '/../views'

get '/' do
  @uke = params[:sample] ?
    File.read(__dir__ + '/../spec/resource/input/RECEIPTC_GAIRAI_SAMPLE.UKE', encoding: 'Shift_JIS:UTF-8') :
    ''
  erb :index
end

post '/summary' do
  uke      = params[:uke]
  @summary = Recediff::SummaryParser.new.parse_as_receipt_summaries_from_text(uke)

  erb :summary
end

post '/preview' do
  @receipts = Recediff::Parser.create.parse_area(params['uke'])
  @util     = Recediff::StringUtil.new
  erb :preview
end
