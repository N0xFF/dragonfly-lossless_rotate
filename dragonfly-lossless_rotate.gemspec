# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dragonfly/lossless_rotate/version"

Gem::Specification.new do |spec|
  spec.name         = "dragonfly-lossless_rotate"
  spec.version      = Dragonfly::LosslessRotate::VERSION
  spec.summary      = "Dragonfly lossless image rotate"
  spec.description  = "Lossless rotating and compressing JPEG images via libjpeg tools"
  spec.author       = "Maxim Perepelitsa"
  spec.email        = "n0xff@outlook.com"
  spec.homepage     = "https://github.com/n0xff/dragonfly-lossless_rotate"
  spec.license      = "MIT"

  spec.requirements << "cjpeg"
  spec.requirements << "djpeg"
  spec.requirements << "jpegtran"
  spec.requirements << "pnmflip"

  spec.files = `git ls-files`.split($/)

  spec.add_runtime_dependency "dragonfly", "~> 1.0"
end
