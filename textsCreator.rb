#!/usr/bin/env ruby
require "rexml/document"
require "xcodeproj"
require "fileutils"
include REXML

def error(message="Unknown error")
    puts "ERROR: #{message}"
    exit 1
end

pathToTrema = ARGV[1]

if ARGV.count < 2
    error("amount of arguments is not enough")
end

if ARGV[2].nil?
    structName = "Texts"
    dirPath = "src/main/resources/trema/"
    textsPath = "src/main/resources/trema/" + structName + ".swift"
else
    textsPath = ARGV[2]
    structName = textsPath.split("/").last.split(".").first
    dirPath = ""
    textsPath.split("/").each do |subString|
        if !(subString == structName + ".swift")
            dirPath += subString
            dirPath += "/"
        end
    end
end

file = File.open(pathToTrema).read
doc = Document.new file

root = doc.root

shouldAdd = false

if File.file?(textsPath)
    outfile = File.open(textsPath,"w")
else
    outfile = File.new(textsPath,"w")
    shouldAdd = true
end
outfile.puts "import GirdersSwift\n\n"
outfile.puts "struct " + structName + " { \n"
doc.elements.each("trema/text") do |e|
    e.elements.each("context") do |c|
        if c.has_text?()
            outfile.puts "    // " + c.text()
        end
    end
    outfile.puts "    static let " + e.attributes["key"] + " = " + "translate(\"" + e.attributes["key"]  + "\")"
end

outfile.puts "\n}"

outfile.close

if shouldAdd
    product_name = ARGV[0]
    project_file =  product_name + ".xcodeproj"
    project = Xcodeproj::Project.open(project_file)

    # Add a file to the project in the main group
    file_name =  structName + ".swift"
    xcFile = project[dirPath].new_file(file_name)

    ## Add the file to the main target
    project.targets.each do |target|
        target.add_file_references([xcFile])
    end

    ## Save the project file
    project.save()
end


