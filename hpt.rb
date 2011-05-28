#!/usr/bin/env ruby 
  
require 'optparse'
require 'rubygems'
require 'xmlsimple'


options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: ./hpt.rb [options]"


   # Define the options, and what they do
   options[:polling] = nil
   opts.on( '-p', '--[no-]polling', 'Enable or Disable SCM Polling' ) do|p|
     options[:polling] = p
   end

   options[:node] = nil
   opts.on( '-n', '--node=val', String, 'Assign node' ) do|n|
     options[:node] = n 
   end
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
end

def assignNode(filename,node)
  config = XmlSimple.xml_in(filename,'KeepRoot'=>true)
  root=config.keys[0];
  config[root][0]['assignedNode']=[node]
  output = XmlSimple.xml_out(config,'KeepRoot'=>true, 'OutputFile'=>filename, 'XmlDeclaration'=>"<?xml version='1.0' encoding='UTF-8'?>")
end

def enablePolling(filename)
  config = XmlSimple.xml_in(filename,'KeepRoot'=>true)
  root=config.keys[0];
  config[root][0]['triggers']=[{"class"=>"vector", "hudson.triggers.SCMTrigger"=>[{"spec"=>["* * * * *"]}]}]
  output = XmlSimple.xml_out(config,'KeepRoot'=>true, 'OutputFile'=>filename, 'XmlDeclaration'=>"<?xml version='1.0' encoding='UTF-8'?>")
end

def disablePolling(filename)
  config = XmlSimple.xml_in(filename,'KeepRoot'=>true)
  root=config[0];
  config[root][0]['triggers']=[{"class"=>"vector"}]
  output = XmlSimple.xml_out(config,'KeepRoot'=>true, 'OutputFile'=>filename, 'XmlDeclaration'=>"<?xml version='1.0' encoding='UTF-8'?>")
end

 
begin
optparse.parse! ARGV
raise OptionParser::MissingArgument if options[:polling].nil?
#raise OptionParser::MissingArgument if options.empty?
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts optparse
  exit 1
end

if options[:node]
  puts "Assigning node: " + options[:node]
  Dir['.hudson/jobs/*/config.xml'].each { |f| assignNode(f,options[:node]) }
end

if options[:polling]
  puts "Polling"
  Dir['.hudson/jobs/*/config.xml'].each { |f| enablePolling f }
else
  puts "Not Polling"
  Dir['.hudson/jobs/*/config.xml'].each { |f| disablePolling f }
end
