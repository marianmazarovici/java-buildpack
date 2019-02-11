require 'fileutils'
require 'net/http'
require 'json'
require 'java_buildpack/framework'


module JavaBuildpack
  module Framework
    class SnykExercise < JavaBuildpack::Component::BaseComponent
      # If the component should be used when staging an application
      #
      # @return [Array<String>, String, nil] If the component should be used when staging the application, a +String+ or
      #                                      an +Array<String>+ that uniquely identifies the component (e.g.
      #                                      +open_jdk=1.7.0_40+).  Otherwise, +nil+.
      def detect
        enabled? ? self.class.to_s: nil
      end

      # Modifies the application's file system.  The component is expected to transform the application's file system in
      # whatever way is necessary (e.g. downloading files or creating symbolic links) to support the function of the
      # component.  Status output written to +STDOUT+ is expected as part of this invocation.
      #
      # @return [Void]
      def compile
        response = request poms
      end

      # Modifies the application's runtime configuration. The component is expected to transform members of the +context+
      # (e.g. +@java_home+, +@java_opts+, etc.) in whatever way is necessary to support the function of the component.
      #
      # Container components are also expected to create the command required to run the application.  These components
      # are expected to read the +context+ values and take them into account when creating the command.
      #
      # @return [void, String] components other than containers are not expected to return any value.  Container
      #                        components are expected to return the command required to run the application.
      def release
      end

      def enabled?
        true
      end

      def api_url
        'https://cf-gate:5000/api'
      end

      def poms
        (filesystem_poms + jar_poms).flatten
      end

      def jar_poms
        (@application.root + '**/*.jar')
          .glob(File::FNM_DOTMATCH).reject(&:directory?).sort
          .map do |jar|
          `unzip -Z1 #{jar} | grep "pom\.xml"`.split("\n").map do |pom|
            `unzip -p #{jar} #{pom}`
          end
        end
      end

      def filesystem_poms
        (@application.root + '**/pom.xml').glob(File::FNM_DOTMATCH).reject(&:directory?).sort.map { |f| File.read(f) }
      end

      def request(poms)
        uri       = URI("#{api_url}")

        body = { 'encoding' => 'plain', 'files' => { 'target' => {} } }
        body['files'] = poms.map { |pom| { 'contents' => pom } } if poms.length > 1

        request                  = Net::HTTP::Post.new(uri)
        request['Content-Type']  = 'application/json'
        request.body             = body.to_json

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(request)
        end
      end
    end
  end
end