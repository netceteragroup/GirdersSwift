file_name = "module.modulemap"
text = File.read(file_name)
path = `xcode-select -p`.strip << "/"
new_contents = text.gsub(/\/Applications\/Xcode.app\/Contents\/Developer\//, path)
File.open(file_name, "w") {|file| file.puts new_contents }