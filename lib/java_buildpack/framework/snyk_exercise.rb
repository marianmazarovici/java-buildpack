module JavaBuildpack
  module Framework
    class SnykExercise < JavaBuildpack::Component::BaseComponent
      # If the component should be used when staging an application
      #
      # @return [Array<String>, String, nil] If the component should be used when staging the application, a +String+ or
      #                                      an +Array<String>+ that uniquely identifies the component (e.g.
      #                                      +open_jdk=1.7.0_40+).  Otherwise, +nil+.
      def detect

      end

      # Modifies the application's file system.  The component is expected to transform the application's file system in
      # whatever way is necessary (e.g. downloading files or creating symbolic links) to support the function of the
      # component.  Status output written to +STDOUT+ is expected as part of this invocation.
      #
      # @return [Void]
      def compile

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
    end
  end
end