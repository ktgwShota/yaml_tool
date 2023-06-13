require 'yaml'

file = ARGV[0] # YAMLファイル
data = open(file,'r') { |f| YAML.load(f) } # YAMLを扱えるように変換

node_group_name = data['node_groups'].map { |node_group| node_group[0] }.drop(1) # ノードグループを取得（先頭のノードグループは使用しないので削除

def get_dest(data) # destのvalueを全て取得
  dest_lists = []
  if data.is_a?(Hash) 
    data.each do |key, value|
      if key == 'dest'
        dest_lists << value
      elsif value.is_a?(Hash) || value.is_a?(Array)
        sub_dests = get_dest(value)
        dest_lists.concat(sub_dests)
      end
    end
  elsif data.is_a?(Array)
    data.each do |value|
      sub_dests = get_dest(value)
      dest_lists.concat(sub_dests)
    end
  end
  dest_lists
end

result_1 = node_group_name - get_dest(data).uniq # ノードグループには存在するがdestでは指定されていない値
result_2 = get_dest(data).uniq - node_group_name # destでは指定されているがノードグループには存在しない値

puts '-----------------------------------------------'
puts "\e[32m使用されていないノードグループ名\e[0m"
puts "\e[31m#{result_1}\e[0m"
puts '///////////////////////////////////////////////'
puts "\e[32mdestで使用されているが存在しないノードグループ名\e[0m"
puts "\e[31m#{result_2}\e[0m"
puts '-----------------------------------------------'
