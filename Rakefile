# frozen_string_literal: true

EXCLUDED = %w[k1-Twister ColAdj5 MtnPas SimWrp]
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

extensions = %w[anm tra obj cam scn]
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
                  "--label:#{prefix}\\#{filename[1..]}\n" +
                    current_script_lines.join("\n")
                )
                sources[extension] << {
                  "path" => path,
                  "label" => "#{current_script}"
                }
                current_script_lines = []
              end
              current_script = line[1..-1].strip
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
            "--label:#{prefix}\\#{filename[1..]}\n" +
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
            display_name, kind =
              if display_name.end_with?("/chk")
                [display_name.delete_suffix("/chk"), "check"]
              elsif display_name.end_with?("/col")
                [display_name.delete_suffix("/col"), "color"]
              elsif display_name.end_with?("/fig")
                [display_name.delete_suffix("/fig"), "figure"]
              else
                [display_name, "value"]
              end

            # replacements << "---##{kind}@#{variable_name}:#{display_name},#{initial_value}"
            replacements << <<~LUA
            ---$#{kind}:#{display_name}
            local #{variable_name} = #{initial_value}
            LUA
          end
        new_content =
          content.gsub(/--dialog:.*\n/, replacements.join("\n") + "\n")
        File.write(file, new_content)
      end
    end
end

task :rewrite_parameters do
  Dir
    .glob("./lua/**/*.lua")
    .each do |file|
      content = File.read(file)
      content.gsub!(/--track([0-3]):(.*)/) do |match|
        # --track0:項目名,最小値,最大値,デフォルト値,移動単位
        track_id = $1
        track_name, min, max, default, step = $2.split(",")
        step ||= "0.1"
        default ||= min
        unless track_name && min && max && default && step
          raise "Invalid track format in #{file}: #{match}"
        end

        <<~LUA
      ---$track:#{track_name}
      ---min=#{min}
      ---max=#{max}
      ---step=#{step}
      local rename_me_track#{track_id} = #{default}
      LUA
      end
      content.gsub!(/--check0:(.*)/) do |match|
        # --check0:項目名,デフォルト値（0か1）
        check_name, default = $1.split(",")
        default ||= "0"
        unless check_name && default
          raise "Invalid check format in #{file}: #{match}"
        end

        if default != "0" && default != "1"
          warn "Invalid default value for check in #{file}: #{match}"
        end
        <<~LUA
      ---$check:#{check_name}
      local rename_me_check0 = #{default.start_with?("0") ? "false" : "true"}
      LUA
      end
      content.gsub!(/--color:(.*)/) do |match|
        # --color:デフォルト値
        check_name, default = $1.split(",")
        default ||= "0"
        unless check_name && default
          raise "Invalid check format in #{file}: #{match}"
        end

        <<~LUA
      ---$color:#{check_name}
      local rename_me_color = #{default == "0" ? "false" : "true"}
      color = rename_me_color
      LUA
      end
      content.gsub!(/--file:/) { |match| <<~LUA }
      ---$file:ファイル
      local rename_me_file = ""
      file = rename_me_file
      LUA
      content.gsub!(/obj.getvalue\(([0-4])/) do |match|
        obj_id = $1
        "obj.getvalue(\"track.rename_me_track#{obj_id}\""
      end
      content.gsub!(/obj.track([0-4])/) { |match| "rename_me_track#{$1}" }
      content.gsub!(/obj.check0/) { |match| "rename_me_check0" }

      File.write(file, content)
    end
end

task :format do
  files = Dir.glob("./lua/**/*.lua")
  sh "stylua #{files.join(" ")}"
end

task :tasklist do
  require "yaml"
  project = YAML.load_file("aulua.yaml")
  puts "| カテゴリ | スクリプト | 動作確認 | DLL | パラメーター最適化 | シェーダー化 |"
  puts "|---|---|---|---|---|---|"
  project["scripts"].each do |script|
    script["sources"].each do |source|
      content = File.read(source["path"])
      if content.include?("--label:")
        label = content[/--label:(.*)/, 1]
        if content.include?("require")
          dll = ":x:"
        else
          dll = "-"
        end
        filename = File.basename(source["path"]).delete_suffix(".lua")
        label.gsub!(/#{prefix}\\?/, "")
        label = "-" if label.empty?
        puts "| #{label} | #{filename} | ？ | #{dll} | :x: | ？ |"
      end
    end
  end
end

task "tasklist:reorder" do
  sh "ruby ./scripts/reorder_tasklist.rb"
end

task :current_progress do
  tasklist = File.read("./TASKLIST.md")
  # | カテゴリ                  | スクリプト                                | 動作確認 | DLL | パラメーター改善 | シェーダー化 |
  num_checked = 0
  num_dll_ported = 0
  num_dll_all = 0
  num_parameter_improved = 0
  num_shader_ported = 0
  num_shader_all = 0
  num_scripts = 0
  tasklist
    .scan(/\| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|/)
    .each do |category, script, confirmed, dll, parameter, shader|
      next if category.include?("カテゴリ") || category.include?("----")
      num_checked += 1 if confirmed.include?("o")
      num_dll_ported += 1 if dll.include?("o")
      num_dll_all += 1 unless dll.include?("-")
      num_parameter_improved += 1 if parameter.include?("o")
      if shader.include?("o")
        num_shader_ported += 1
        num_shader_all += 1
      end
      num_shader_all += 1 if shader.include?("x")
      num_scripts += 1
    end

  puts "動作確認: #{num_checked}/#{num_scripts} (#{(num_checked.to_f / num_scripts * 100).round(1)}%)"
  puts "DLL移植: #{num_dll_ported}/#{num_dll_all} (#{num_dll_all > 0 ? (num_dll_ported.to_f / num_dll_all * 100).round(1) : "N/A"}%)"
  puts "パラメーター改善: #{num_parameter_improved}/#{num_scripts} (#{(num_parameter_improved.to_f / num_scripts * 100).round(1)}%)"
  puts "シェーダー化/最適化: #{num_shader_ported}/#{num_shader_all} (#{num_shader_all > 0 ? (num_shader_ported.to_f / num_shader_all * 100).round(1) : "N/A"}%)"
end
