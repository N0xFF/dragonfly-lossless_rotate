require 'dragonfly'

Dragonfly::App.register_plugin(:lossless_rotate) { Dragonfly::LosslessRotate::Plugin.new }

module Dragonfly
  class LosslessRotate

    class Plugin
      def call(app, opts={})
        app.add_processor :lossless_rotate, Dragonfly::LosslessRotate::Rotate.new
        app.add_processor :safe_lossless_rotate, Dragonfly::LosslessRotate::SafeRotate.new
      end
    end

    # Only JPEG format
    class Rotate
      def call(content, degree=90, optimize=true)
        unless [90, 180, 270].include?(degree)
          warn "Rotate by 90, 180 and 270 degrees allowed"
          degree = 90
        end

        rotate(content, degree, optimize)
      end

      private

        def pnmflip_degrees(degree)
          { 90 => 270, 180 => 180, 270 => 90 }[degree]
        end

        def jpeg?(content)
          content.shell_eval { |path| "identify -format \%m #{path}" } == "JPEG"
        end

        def rotate(content, degree, optimize)
          cjpeg_bin    = content.env[:cjpeg_bin] || 'mozjpeg-cjpeg'
          djpeg_bin    = content.env[:djpeg_bin] || 'mozjpeg-djpeg'
          jpegtran_bin = content.env[:jpegtran_bin] || 'mozjpeg-jpegtran'
          pnmflip_bin  = content.env[:pnmflip_bin] || 'pnmflip' # pamflip

          content.shell_update escape: false do |old_path, new_path|
            optimize_option = " -optimize" if optimize
            output_command = if optimize
              " #{pnmflip_bin} -r#{pnmflip_degrees(degree)} | #{cjpeg_bin}#{optimize_option} > #{new_path}"
            else
              " convert - -rotate #{degree} JPG:#{new_path}"
            end

            lossless_rotate_command = "#{jpegtran_bin} -rotate #{degree} -perfect#{optimize_option} #{old_path} > #{new_path}"
            lossy_rotate_command = "#{djpeg_bin} #{old_path} |#{output_command}"

            "#{lossless_rotate_command} || #{lossy_rotate_command}"
          end
        end
    end

    # All formats support by ImageMagick
    class SafeRotate < Rotate
      def rotate(content, degree, optimize)
        return super if jpeg?(content)

        content.shell_update escape: false do |old_path, new_path|
          "convert -rotate #{degree} #{old_path} > #{new_path}"
        end
      end
      private :rotate
    end
  end
end
