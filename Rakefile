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
        script_label = "@#{filename[1..]}"
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
                  "--label:#{prefix}\\#{script_label}\n" +
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
            "--label:#{prefix}\\#{script_label}\n" +
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
  lua_files = Dir.glob("./lua/**/*.lua")
  sh "stylua #{lua_files.join(" ")}"

  hlsl_files = Dir.glob("./lua/**/*.hlsl")
  sh "clang-format -i #{hlsl_files.join(" ")}"

  sh "cargo fmt"
end

task :check_setanchor_variables do
  issues = []

  Dir
    .glob("./lua/**/*.lua")
    .sort
    .each do |file|
      lines = File.readlines(file, chomp: true)
      anchorable_variables = {}
      pending_kind = nil

      lines.each_with_index do |line, index|
        if (match = line.match(/^---\$(track|value):/))
          pending_kind = match[1]
          next
        end

        if pending_kind
          if (match = line.match(/^\s*local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=/))
            anchorable_variables[match[1]] = pending_kind
            pending_kind = nil
            next
          end

          next if line.strip.empty? || line.start_with?("---")

          pending_kind = nil
        end

        next unless (match = line.match(/obj\.setanchor\("([^"]+)"/))

        variable_names = match[1].split(",").map(&:strip).reject(&:empty?)

        variable_names.each do |variable_name|
          next if anchorable_variables.key?(variable_name)

          issues << "#{file}:#{index + 1}: setanchor target `#{variable_name}` is not declared as ---$track or ---$value"
        end
      end
    end

  if issues.empty?
    puts "All setanchor targets are declared as ---$track or ---$value."
  else
    abort(issues.join("\n"))
  end
end

task :tasklist do
  require "yaml"
  project = YAML.load_file("aulua.yaml")
  rows = []
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
        effect = source["label"]
        label = label.delete_prefix("#{prefix}\\")
        category, script_name = label.split("\\", 2)
        category ||= "-"
        script_name = "-" if script_name.nil? || script_name.empty?
        if script_name == "-" &&
             effect.match?(/\A.+\.(?:anm|obj|cam|tra|scn)\z/)
          script_name = effect
          effect = "-"
        end
        rows << [category, script_name, effect, "？", dll, ":x:", ":x:"]
      end
    end
  end

  header = %w[カテゴリ スクリプト エフェクト名 動作確認 DLL パラメーター改善 シェーダー化・最適化]
  widths =
    header.map.with_index do |cell, index|
      ([cell] + rows.map { |row| row[index] }).map(&:length).max
    end

  puts "| #{header.each_with_index.map { |cell, index| cell.ljust(widths[index]) }.join(" | ")} |"
  puts "| #{widths.map { |width| "-" * width }.join(" | ")} |"
  rows.each do |row|
    puts "| #{row.each_with_index.map { |cell, index| cell.ljust(widths[index]) }.join(" | ")} |"
  end
end

task :current_progress do
  require "csv"
  tasklist = File.read("./TASKLIST.md")
  num_checked = 0
  num_dll_ported = 0
  num_dll_all = 0
  num_parameter_improved = 0
  num_shader_ported = 0
  num_shader_all = 0
  num_scripts = 0
  lines = tasklist.scan(/^\| (.*?) \|$/m)
  lines.delete_at(1)
  loaded =
    CSV.parse(lines.join("\n").gsub(" ", ""), col_sep: "|", headers: :first_row)
  loaded.each do |row|
    confirmed = row.fetch("動作確認").strip
    dll = row.fetch("DLL").strip
    parameter = row.fetch("パラメーター改善").strip
    shader = row.fetch("シェーダー化・最適化").strip
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

namespace :i18n do
  DEFAULT_LANG = "Default"
  task :seed do
    require "yaml"
    translations = {}
    languages =
      Dir
        .glob("./i18n/*.yaml")
        .map do |file|
          lang = File.basename(file, ".yaml")
          content = YAML.load_file(file)
          content&.each do |group, entries|
            entries.each do |key, value|
              translations[group] ||= {}
              translations[group][key] ||= {}
              translations[group][key][lang] = value
            end
          end
          lang
        end
    files = Dir.glob("./build/@*.*")
    translation_meta = {}
    translation_labels = Set[]
    files.each do |file|
      content = File.read(file)
      current_script = nil
      suffix = file.match(/(@.+\..+)\..*/, 1)[1]
      content.lines.each_with_index do |line, index|
        if line.start_with?("@")
          current_script = line[1..-1].strip
          group = "#{current_script}#{suffix}"
          translations[group] ||= {}
          translations[group][group] ||= {}
          translations[group][group][DEFAULT_LANG] = group
          translation_meta[group] ||= {}
          translation_meta[group][group] = "script name"
          next
        end
        next unless current_script

        line.chomp!
        group = "#{current_script}#{suffix}"
        kinds = %w[
          track
          check
          color
          file
          folder
          font
          figure
          text
          value
          group
          separator
        ].join("|")
        if (match = line.match(/--(#{kinds})@[^:]+:(?:[^:,]+::)*([^,]+)/))
          kind = match[1]
          label = match[2]
          translations[group] ||= {}
          translations[group][label] ||= {}
          translations[group][label][DEFAULT_LANG] = label
          translation_meta[group] ||= {}
          translation_meta[group][label] = "kind: #{kind}"
        elsif (
              match =
                line.match(/--select@[^:]+:(?:[^,]+::)*([^,=]+)=[0-9]+,(.*)/)
            )
          label = match[1]
          options = match[2].split(",").map { |option| option.split("=", 2)[0] }
          translations[group] ||= {}
          translations[group][label] ||= {}
          translations[group][label][DEFAULT_LANG] = label
          translation_meta[group] ||= {}
          translation_meta[group][
            label
          ] = "kind: select, options: #{options.join(", ")}"
          options.each do |option|
            translations[group][option] ||= {}
            translations[group][option][DEFAULT_LANG] = option
            translation_meta[group] ||= {}
            translation_meta[group][
              option
            ] = "kind: select_option, parent: #{label}"
          end
        elsif (match = line.match(/--label:(.*)/))
          label = match[1]
          translation_labels << label
        else
          next
        end
      end
    end

    translation_files = {}
    languages.each { |lang| translation_files[lang] ||= {} }
    translations.each do |group, entries|
      entries.each do |key, langs|
        langs.each do |lang, value|
          translation_files[lang] ||= {}
          translation_files[lang][group] ||= {}
          translation_files[lang][group][key] = value
        end
      end
    end
    translation_files.each_key do |lang|
      File.open("./i18n/#{lang}.yaml", "w") do |file|
        groups = translation_files[DEFAULT_LANG]
        groups.each do |group, entries|
          file.puts "#{group}:"
          entries.each do |key, value|
            meta = translation_meta.dig(group, key)
            file.puts "  # #{meta}" if meta
            file.puts "  '#{key}': #{translation_files[lang].dig(group, key) || value}"
          end
        end
        file.puts
        file.puts "labels:"
        translation_labels.each do |label|
          file.puts "  '#{label}': #{translation_files[lang].dig("labels", label) || label}"
        end
      end
    end
  end

  task :build do
    require "yaml"
    translations =
      Dir
        .glob("./i18n/*.yaml")
        .to_h do |file|
          lang = File.basename(file, ".yaml")
          content = YAML.load_file(file)
          [lang, content]
        end
    groups = translations[DEFAULT_LANG]
    translations.each_key do |lang|
      File.open("./build/#{lang}.ported_tim.aul2", "w") do |file|
        groups.each do |group, entries|
          if group == "labels"
            file.puts("[Effect]")
          else
            file.puts("[#{group}]")
          end
          entries.each do |key, value|
            file.puts("#{key}=#{translations[lang].dig(group, key) || value}")
          end
        end
      end
    end
  end
end
