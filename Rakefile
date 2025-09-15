# Rakefile
require_relative 'lib/stable'

Stable.configure do |config|
  latest_spec_file = Dir.glob("/tmp/stable-*.jsonl").max_by { |f| File.mtime(f) }
  config.storage_path = latest_spec_file
end
