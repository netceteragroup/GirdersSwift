#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'

# print error mesage and exit with status 1
def error(message="Unknown error")
    puts "ERROR: #{message}"
    exit 1
end

#parse the spath and fill into the provided result file
def parse(spath, result)

    # if the file is not present, return the result as is
    unless File.file? spath
        return result
    end

    # if the file is empty, return the result as is
    contents = File.open(spath).read
    unless contents.length > 0
        return result
    end

    # parse the doc
    begin
        doc = Nokogiri::XML(File.open(spath)) do |config|
            config.strict.noent
        end
    rescue Exception => e
        error e
    end

    # we support trema-1.0
    trema = doc/'trema'
    ver = trema.attr('noNamespaceSchemaLocation').value
    exp = 'http://software.group.nca/trema/schema/trema-1.0.xsd'
    error "Unsupported TREMA version '#{ver}'" unless exp == ver

    # itterate trough all texts
    (trema/'text').each do |text|
        key = text.attr('key')

        # and all values
        (text/'value').each do |value|
            lang = value.attr('lang')

            # create the string for that language if not existent
            unless result[lang]
                result[lang] = Hash.new
            end

            language_hash = result[lang]

            # escape the quotes
            string = value.content
            string = string.gsub("\"", "\\\"")
            language_hash[key] = string
        end
    end
    result
end

#save each key/language from the result dictionary into a messages.strings file
def save(result, dpath)
    result.each do |key, language_hash| 
        path = "#{dpath}/#{key}.lproj"
        Dir.mkdir(path) unless File.directory? path
        fout = File.open("#{path}/messages.strings", 'w') 

        language_hash.each do |key, string|
            text = "\"#{key}\" = \"#{string}\";\n"
            fout.puts text
        end

        fout.close()
    end
end

error "Invalid arguments provided. \n"\
"Usage: \n"\
" - ruby trema.rb source.trm output_folder or\n"\
" - ruby trema.rb source.trm second_source.trm output_folder\n"\
"Note that only the first source file must be present.\n"\
unless ARGV.length == 2 or ARGV.length == 3

if ARGV.length == 2
    spath = ARGV[0]
    dpath = ARGV[1]
    error 'The source path should point to an existing file' unless File.file? spath
    error 'The output path should point to an existing directory' unless File.directory? dpath

    result = parse(spath, Hash.new)
    save(result, dpath)
end

if ARGV.length == 3
    s1path = ARGV[0]
    s2path = ARGV[1]
    dpath = ARGV[2]
    error 'The first source path should point to an existing file' unless File.file? s1path
    error 'The output path should point to an existing directory' unless File.directory? dpath

    result = parse(s1path, Hash.new)
    result = parse(s2path, result)
    save(result, dpath)
end
