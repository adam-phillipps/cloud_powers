require 'fileutils'
require 'pathname'
require 'uri'

module Smash
  module CloudPowers
    module PathHelp

      # Gives a common home for tasks to live so they can be easily grouped and
      # found.  This method will create nested directories, based on the
      # <tt>#project_root()</tt> method and an additional 'lib/tasks' directory.
      # If no project root has been set by the time this method is called, a new
      # directory will be created relative to the gem's project root.
      #
      # Returns
      # +String+
      #
      # Notes
      # * # If no project root has been set by the time this method is called, a new
      # directory will be created relative to the gem's project root.  This might
      # have deeper implications than you want to deal with so it's always a good
      # idea to set your project root as soon as you can.
      # * TODO: find a way to have this method figure out the actual project's
      #   root, as opposed to just making common <i>"good"</i> assumptions.
      def task_home
        string_th = FileUtils.mkdir_p("#{project_root}/lib/tasks/").first
        @task_home ||= Pathname.new(string_th).realpath.to_s
      end

      # Gives the path from the project root to lib/tasks[/#{file}.rb]
      #
      # Parameters
      # * file +String+ (optional) (default is '') - name of a file
      #
      # Returns
      # * path/file +String+ if +file+ parameter is given.  return has
      #   '.rb' extension included
      # * file +String+ if +file+ parameter is not given it will return the <tt>#task_require_path()</tt>
      #
      # Notes
      # * See <tt>#task_home</tt>
      def task_path(file = '')
       return task_home if file.empty?
        Pathname.new("#{task_home}/#{file}").to_s
      end


      # Check if the task file exists in the task directory
      #
      # Parameters
      # * file +String+
      #
      # Returns
      # +Boolean+
      #
      # Notes
      # * See +#task_home()+
      def task_exist?(file)
        begin
          File.new("#{task_home}/#{file}")
          true
        rescue Errno::ENOENT
          false
        end
      end

      # Gives the path from the project root to lib/tasks[/file]
      #
      # Parameters String (optional)
      # * file_name name of a file
      #
      # Returns
      # * path/file +String+ if +file_name+ was given
      # * path to task_directory if +file_name+ was <i>not</i> given
      #
      # Notes
      # * Neither path nor file will have a file extension
      # * See <tt>#task_home</tt>
      def task_require_path(file_name = '')
        begin
          file_sans_extension = File.basename(file_name, '.*')
          (Pathname.new(task_home) + file_sans_extension).to_s
        rescue Errno::ENOENT
          nil
        end
      end
    end
  end
end
