# frozen_string_literal: true

require "dragonfly"

Dragonfly::App.register_plugin(:lossless_rotate) { Dragonfly::LosslessRotate::Plugin.new }

module Dragonfly
  class LosslessRotate
    class Plugin
      def call(app, opts = {})
        app.env[:cjpeg_bin] = opts[:cjpeg_bin] || "cjpeg"
        app.env[:djpeg_bin] = opts[:djpeg_bin] || "djpeg"
        app.env[:jpegtran_bin] = opts[:jpegtran_bin] || "jpegtran"
        app.env[:pnmflip_bin] = opts[:pnmflip_bin] || "pnmflip"

        app.env[:libjpeg_optimize] = opts[:libjpeg_optimize] || true
        app.env[:libjpeg_progressive] = opts[:libjpeg_progressive] || false

        app.add_processor :lossless_rotate, Dragonfly::LosslessRotate::Rotate.new
        app.add_processor :safe_lossless_rotate, Dragonfly::LosslessRotate::SafeRotate.new
      end
    end

    # Only JPEG format
    class Rotate
      def call(content, degree = 90, optimize: nil, progressive: nil)
        unless [90, 180, 270, -90, -180, -270].include?(degree)
          warn "Rotate only by 90, 180 and 270 degrees allowed"
          degree = 90
        end

        optimize    ||= content.env[:libjpeg_optimize]
        progressive ||= content.env[:libjpeg_progressive]

        rotate(content, degree, optimize, progressive)
      end

      private

        def rotate(content, degree, optimize, progressive)
          cjpeg_bin    = content.env[:cjpeg_bin] || "cjpeg"
          djpeg_bin    = content.env[:djpeg_bin] || "djpeg"
          jpegtran_bin = content.env[:jpegtran_bin] || "jpegtran"
          pnmflip_bin  = content.env[:pnmflip_bin] || "pnmflip"

          content.shell_update escape: false do |old_path, new_path|
            optimize_option    = " -optimize" if optimize
            progressive_option = " -progressive" if progressive

            output_command = if optimize
              " #{pnmflip_bin} -r#{pnmflip_degrees(degree)} | #{cjpeg_bin}#{progressive_option}#{optimize_option} > '#{new_path}'"
            else
              " convert - -rotate #{degree} 'JPG:#{new_path}'"
            end

            lossless_rotate_command = "#{jpegtran_bin} -rotate #{jpegtran_degrees(degree)} -perfect#{progressive_option}#{optimize_option} '#{old_path}' > '#{new_path}'"
            lossy_rotate_command = "#{djpeg_bin} '#{old_path}' |#{output_command}"

            "#{lossless_rotate_command} || #{lossy_rotate_command}"
          end
        end

        def pnmflip_degrees(degree)
          {
            90 => 270,
            180 => 180,
            270 => 90,
            -90 => 90,
            -180 => 180,
            -270 => 270
          }[degree]
        end

        def jpegtran_degrees(degree)
          {
            90 => 90,
            180 => 180,
            270 => 180,
            -90 => 270,
            -180 => 180,
            -270 => 90
          }[degree]
        end

        def jpeg?(content)
          content.shell_eval { |path| "identify -format \%m #{path}" } == "JPEG"
        end
    end

    # All formats support by ImageMagick
    class SafeRotate < Rotate
      def rotate(content, degree, optimize, progressive)
        return super if jpeg?(content)

        content.shell_update do |old_path, new_path|
          "convert #{old_path} -rotate #{degree} #{new_path}"
        end
      end
      private :rotate
    end
  end
end
