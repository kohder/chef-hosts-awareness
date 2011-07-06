require 'fileutils'
require 'tempfile'

COOKBOOK_DIR = File.dirname(__FILE__)
COOKBOOK_NAME = 'hosts-awareness'
MANIFEST = %w{
  attributes
  libraries
  recipes
  metadata.*
  README.*
}

desc 'Create tarball of cookbook for distribution'
task :create_tarball do
  metadata_rb = File.join(COOKBOOK_DIR, 'metadata.rb')
  system("knife cookbook metadata from file #{metadata_rb}")
  tarball_name = "#{COOKBOOK_NAME}.tgz"
  temp_dir = File.join(Dir.tmpdir, 'chef-cookbooks')
  temp_cookbook_dir = File.join(temp_dir, COOKBOOK_NAME)
  dist_dir = File.join(COOKBOOK_DIR, 'dist')

  FileUtils.mkdir_p(dist_dir)
  FileUtils.mkdir(temp_dir)
  FileUtils.mkdir(temp_cookbook_dir)

  files = MANIFEST.inject([]) do |arr, manifest_entry|
    arr + Dir.glob(File.join(COOKBOOK_DIR, manifest_entry))
  end
  FileUtils.cp_r files, temp_cookbook_dir

  system('tar', '-C', temp_dir, '-cvzf', File.join(dist_dir, tarball_name), File.join('.', COOKBOOK_NAME))

  FileUtils.rm_rf temp_dir
end
