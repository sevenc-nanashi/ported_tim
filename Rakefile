# frozen_string_literal: true

EXCLUDED = %w[k1-Twister ColAdj5 MtnPas]
prefix = "tim2"
task :download do
  require "open-uri"
  require "fileutils"
  require "zip"

  html =
    URI
      .open("https://tim3.web.fc2.com/sidx.htm")
      .read
      .force_encoding("SHIFT_JIS")
  scripts = html.scan(%r{<a href="\./script/(.*?)\.zip">}).flatten
  FileUtils.mkdir_p("./original/zips")
  Zip.unicode_names = true
  Zip.force_entry_names_encoding = "SHIFT_JIS"
  scripts.each do |script|
    url = "https://tim3.web.fc2.com/script/#{script}.zip"
    puts "Downloading #{url}..."
    URI.open(url) do |remote_file|
      File.open("./original/zips/#{script}.zip", "wb") do |local_file|
        local_file.write(remote_file.read)
      end

      Zip::File.open("./original/zips/#{script}.zip") do |zip_file|
        zip_file.each do |entry|
          path = File.join("./original/scripts", script, entry.name)
          FileUtils.mkdir_p(File.dirname(path))
          entry.extract(path) unless File.exist?(path)
          puts "Extracted #{entry.name} to #{path}"
        end
      end
    end
  end
end

extensions = %w[anm tra obj]
task :seed do
  require "yaml"
  require "fileutils"

  project = {
    "project" => {
    },
    "build" => {
      "out_dir" => "build"
    },
    "scripts" => []
  }
  sources = extensions.to_h { |ext| [ext, []] }
  Dir
    .glob("./original/scripts/**/*.*")
    .each do |file|
      script_name = file.split("/")[3]
      next if EXCLUDED.include?(script_name)
      filename = File.basename(file)
      extension = File.extname(filename).delete_prefix(".")
      next unless extensions.include?(extension)
      root = "./lua/#{script_name}/"
      if filename.start_with?("@")
        content = File.read(file, encoding: "SHIFT_JIS").encode("UTF-8")
        current_script = nil
        current_script_lines = []
        content
          .split("\n")
          .each_with_index do |line, index|
            if line.start_with?("@")
              if current_script
                FileUtils.mkdir_p(root)
                path = File.join(root, current_script.gsub("/", "__") + ".lua")
                File.write(
                  path,
                  "--label:#{prefix}\\#{filename[1..]}\\#{current_script}\n" +
                    current_script_lines.join("\n")
                )
                sources[extension] << {
                  "path" => path,
                  "label" => "#{current_script}"
                }
                current_script_lines = []
              end
              current_script = line[1..-1]
              next
            end
            next unless current_script
            current_script_lines << line
          end
        if current_script
          FileUtils.mkdir_p(root)
          path = File.join(root, current_script.gsub("/", "__") + ".lua")
          File.write(
            path,
            "--label:#{prefix}\\#{filename[1..]}\\#{current_script}\n" +
              current_script_lines.join("\n")
          )
          sources[extension] << {
            "path" => path,
            "label" => "#{current_script}"
          }
        end
      else
        content = File.read(file, encoding: "SHIFT_JIS").encode("UTF-8")
        FileUtils.mkdir_p(root)
        File.write(
          File.join(root, filename + ".lua"),
          "--label:#{prefix}\n" + content
        )
        path = File.join(root, filename + ".lua")
        sources[extension] << { "path" => path, "label" => filename }
      end
    end

  sources.each do |ext, files|
    project["scripts"] << { "name" => "tim2.#{ext}2", "sources" => files }
  end
  File.write("aulua.yaml", project.to_yaml)
end

task :flatten_dialog do
  require "fileutils"

  FileUtils.mkdir_p("./lua")
  Dir
    .glob("./lua/**/*.lua")
    .each do |file|
      content = File.read(file)
      if content.include?("--dialog:")
        puts "Flattening dialog in #{file}..."
        dialog = content[/--dialog:(.*)/, 1]
        # --dialog:表示名,変数名=初期値;(以降、表示名から繰り返し)
        replacements = []
        dialog
          .split(";")
          .each do |entry|
            next if entry.strip.empty?
            display_name, rest = entry.split(",", 2)
            variable_name, initial_value = rest.split("=", 2)
            variable_name = variable_name.delete_prefix("local ")
            variable_name, kind =
              if variable_name.end_with?("/chk")
                [variable_name.delete_suffix("/chk"), "check"]
              elsif variable_name.end_with?("/col")
                [variable_name.delete_suffix("/col"), "color"]
              elsif variable_name.end_with?("/fig")
                [variable_name.delete_suffix("/fig"), "figure"]
              else
                [variable_name, "value"]
              end

            replacements << "--#{kind}@#{variable_name}:#{display_name},#{initial_value}"
          end
        new_content = content.gsub(/--dialog:.*\n/, replacements.join("\n") + "\n")
        File.write(file, new_content)
      end
    end
end

task :format do
  files = Dir.glob("./lua/**/*.lua")
  sh "stylua #{files.join(" ")}"
end
